# =============================================================================
# 02_cleaning.R                                           Workflow step 4: Cleaning
#
# Applies the decisions from the data quality step, builds the groups and the
# indicators, and records every change in the cleaning log.
# The raw file is never edited: this script reads it and writes a clean copy.
#
# Input : data/raw/<survey file>.xlsx   (from HDX, never edited)
#         output/dq_flags.csv           (from 01_data_quality.R)
# Output: data/clean/analysis_data.rds     one line per household in the analysis
#         data/clean/sensitivity_data.rds  same indicators, groups defined by
#                                          the questions answered (step 6)
#         output/cleaning_log.csv          one line per change
#
# Run 01_data_quality.R first.
# =============================================================================

library(tidyverse)
library(readxl)

raw_file <- "data/raw/idmc_sudan_socioeconomicimpact_idps_06122024_10012025.xlsx"
dir.create("data/clean", showWarnings = FALSE)

d     <- read_excel(raw_file, sheet = "Main", col_types = "text")
flags <- read_csv("output/dq_flags.csv", col_types = cols(.default = "c"))

# The cleaning log: each change adds a line with log_change().
cleaning_log <- tibble()
log_change <- function(order, variable, rows, rule, from_check) {
  cleaning_log <<- bind_rows(cleaning_log, tibble(order, variable, rows_changed = rows, rule, from_check))
}

as_num <- function(x) suppressWarnings(as.numeric(x))


# 1. BLANK CELLS -> MISSING ----------------------------------------------------
n_blank <- sum(map_int(d, ~ sum(!is.na(.x) & str_trim(.x) == "")))
d <- d %>% mutate(across(everything(), ~ na_if(str_trim(.x), "")))
log_change(1, "all columns", n_blank, "Blank or space-only cells set to missing", "B1")

# Add the group and flags from the data quality step (same rows, same order).
stopifnot(identical(d$case_id, flags$case_id))
d <- bind_cols(d, select(flags, questions_answered, analysis_group, starts_with("flag_")))


# 2. DUPLICATES ----------------------------------------------------------------
n_dup <- sum(d$flag_duplicate_row == "TRUE")
d <- filter(d, flag_duplicate_row == "FALSE")
log_change(2, "all columns", n_dup, "Rows identical to an earlier row removed", "A2")


# 3. IMPOSSIBLE VALUES -> MISSING ------------------------------------------------
n_age <- sum(d$flag_age_over_100 == "TRUE")
d$age[d$flag_age_over_100 == "TRUE"] <- NA
log_change(3, "age", n_age, "Ages over 100 set to missing; under 18 kept and flagged", "D1")

yod <- as_num(d$year_of_displacement)
bad_year <- !is.na(d$year_of_displacement) & (is.na(yod) | yod < 1950 | yod > 2024)
d$year_of_displacement[bad_year] <- NA
log_change(3, "year_of_displacement", sum(bad_year), "'Unknown' and years outside 1950-2024 set to missing", "A3, D3")


# 4. GROUPS -------------------------------------------------------------------------
d <- d %>% mutate(
  group = factor(analysis_group, levels = c("IDP", "Host")),
  round = str_to_title(period),

  # Cluster for confidence intervals: state + settlement name, replaced by a
  # number so that place names never leave this script.
  cluster_id = as.integer(factor(paste(state, City_Settlement))),

  sex_respondent = factor(if_else(gender %in% c("Female", "Male"), gender, NA), levels = c("Female", "Male")),

  # Disability: either the other-members variable or the respondent variable
  disability_household = case_when(disability_hh == "Yes" | disability_hh_head == "Yes" ~ "Yes",
                                   disability_hh == "No"  & disability_hh_head == "No"  ~ "No"),

  shelter_type = case_when(
    site_type %in% c("Formal Camp", "Collective Centre (in a public space or public building)",
                     "Reception Centre (where registration is taking place)",
                     "Transit Site (temporary space)", "Informal Site", "Open Area") ~ "Camps and sites",
    site_type == "IDPs staying with a host family" ~ "Host family",
    site_type == "Rented Accommodation"            ~ "Rented",
    !is.na(site_type)                              ~ "Other")
)
log_change(4, "disability_household", sum(d$disability_household %in% "Yes"),
           "Yes if disability_hh OR disability_hh_head is Yes", "E2")
log_change(4, "sex_respondent", sum(d$gender %in% "Unsure"), "'Unsure' set to missing", "A4")
log_change(4, "cluster_id", n_distinct(d$cluster_id),
           "State and settlement name replaced by a number", "G1")


# 5. INDICATORS ------------------------------------------------------------------
# Each indicator is coded 1 (in the numerator), 0 (any other answer, including
# "don't know" and "prefer not to answer") or NA (not in the denominator:
# not in the group, not eligible, or no answer recorded).
# A second column, ans_*, keeps the type of answer for the don't-know table.

indicators <- tribble(
  ~name,          ~idp_question,                ~host_question,                ~numerator,
  "ind1_food",    "access_food_now_idp",        "access_food_now_host",        "No",
  "ind2_noearner","num_earners_now_idp",        "num_earners_now_host",        "No household members were earning from work",
  "ind3_water",   "difficulties_water_now_idp", "difficulties_water_now_host", "Yes",
  "ind4_nolatrine","latrines_availability_idp", "latrines_availability_host",  "No",
  "ind5_nfi",     "urgent_nfi_need_idp",        "urgent_nfi_need_host",        "Yes",
  "ind6_nofreehealth","free_healthcare_now_idp","free_healthcare_now_host",    "No",
  "ind7_school",  "attendance_now_idp_001",     "attendance_now_host",         "Yes"
)

answer_type <- function(answer, numerator) {
  case_when(is.na(answer)                        ~ NA,
            answer == numerator                  ~ "Numerator",
            str_detect(answer, "^Don.?t know")   ~ "Don't know",
            str_detect(answer, "^Prefer not")    ~ "Prefer not to answer",
            TRUE                                 ~ "Other answer")
}

# build_indicators(): one column per indicator, for a given way of defining
# the groups. Used twice: with the published status (main analysis) and with
# the questions answered (sensitivity check).
build_indicators <- function(d, group) {
  # Indicator 7 is only for households with a confirmed child whose age is 6-14
  confirmed <- if_else(group == "IDP", d$idp_education_confirmation, d$host_education_confirmation)
  child_age <- as_num(if_else(group == "IDP", d$age_child_idp, d$age_child_host))
  school_ok <- confirmed %in% "Yes" & !(!is.na(child_age) & (child_age < 6 | child_age > 14))

  out <- tibble(.rows = nrow(d))
  for (i in seq_len(nrow(indicators))) {
    answer <- case_when(group == "IDP"  ~ d[[indicators$idp_question[i]]],
                        group == "Host" ~ d[[indicators$host_question[i]]])
    if (indicators$name[i] == "ind7_school") answer[!school_ok] <- NA
    out[[indicators$name[i]]] <- if_else(is.na(answer), NA, as.integer(answer == indicators$numerator[i]))
    out[[sub("ind", "ans", indicators$name[i])]] <- answer_type(answer, indicators$numerator[i])
  }
  out
}

d <- bind_cols(d, build_indicators(d, d$analysis_group))

n_school_age <- sum(d$flag_edu_age_outside == "TRUE")
log_change(5, "ind7_school", n_school_age, "Children aged outside 6-14 left out of the denominator", "C4")
log_change(5, "ind1-ind7", NA, "Missing answers left out of the denominator; don't know and prefer not to answer kept", "Plan rule")

# Sensitivity check: the same indicators, with the group defined by the
# questions answered. Respondents who answered neither set stay out.
group_by_questions <- case_when(d$questions_answered == "IDP questions"  ~ "IDP",
                                d$questions_answered == "Host questions" ~ "Host")
sensitivity <- bind_cols(
  tibble(state = d$state, cluster_id = d$cluster_id,
         group = factor(group_by_questions, levels = c("IDP", "Host"))),
  build_indicators(d, group_by_questions)) %>%
  filter(!is.na(group))
log_change(5, "sensitivity version", sum(group_by_questions != coalesce(d$analysis_group, "none"), na.rm = TRUE),
           "Indicators rebuilt with the group defined by the questions answered", "C2")

# Recall indicators (IDPs only): before leaving home and now
is_idp    <- d$analysis_group %in% "IDP"
no_earner <- "No household members were earning from work"
code <- function(answer, numerator) if_else(is_idp & !is.na(answer), as.integer(answer == numerator), NA)

documents <- c("birth_certificates", "marriage_certificates", "identification_cards",
               "passport", "housing_agreements")
lost_any  <- rowSums(sapply(paste0("lost_documentations_idp_", documents), function(v) d[[v]] %in% "1")) > 0
answered_docs <- !is.na(d$lost_documentations_idp)

d <- d %>% mutate(
  r1_food_pre     = code(access_food_pre_idp, "No"),
  r1_food_now     = code(access_food_now_idp, "No"),
  r2_noearner_pre = code(num_earners_pre_idp, no_earner),
  r2_noearner_now = code(num_earners_now_idp, no_earner),
  r3_lost_docs    = if_else(is_idp & answered_docs, as.integer(lost_any), NA)
)
for (doc in documents) {
  d[[paste0("r3_lost_", doc)]] <- if_else(is_idp & answered_docs,
                                          as.integer(d[[paste0("lost_documentations_idp_", doc)]] %in% "1"), NA)
}


# 6. CHECKS (the script stops if one fails) ----------------------------------------
stopifnot(
  "one line per household"            = !anyDuplicated(d$case_id),
  "indicators only 0, 1 or missing"   = all(as.matrix(d[indicators$name]) %in% c(0, 1, NA)),
  "no indicator for excluded rows"    = all(is.na(as.matrix(d[is.na(d$group), indicators$name]))),
  "recall indicators only for IDPs"   = all(is.na(d$r1_food_now[!is_idp]))
)


# 7. SAVE ---------------------------------------------------------------------------
# Only the variables the analysis needs: no free text, no place names,
# no language or origin (data protection, step 7).
analysis <- d %>%
  filter(!is.na(group)) %>%
  select(case_id, state, round, group, cluster_id, sex_respondent, disability_household, shelter_type,
         starts_with("ind"), starts_with("ans"), starts_with("r1_"), starts_with("r2_"), starts_with("r3_"))

saveRDS(analysis,    "data/clean/analysis_data.rds")
saveRDS(sensitivity, "data/clean/sensitivity_data.rds")
write_csv(cleaning_log, "output/cleaning_log.csv", na = "")

cat("Done:", nrow(analysis), "households in the analysis (",
    sum(analysis$group == "IDP"), "IDP,", sum(analysis$group == "Host"), "host )\n")
