# =============================================================================
# 01_data_quality.R                                  Workflow step 3: Data quality
#
# Screens and diagnoses the data. It does NOT change the data.
# Each problem found is written to the issue log with the decision agreed in
# advance. Check IDs (A1, B1, ...) match the table on the step 3 page.
#
# Input : data/raw/<survey file>.xlsx             (from HDX, never edited)
#         data/reference/nrc_sample_by_state.csv  (published report, p. 20)
# Output: output/dq_log.csv    one line per issue: check, rows, decision, reason
#         output/dq_flags.csv  one line per respondent: group and flags,
#                              used by 02_cleaning.R
#
# Run from the project folder (the folder that contains R/ and data/).
# =============================================================================

library(tidyverse)
library(readxl)

raw_file <- "data/raw/idmc_sudan_socioeconomicimpact_idps_06122024_10012025.xlsx"
dir.create("output", showWarnings = FALSE)

# Read everything as text, so that Excel cannot change types without us seeing.
d    <- read_excel(raw_file, sheet = "Main",     col_types = "text")
meta <- read_excel(raw_file, sheet = "Metadata", col_types = "text")   # codebook
nrc  <- read_csv("data/reference/nrc_sample_by_state.csv", show_col_types = FALSE)

# The issue log: each check adds a line with add_issue().
dq_log <- tibble()
add_issue <- function(check_id, check, variable, rows, issue, decision, reason) {
  dq_log <<- bind_rows(dq_log, tibble(check_id, check, variable,
                                      rows_affected = rows, issue, decision, reason))
}

as_num <- function(x) suppressWarnings(as.numeric(x))   # text that is not a number -> NA


# A. STRUCTURE ----------------------------------------------------------------

# A1. Size, and every column described in the codebook
cat("A1:", nrow(d), "rows,", ncol(d), "columns;",
    length(setdiff(names(d), meta$variable_name)), "columns not in the codebook\n")

# A2. Duplicates: the same ID twice, or identical answers under different IDs
dup_id  <- sum(duplicated(d$case_id))
dup_row <- duplicated(select(d, -case_id))          # TRUE for the 2nd copy onwards
if (dup_id > 0) add_issue("A2", "Duplicates", "case_id", dup_id,
  "Same ID on more than one row", "Keep, flag", "Answers differ: probably different interviews")
if (sum(dup_row) > 0) add_issue("A2", "Duplicates", "all columns", sum(dup_row),
  "Rows identical to an earlier row", "Keep the first, remove the copies", "Exact copies inflate n")

# A3. Numbers stored as text
for (v in c("age", "year_of_displacement", "age_child_idp", "age_child_host")) {
  x   <- str_trim(d[[v]])
  bad <- !is.na(x) & x != "" & is.na(as_num(x))
  if (sum(bad) > 0) add_issue("A3", "Numbers stored as text", v, sum(bad),
    paste("Not a number, e.g.", paste(unique(x[bad])[1:min(3, n_distinct(x[bad]))], collapse = "; ")),
    "Set to missing", "Cannot be used as an age or a year")
}

# A4. Survey design: one round per state; sex recorded as "Unsure"
print(count(d, state, period))
n_unsure <- sum(d$gender == "Unsure", na.rm = TRUE)
if (n_unsure > 0) add_issue("A4", "Survey design", "gender", n_unsure,
  "Sex recorded as 'Unsure'", "Set to missing in cleaning", "Too few to report")


# B1. BLANK CELLS (done first: every later count depends on it) ---------------

# Some cells hold only spaces (including non-breaking spaces). They look empty
# but count as answers. From here on, they are treated as missing.
is_blank   <- function(x) !is.na(x) & str_trim(x) == ""
blank_cols <- map_int(d, ~ sum(is_blank(.x)))
add_issue("B1", "Blank cells", paste(sum(blank_cols > 0), "columns"), sum(blank_cols),
  "Cells hold only spaces instead of being empty", "Convert to missing",
  "Otherwise they count as answers and distort denominators")
d <- d %>% mutate(across(everything(), ~ if_else(is_blank(.x), NA_character_, .x)))


# C. CLASSIFICATION AND ROUTING ----------------------------------------------

# Which set of questions did each respondent answer: the IDP or the host one?
# (The codebook's "universe" column says who each question is for.)
sections  <- c("Housing", "Livelihoods", "Health", "Security/Protection", "Education")
idp_qs    <- meta$variable_name[meta$section_name %in% sections & meta$universe == "idp"]
host_qs   <- meta$variable_name[meta$section_name %in% sections & meta$universe == "non_idp"]

d <- d %>% mutate(
  answered_idp  = rowSums(!is.na(across(all_of(idp_qs))))  > 0,
  answered_host = rowSums(!is.na(across(all_of(host_qs)))) > 0,
  questions_answered = case_when(answered_idp & answered_host ~ "Both",
                                 answered_idp  ~ "IDP questions",
                                 answered_host ~ "Host questions",
                                 TRUE          ~ "Neither"),
  # Agreed rule: the group is the published idp_status, as long as the
  # respondent answered that group's questions. Others are left out of indicators.
  analysis_group = case_when(idp_status == "IDP"     & answered_idp  ~ "IDP",
                             idp_status == "Non-IDP" & answered_host ~ "Host"),
  exclusion_reason = case_when(!is.na(analysis_group) ~ NA_character_,
                               questions_answered == "Neither" ~ "Answered neither set of questions",
                               TRUE ~ "Answered the other group's questions")
)

# C1. Our sample by state compared with the published report's (six August states)
c1 <- d %>% filter(state %in% nrc$state) %>%
  group_by(state) %>%
  summarise(idp_by_status  = sum(idp_status == "IDP"),
            host_by_status = sum(idp_status == "Non-IDP"),
            host_by_questions = sum(answered_host & !answered_idp)) %>%
  left_join(nrc, by = "state")
print(c1)
for (i in which(c1$idp_by_status != c1$nrc_idp | c1$host_by_status != c1$nrc_host)) {
  add_issue("C1", "Reconciliation with published report", "idp_status", NA,
    sprintf("%s: %d IDP / %d host by status; report %d / %d; hosts by questions answered %d",
            c1$state[i], c1$idp_by_status[i], c1$host_by_status[i],
            c1$nrc_idp[i], c1$nrc_host[i], c1$host_by_questions[i]),
    "Explain in validation", "The report defines the groups differently")
}

# C2. Respondents whose status does not match the questions they answered
c2 <- d %>% filter(!is.na(exclusion_reason)) %>% count(state, idp_status, exclusion_reason)
for (i in seq_len(nrow(c2))) {
  add_issue("C2", "IDP/host classification", "idp_status", c2$n[i],
    sprintf("%s: %s respondents. %s", c2$state[i], c2$idp_status[i], c2$exclusion_reason[i]),
    "Keep in the sample table, leave out of indicators; sensitivity check",
    "No answers for their own group's questions")
}
# Evidence that status may be miscoded: non-IDPs who gave a state of origin,
# a question asked only of people who left their home.
ev <- d %>% filter(idp_status == "Non-IDP", answered_idp) %>%
  group_by(state) %>% summarise(n = n(), gave_origin = sum(!is.na(original_state)))
add_issue("C2", "IDP/host classification", "original_state", sum(ev$gave_origin),
  paste("Non-IDPs who answered the IDP questions and gave a state of origin:",
        paste(sprintf("%s %d of %d", ev$state, ev$gave_origin, ev$n), collapse = "; ")),
  "Report as evidence; sensitivity check by questions answered",
  "Suggests idp_status was miscoded for these respondents")

# The variables the analysis plan uses, for each group.
plan_vars <- tribble(
  ~indicator, ~idp,                         ~host,
  "1",        "access_food_now_idp",        "access_food_now_host",
  "2",        "num_earners_now_idp",        "num_earners_now_host",
  "3",        "difficulties_water_now_idp", "difficulties_water_now_host",
  "4",        "latrines_availability_idp",  "latrines_availability_host",
  "5",        "urgent_nfi_need_idp",        "urgent_nfi_need_host",
  "6",        "free_healthcare_now_idp",    "free_healthcare_now_host",
  "7",        "attendance_now_idp_001",     "attendance_now_host",
  "R1",       "access_food_pre_idp",        NA,
  "R2",       "num_earners_pre_idp",        NA,
  "R3",       "lost_documentations_idp",    NA
) %>% pivot_longer(c(idp, host), names_to = "group", values_to = "variable") %>%
  filter(!is.na(variable)) %>%
  mutate(group = if_else(group == "idp", "IDP", "Host"))

# Who should have answered: everyone in the group, except indicator 7,
# which is asked only of households that confirmed a child aged 6-14.
should_answer <- function(indicator, group) {
  in_group <- d$analysis_group %in% group
  if (indicator != "7") return(in_group)
  confirmed <- if (group == "IDP") d$idp_education_confirmation else d$host_education_confirmation
  in_group & confirmed %in% "Yes"
}

# C3. Routing: answers from people the questionnaire should have skipped
for (i in seq_len(nrow(plan_vars))) {
  v    <- plan_vars$variable[i]
  skip <- d$analysis_group %in% plan_vars$group[i] & !should_answer(plan_vars$indicator[i], plan_vars$group[i])
  n    <- sum(skip & !is.na(d[[v]]))
  if (n > 0) add_issue("C3", "Routing", v, n, "Answered although the routing skips the question",
                       "Set to missing", "Denominators must match the questionnaire")
}

# B2 and B3. Missing answers, and "don't know" / "prefer not to answer",
# by state, among the households that should have answered
for (i in seq_len(nrow(plan_vars))) {
  v <- plan_vars$variable[i]; g <- plan_vars$group[i]
  tab <- tibble(state = d$state, x = d[[v]])[should_answer(plan_vars$indicator[i], g), ] %>%
    group_by(state) %>%
    summarise(asked = n(), missing = sum(is.na(x)),
              dk  = sum(str_detect(x, "^Don.?t know"), na.rm = TRUE),
              pna = sum(str_detect(x, "^Prefer not to answer"), na.rm = TRUE)) %>%
    mutate(pct_missing = 100 * missing / asked,
           pct_dk  = 100 * dk  / (asked - missing),
           pct_pna = 100 * pna / (asked - missing))
  for (j in which(tab$pct_missing > 10)) add_issue("B2", "Missing answers", v, tab$missing[j],
    sprintf("%s, %s: %.1f%% of %d households asked did not answer", tab$state[j], g, tab$pct_missing[j], tab$asked[j]),
    "Flag the indicator (over 10%)", "High non-response can bias the figure")
  for (j in which(tab$pct_dk > 5 | tab$pct_pna > 5)) add_issue("B3", "Don't know / prefer not to answer", v,
    tab$dk[j] + tab$pna[j],
    sprintf("%s, %s: don't know %.1f%%, prefer not to answer %.1f%%", tab$state[j], g, tab$pct_dk[j], tab$pct_pna[j]),
    "Show separately (over 5%)", "Kept in the denominator, so must be visible")
}

# C4. Education: the child's recorded age must be 6-14
age_child <- as_num(if_else(d$analysis_group %in% "IDP", d$age_child_idp, d$age_child_host))
outside   <- !is.na(age_child) & (age_child < 6 | age_child > 14)
for (g in c("IDP", "Host")) {
  n <- sum(should_answer("7", g) & outside)
  add_issue("C4", "Education eligibility", "age_child", n,
    paste(g, "households: child's recorded age outside 6-14"),
    "Exclude from indicator 7", "The indicator is defined for children aged 6-14")
}


# D. PLAUSIBILITY AND ANSWER LISTS ---------------------------------------------

# D1. Respondent age
age <- as_num(d$age)
add_issue("D1", "Plausibility", "age", sum(age > 100, na.rm = TRUE),
  "Age over 100 (some are years, e.g. 2023)", "Set to missing", "Not a plausible age")
add_issue("D1", "Plausibility", "age", sum(age < 18, na.rm = TRUE),
  "Age under 18", "Flag only", "Possible: a young person can be the main earner")

# D2. Household counts
for (v in c("num_children_0_5", "num_children_6_14", "num_children_15_17",
            "num_adults_18_64", "num_elderly_65_over")) {
  x <- as_num(d[[v]])
  n <- sum(x < 0 | x > 20 | x != round(x), na.rm = TRUE)
  if (n > 0) add_issue("D2", "Plausibility", v, n,
    paste("Negative, not whole, or above 20 (maximum", max(x, na.rm = TRUE), ")"),
    "Flag only", "Not used in any indicator; no correction without evidence")
}

# D3. Year of displacement
yod <- as_num(d$year_of_displacement)
n   <- sum(yod < 1950 | yod > 2024, na.rm = TRUE)
if (n > 0) add_issue("D3", "Plausibility", "year_of_displacement", n,
  "Year before 1950 or after 2024", "Set to missing", "Not a plausible year")

# D4. Answers that are not in the codebook's answer list (plan variables)
for (v in unique(c(plan_vars$variable, "meals_per_day_now_idp", "meals_per_day_now_host"))) {
  options <- str_split(meta$answer_values[meta$variable_name == v], fixed(" | "))[[1]]
  if (meta$type_question[meta$variable_name == v] != "single_choice") next
  bad <- !is.na(d[[v]]) & !(str_trim(d[[v]]) %in% options)
  if (sum(bad) > 0) add_issue("D4", "Answer list", v, sum(bad),
    paste("Answers not in the codebook list:", paste(unique(d[[v]][bad]), collapse = "; ")),
    "Review before use", "Indicator definitions rely on the codebook answers")
}


# E. CONSISTENCY ---------------------------------------------------------------

# E2. Derived disability variables against the Washington Group questions.
# Cut-off: at least one domain with "a lot of difficulty" or "cannot do at all".
wg <- function(who) {
  vars <- paste0("difficulty_", c("seeing", "hearing", "walking", "remembering",
                                  "selfcare", "communicating"), "_", who)
  rowSums(sapply(d[vars], function(x) x %in% c("A lot of difficulty", "Cannot do at all"))) > 0
}
match_other <- mean((d$disability_hh %in% "Yes") == wg("other"))
match_me    <- mean((d$disability_hh_head %in% "Yes") == wg("me"))
disability_any <- d$disability_hh %in% "Yes" | d$disability_hh_head %in% "Yes"
add_issue("E2", "Derived variable", "disability_hh", sum(d$disability_hh %in% "Yes"),
  sprintf("Matches the WG cut-off for OTHER members in %.1f%% of rows: it leaves out the respondent", 100 * match_other),
  sprintf("Use disability_hh OR disability_hh_head (%d households)", sum(disability_any)),
  "Otherwise households where only the respondent has a disability are missed")
add_issue("E2", "Derived variable", "disability_hh_head", sum(d$disability_hh_head %in% "Yes"),
  sprintf("Matches the WG cut-off for the RESPONDENT in %.1f%% of rows (label says household head)", 100 * match_me),
  "Document the rule", "Label does not match the question")

# Older people: the variable is missing for many IDP households
n_missing <- sum(d$analysis_group %in% "IDP" & is.na(d$elderly_living_home))
add_issue("E2", "Derived variable", "elderly_living_home", n_missing,
  "Missing for IDP households (household counts not always asked; respondent not always counted)",
  "Older people dropped from SQ2", "Too many unknowns to compare reliably")

# E3. Answers that contradict each other (flagged, never corrected)
no_earner <- "No household members were earning from work"
contradictions <- tribble(
  ~group, ~pair,                                       ~hit,
  "IDP",  "No earner, but resources are enough",       d$num_earners_now_idp %in% no_earner & d$financial_sufficiency_now_idp %in% c("Agree", "Completely agree"),
  "Host", "No earner, but resources are enough",       d$num_earners_now_host %in% no_earner & d$financial_sufficiency_now_host %in% c("Agree", "Completely agree"),
  "IDP",  "Enough food, but one meal a day or none",   d$access_food_now_idp %in% "Yes" & d$meals_per_day_now_idp %in% c("1", "No regular meals"),
  "Host", "Enough food, but one meal a day",           d$access_food_now_host %in% "Yes" & d$meals_per_day_now_host %in% "1"
)
for (i in seq_len(nrow(contradictions))) {
  n <- sum(d$analysis_group %in% contradictions$group[i] & contradictions$hit[[i]])
  add_issue("E3", "Contradictory answers", contradictions$pair[i], n,
    paste0(contradictions$group[i], ": ", contradictions$pair[i]),
    "Flag only, report", "There is no way to know which answer is right")
}


# F. CODEBOOK PROBLEMS ------------------------------------------------------------
add_issue("F", "Codebook", "meals_per_day_now_*", NA,
  "Hosts were offered 1, 2 or 3 meals; IDPs also 'No regular meals'",
  "Meals indicator dropped", "The two groups were offered different answers")
add_issue("F", "Codebook", "gender, age, disability_hh_head", NA,
  "Labelled 'of household head', but asked of the respondent",
  "Report as 'of respondent'", "The respondent may not be the head")


# G. READY FOR ANALYSIS -------------------------------------------------------------

# G1. Clusters: settlement names are free text
add_issue("G1", "Clusters", "City_Settlement", n_distinct(d$City_Settlement),
  "Settlement names are free text; spelling variants may split one settlement",
  "Cluster by name as recorded; note in limitations", "No clean settlement ID in the data")

# G2. Cell sizes for the SQ2 groups (IDPs, by state)
shelter <- case_when(
  d$site_type %in% c("Formal Camp", "Collective Centre (in a public space or public building)",
                     "Reception Centre (where registration is taking place)",
                     "Transit Site (temporary space)", "Informal Site", "Open Area") ~ "Camps and sites",
  d$site_type == "IDPs staying with a host family" ~ "Host family",
  d$site_type == "Rented Accommodation" ~ "Rented",
  !is.na(d$site_type) ~ "Other")
cells <- bind_rows(
  tibble(state = d$state, group = d$analysis_group, cell = paste("Sex:", d$gender)),
  tibble(state = d$state, group = d$analysis_group, cell = paste("Disability:", if_else(disability_any, "Yes", "No"))),
  tibble(state = d$state, group = d$analysis_group, cell = paste("Shelter:", shelter))) %>%
  filter(group == "IDP") %>% count(state, cell) %>% filter(n < 30)
add_issue("G2", "Cell sizes", "SQ2 groups", nrow(cells),
  paste("Fewer than 30 IDP households:", paste(cells$state, cells$cell, collapse = "; ")),
  "Not reported", "Minimum cell size in the analysis plan")


# H. NOT CHECKABLE ------------------------------------------------------------------
add_issue("H", "Not checkable", "interviewer, time, GPS", NA,
  "Not in the public file", "State in the limitations",
  "Usual checks for rushed or invented interviews are not possible")


# SAVE --------------------------------------------------------------------------------

dq_log <- dq_log %>% mutate(issue_no = row_number(), .before = 1)
write_csv(dq_log, "output/dq_log.csv", na = "")

# Flags for 02_cleaning.R: one line per respondent
flags <- tibble(case_id = d$case_id, state = d$state, idp_status = d$idp_status,
                questions_answered = d$questions_answered,
                analysis_group = d$analysis_group, exclusion_reason = d$exclusion_reason,
                flag_duplicate_row   = dup_row,
                flag_age_over_100    = !is.na(age) & age > 100,
                flag_age_under_18    = !is.na(age) & age < 18,
                flag_edu_age_outside = outside,
                disability_any_member = disability_any)
write_csv(flags, "output/dq_flags.csv", na = "")

cat("Done:", nrow(dq_log), "issues in output/dq_log.csv\n")
