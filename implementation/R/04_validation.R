# =============================================================================
# 04_validation.R                                       Workflow step 6: Validation
#
# External validation: recalculates 24 figures published in the survey's own
# report (Bursting at the seams, 2024) from the public data, and tests
# explanations for the figures that do not match.
#
# Rules from the analysis plan:
#   - The six August-round states covered by the report.
#   - The report does not say how its "six states" figures are calculated, so
#     two definitions are calculated for ALL of them: the share of all households
#     pooled, and the average of the six state shares. Each definition gets its
#     own verdict; we never pick the closer one figure by figure.
#   - Verdict: within 2 points = reproduced; 2-5 = close; over 5 = not reproduced.
#
# Input : data/clean/analysis_data.rds, data/clean/sensitivity_data.rds,
#         data/reference/nrc_published_figures.csv (wording and page of each figure),
#         data/raw/<survey file>.xlsx (for one of the tested explanations)
# Output: output/tables/T6_validation.csv, output/validation_summary.txt
# =============================================================================

library(tidyverse)
library(readxl)

six_states <- c("Blue Nile", "Gedaref", "Kassala", "Northern", "Red Sea", "White Nile")
a    <- readRDS("data/clean/analysis_data.rds")    %>% filter(state %in% six_states)
sens <- readRDS("data/clean/sensitivity_data.rds") %>% filter(state %in% six_states)
published <- read_csv("data/reference/nrc_published_figures.csv", show_col_types = FALSE)

verdict <- function(diff) case_when(abs(diff) <= 2 ~ "Reproduced",
                                    abs(diff) <= 5 ~ "Close",
                                    TRUE           ~ "Not reproduced")

# share(): % of households with the indicator = 1, for one group and one state,
# or for the six states (pooled, or the average of the state shares).
share <- function(data, var, grp, where, method = "pooled") {
  x <- filter(data, group == grp, !is.na(.data[[var]]))
  if (where != "Six states") return(100 * mean(x[[var]][x$state == where]))
  if (method == "pooled") return(100 * mean(x[[var]]))
  x %>% group_by(state) %>% summarise(p = 100 * mean(.data[[var]])) %>% pull(p) %>% mean()
}


# 1. RECALCULATE EACH PUBLISHED FIGURE --------------------------------------------
T6 <- published %>% mutate(pooled = NA_real_, mean_of_states = NA_real_, by_questions_answered = NA_real_)
for (i in seq_len(nrow(T6))) {
  f <- T6[i, ]
  # Some report figures are the opposite of our indicator
  # (e.g. "not attending school" = 100 - attending).
  flip <- function(x) if (f$transform == "100 - pct") 100 - x else x
  T6$pooled[i]          <- flip(share(a, f$our_variable, f$group, f$state, "pooled"))
  T6$mean_of_states[i]  <- if (f$state == "Six states") flip(share(a, f$our_variable, f$group, f$state, "mean")) else NA
  T6$by_questions_answered[i] <- flip(share(sens, f$our_variable, f$group, f$state, "pooled"))
}
T6 <- T6 %>% mutate(
  verdict_pooled = verdict(pooled - nrc_value),
  # For state figures there is only one definition, so both verdicts are the same
  verdict_mean_of_states = verdict(coalesce(mean_of_states, pooled) - nrc_value)
)


# 2. TEST EXPLANATIONS FOR FIGURES THAT DO NOT MATCH --------------------------------

# Explanation A: the wrong denominator. Host "yes" answers divided by ALL
# respondents in the six states (IDPs and hosts), instead of by hosts only.
T6$all_respondents_denominator <- NA
for (i in which(T6$state == "Six states" & T6$transform == "pct")) {
  v <- T6$our_variable[i]
  T6$all_respondents_denominator[i] <- 100 * sum(a[[v]][a$group == T6$group[i]] == 1, na.rm = TRUE) /
                                             sum(!is.na(a[[v]]))
}

# Explanation B: school attendance without our age check (children recorded
# outside 6-14 kept). Needs the raw answers, before cleaning.
raw <- read_excel("data/raw/idmc_sudan_socioeconomicimpact_idps_06122024_10012025.xlsx",
                  sheet = "Main", col_types = "text") %>%
  inner_join(select(a, case_id, group), by = "case_id") %>%
  mutate(attends = if_else(group == "IDP", attendance_now_idp_001, attendance_now_host)) %>%
  filter(!is.na(attends), str_trim(attends) != "")
T6$school_without_age_check <- NA
for (i in which(T6$our_variable == "ind7_school")) {
  x <- filter(raw, group == T6$group[i])
  if (T6$state[i] != "Six states") x <- filter(x, state == T6$state[i])
  T6$school_without_age_check[i] <- 100 - 100 * mean(x$attends == "Yes")
}

T6 <- T6 %>% mutate(explanation = case_when(
  abs(all_respondents_denominator - nrc_value) <= 2 ~
    "Within 2 points if host answers are divided by ALL respondents: consistent with a denominator error in the report (hypothesis, not proven)",
  abs(school_without_age_check - nrc_value) <= 2 ~ "Matches without the 6-14 age check",
  verdict_pooled == "Not reproduced" | verdict_mean_of_states == "Not reproduced" ~
    "No tested explanation reproduces it",
  state == "Kassala" ~ "The report counts more IDPs in Kassala; see the value by questions answered",
  TRUE ~ ""))


# 3. SAVE ------------------------------------------------------------------------------
T6 <- mutate(T6, across(where(is.double), ~ round(.x, 1)))
write_csv(T6, "output/tables/T6_validation.csv", na = "")

count_verdicts <- function(v) sprintf("%d reproduced, %d close, %d not reproduced",
                                      sum(v == "Reproduced"), sum(v == "Close"), sum(v == "Not reproduced"))
summary_lines <- c(
  paste("Of", nrow(T6), "published figures:"),
  paste("  six-state figures as pooled shares:      ", count_verdicts(T6$verdict_pooled)),
  paste("  six-state figures as average of states:  ", count_verdicts(T6$verdict_mean_of_states)))
writeLines(summary_lines, "output/validation_summary.txt")
cat(summary_lines, sep = "\n")
