# =============================================================================
# 03_analysis.R                                           Workflow step 5: Analysis
#
# Produces the results tables fixed in the analysis plan:
#   T1 sample · T2 IDP and host households (SQ1) · T3 differences among IDPs (SQ2)
#   T4 before leaving home and now, as recalled by IDPs (SQ3)
#   T5 don't know / prefer not to answer · S1 sensitivity check (step 6)
#
# Rules from the analysis plan:
#   - Results by state only; no figures for all states together (no weights).
#   - 95% confidence intervals clustered by settlement, labelled indicative.
#   - A difference is CLEAR when the interval excludes 0 AND it is at least
#     5 percentage points.
#   - Fewer than 30 households: not reported. 30-49: flagged.
#   - SQ2: each IDP group against all other IDPs in the same state. A group is
#     "consistently worse off" only with a clear difference in at least half
#     of the states where it can be reported, and in at least 4 states.
#
# Input : data/clean/analysis_data.rds, data/clean/sensitivity_data.rds,
#         output/dq_flags.csv
# Output: output/tables/*.csv
# =============================================================================

library(tidyverse)
library(survey)
options(survey.lonely.psu = "adjust")   # a settlement with one household does not stop the analysis

a     <- readRDS("data/clean/analysis_data.rds")
sens  <- readRDS("data/clean/sensitivity_data.rds")
flags <- read_csv("output/dq_flags.csv", show_col_types = FALSE)
dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)

MIN_N   <- 30   # minimum households per figure
FLAG_N  <- 50   # 30-49 flagged
MIN_DIFF <- 5   # minimum difference (points) for a clear difference

# The seven indicators. For school attendance, a LOWER share is worse.
indicators <- tribble(
  ~var,                ~label,                                       ~higher_is_worse,
  "ind1_food",         "1 Not able to access enough food",           TRUE,
  "ind2_noearner",     "2 No household member earning from work",    TRUE,
  "ind3_water",        "3 Difficulty accessing safe drinking water", TRUE,
  "ind4_nolatrine",    "4 No latrine where they live",               TRUE,
  "ind5_nfi",          "5 Urgent need of non-food items",            TRUE,
  "ind6_nofreehealth", "6 No free access to a health professional",  TRUE,
  "ind7_school",       "7 Child aged 6-14 attends school",           FALSE
)
states <- sort(unique(a$state))


# THE COMPARISON ---------------------------------------------------------------
# compare(): share in group A, share in group B, the difference A - B in points,
# and its 95% confidence interval clustered by settlement.
# The interval comes from a regression of the 0/1 indicator on the group,
# using the survey package with all weights equal to 1 (the data have no weights).

compare <- function(y, is_a, cluster) {
  keep <- !is.na(y) & !is.na(is_a)
  y <- y[keep]; is_a <- is_a[keep]; cluster <- cluster[keep]
  out <- tibble(n_a = sum(is_a), n_b = sum(!is_a),
                pct_a = 100 * mean(y[is_a]), pct_b = 100 * mean(y[!is_a]),
                difference = pct_a - pct_b, ci_low = NA_real_, ci_high = NA_real_)

  if (out$n_a < MIN_N | out$n_b < MIN_N) {          # too few households: not reported
    out$pct_a[out$n_a < MIN_N] <- NA
    out$pct_b[out$n_b < MIN_N] <- NA
    out$difference <- NA
    return(out)
  }
  if (var(y) == 0) {                                 # everyone gave the same answer
    out$ci_low <- out$ci_high <- out$difference
    return(out)
  }
  design <- svydesign(ids = ~cluster, weights = ~w, data = tibble(y, is_a, cluster, w = 1))
  fit    <- svyglm(y ~ is_a, design = design)
  ci     <- confint(fit, df = degf(design))["is_aTRUE", ]
  out$ci_low <- 100 * ci[[1]]; out$ci_high <- 100 * ci[[2]]
  out
}

# verdict(): is the difference clear, and who is worse off?
verdict <- function(res, higher_is_worse, name_a, name_b) {
  res %>% mutate(
    reported = !is.na(difference),
    clear    = reported & (ci_low > 0 | ci_high < 0) & abs(difference) >= MIN_DIFF,
    worse_off = case_when(!clear ~ "No clear difference",
                          (difference > 0) == higher_is_worse ~ name_a,
                          TRUE ~ name_b),
    flag = case_when(!reported ~ "Not reported (under 30)",
                     n_a < FLAG_N | n_b < FLAG_N ~ "Interpret with caution (30-49)",
                     TRUE ~ ""))
}

round1 <- function(x) mutate(x, across(where(is.double), ~ round(.x, 1)))


# T1. SAMPLE --------------------------------------------------------------------
T1 <- flags %>%
  filter(!flag_duplicate_row) %>%
  mutate(status = if_else(is.na(analysis_group), paste("Excluded:", exclusion_reason),
                          paste("Analysed:", analysis_group))) %>%
  count(state, status) %>%
  pivot_wider(names_from = status, values_from = n, values_fill = 0)


# T2. SQ1: IDP AND HOST HOUSEHOLDS, BY STATE ---------------------------------------
T2 <- tibble()
for (i in seq_len(nrow(indicators))) {
  for (s in states) {
    dd  <- filter(a, state == s)
    res <- compare(dd[[indicators$var[i]]], dd$group == "IDP", dd$cluster_id) %>%
      verdict(indicators$higher_is_worse[i], "IDPs", "Hosts")
    T2 <- bind_rows(T2, tibble(indicator = indicators$label[i], state = s, res))
  }
}
T2 <- rename(T2, n_idp = n_a, n_host = n_b, pct_idp = pct_a, pct_host = pct_b)

T2_summary <- T2 %>% group_by(indicator) %>%
  summarise(states_reported   = sum(reported),
            idps_worse_off    = sum(worse_off == "IDPs"),
            hosts_worse_off   = sum(worse_off == "Hosts"),
            no_clear_difference = sum(reported & worse_off == "No clear difference"))


# T3. SQ2: DIFFERENCES AMONG IDP HOUSEHOLDS -----------------------------------------
# Each group against all other IDPs in the same state, on four indicators.
idp <- filter(a, group == "IDP")
sq2_groups <- tribble(
  ~grouping,                 ~variable,              ~category,
  "Sex of respondent",       "sex_respondent",       "Female",
  "Disability in household", "disability_household", "Yes",
  "Shelter type",            "shelter_type",         "Camps and sites",
  "Shelter type",            "shelter_type",         "Host family",
  "Shelter type",            "shelter_type",         "Rented",
  "Shelter type",            "shelter_type",         "Other"
)
sq2_indicators <- filter(indicators, var %in% c("ind1_food", "ind2_noearner", "ind3_water", "ind7_school"))

T3 <- tibble()
for (g in seq_len(nrow(sq2_groups))) {
  for (i in seq_len(nrow(sq2_indicators))) {
    for (s in states) {
      dd   <- filter(idp, state == s)
      is_a <- dd[[sq2_groups$variable[g]]] == sq2_groups$category[g]
      res  <- compare(dd[[sq2_indicators$var[i]]], is_a, dd$cluster_id) %>%
        verdict(sq2_indicators$higher_is_worse[i], "Group", "Other IDPs")
      T3 <- bind_rows(T3, tibble(grouping = sq2_groups$grouping[g], group = sq2_groups$category[g],
                                 indicator = sq2_indicators$label[i], state = s, res))
    }
  }
}
T3 <- rename(T3, n_group = n_a, n_other_idps = n_b, pct_group = pct_a, pct_other_idps = pct_b)

T3_summary <- T3 %>% group_by(grouping, group, indicator) %>%
  summarise(states_reported   = sum(reported),
            clearly_worse_off = sum(worse_off == "Group"),
            clearly_better_off = sum(worse_off == "Other IDPs"), .groups = "drop") %>%
  mutate(consistently_worse_off = states_reported >= 4 & clearly_worse_off >= states_reported / 2,
         summary = if_else(states_reported < 4,
                           paste0("Not enough states to judge (", states_reported, " reportable)"),
                           paste0("Clearly worse off in ", clearly_worse_off, " of ", states_reported, " states")))


# T4. SQ3: BEFORE LEAVING HOME AND NOW (IDPs, as recalled) ----------------------------
# The change is the average of each household's own change (now minus before),
# with a confidence interval clustered by settlement.
T4 <- tibble()
for (r in list(c("R1 Not able to access enough food", "r1_food_pre", "r1_food_now"),
               c("R2 No household member earning from work", "r2_noearner_pre", "r2_noearner_now"))) {
  for (s in states) {
    dd <- idp %>% filter(state == s, !is.na(.data[[r[2]]]), !is.na(.data[[r[3]]])) %>%
      mutate(change = .data[[r[3]]] - .data[[r[2]]], w = 1)
    design <- svydesign(ids = ~cluster_id, weights = ~w, data = dd)
    m  <- svymean(~change, design)
    ci <- confint(m, df = degf(design))
    T4 <- bind_rows(T4, tibble(indicator = r[1], state = s, n = nrow(dd),
                               pct_before = 100 * mean(dd[[r[2]]]), pct_now = 100 * mean(dd[[r[3]]]),
                               change = 100 * coef(m)[[1]], ci_low = 100 * ci[1], ci_high = 100 * ci[2]))
  }
}

T4_documents <- idp %>% group_by(state) %>%
  summarise(n = sum(!is.na(r3_lost_docs)),
            across(starts_with("r3_lost"), ~ 100 * mean(.x, na.rm = TRUE)))


# T5. DON'T KNOW / PREFER NOT TO ANSWER, where above 5% ---------------------------------
T5 <- a %>% select(state, group, starts_with("ans")) %>%
  pivot_longer(starts_with("ans"), names_to = "indicator", values_to = "answer") %>%
  filter(!is.na(answer)) %>%
  group_by(indicator, state, group) %>%
  summarise(n = n(),
            pct_dont_know  = 100 * mean(answer == "Don't know"),
            pct_prefer_not = 100 * mean(answer == "Prefer not to answer"), .groups = "drop") %>%
  filter(pct_dont_know > 5 | pct_prefer_not > 5)


# S1. SENSITIVITY CHECK: groups defined by the questions answered (step 6) -----------
S1 <- tibble()
for (i in seq_len(nrow(indicators))) {
  for (s in states) {
    dd  <- filter(sens, state == s)
    res <- compare(dd[[indicators$var[i]]], dd$group == "IDP", dd$cluster_id) %>%
      verdict(indicators$higher_is_worse[i], "IDPs", "Hosts")
    S1 <- bind_rows(S1, tibble(indicator = indicators$label[i], state = s,
                               difference_by_questions = res$difference,
                               worse_off_by_questions  = res$worse_off))
  }
}
S1 <- S1 %>%
  left_join(select(T2, indicator, state, difference_by_status = difference, worse_off_by_status = worse_off),
            by = c("indicator", "state")) %>%
  mutate(verdict_changes = worse_off_by_questions != worse_off_by_status)


# SAVE -----------------------------------------------------------------------------
write_csv(T1,                   "output/tables/T1_sample.csv")
write_csv(round1(T2),           "output/tables/T2_idp_and_host.csv", na = "")
write_csv(T2_summary,           "output/tables/T2_summary.csv")
write_csv(round1(T3),           "output/tables/T3_differences_among_idps.csv", na = "")
write_csv(T3_summary,           "output/tables/T3_summary.csv")
write_csv(round1(T4),           "output/tables/T4_recall.csv")
write_csv(round1(T4_documents), "output/tables/T4_lost_documents.csv")
write_csv(round1(T5),           "output/tables/T5_dont_know.csv")
write_csv(round1(S1),           "output/tables/S1_sensitivity.csv", na = "")

cat("Done. Verdicts changed in the sensitivity check:", sum(S1$verdict_changes, na.rm = TRUE),
    "of", sum(!is.na(S1$verdict_changes)), "\n")
