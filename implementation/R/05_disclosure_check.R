# =============================================================================
# 05_disclosure_check.R                            Workflow step 7: Data protection
#
# Checks, before anything is published, that the outputs cannot be used to
# identify or single out households, places or small groups.
# It prints counts only: never free-text answers or place names.
#
# Input : output/tables/*.csv, data/clean/analysis_data.rds, raw survey file
# Output: output/disclosure_check.csv (check, result, status, action)
# =============================================================================

library(tidyverse)
library(readxl)

raw <- read_excel("data/raw/idmc_sudan_socioeconomicimpact_idps_06122024_10012025.xlsx",
                  sheet = "Main", col_types = "text")
a   <- readRDS("data/clean/analysis_data.rds")

checks <- tibble()
add_check <- function(check, what, result, pass, action) {
  checks <<- bind_rows(checks, tibble(check, what, result,
                                      status = if_else(pass, "Pass", "Review"), action))
}


# P1. Every published share rests on at least 30 households -----------------------
T2 <- read_csv("output/tables/T2_idp_and_host.csv", show_col_types = FALSE)
T3 <- read_csv("output/tables/T3_differences_among_idps.csv", show_col_types = FALSE)
small <- sum(T2$n_idp < 30 & !is.na(T2$pct_idp)) + sum(T2$n_host < 30 & !is.na(T2$pct_host)) +
         sum(T3$n_group < 30 & !is.na(T3$pct_group)) + sum(T3$n_other_idps < 30 & !is.na(T3$pct_other_idps))
add_check("P1", "Shares based on fewer than 30 households",
          paste(small, "shares found in tables T2 and T3"), small == 0,
          "Shares under 30 are blanked in 03_analysis.R; counts are kept")


# P2. No place below state level in the tables ---------------------------------------
# Place names of at least 3 letters (a settlement recorded as "41" is not a name);
# state names are allowed ("Sennar" is both a state and a locality).
places <- unique(str_trim(na.omit(c(raw$locality_001, raw$City_Settlement))))
places <- setdiff(places[str_detect(places, "[[:alpha:]]{3,}")], unique(raw$state))
cells  <- list.files("output/tables", full.names = TRUE) %>%
  map(~ unlist(read_csv(.x, col_types = cols(.default = "c")))) %>% unlist()
hits <- sum(cells %in% places)
add_check("P2", "Place names below state level in the tables",
          paste(hits, "place names found"), hits == 0, "Results are published by state only")


# P3. No identifying or sensitive variables in the analysis file ----------------------
sensitive <- c("City_Settlement", "locality_001", "age", "born_in_Sudan", "originally_country",
               "original_state", "What_is_the_main_language_you_", "What_is_the_main_language_you_2",
               "What_is_the_main_language_you_specify", "bad_host_relations_idp", "bad_idp_relations_host")
found <- intersect(sensitive, names(a))
add_check("P3", "Identifying or sensitive variables in the analysis file",
          paste(length(found), "of", length(sensitive), "checked variables present"), length(found) == 0,
          "The analysis file keeps only groups and indicators (02_cleaning.R)")


# P4. Rare combinations: households that share their characteristics with ------------
#     fewer than 2 others (fewer than 3 in total) could be singled out.
rare <- function(vars) a %>% add_count(across(all_of(vars)), name = "k") %>% summarise(n = sum(k < 3), pct = 100 * mean(k < 3))
p4a <- rare(c("state", "group", "sex_respondent", "disability_household", "shelter_type"))
p4b <- rare(c("state", "cluster_id", "group", "sex_respondent", "disability_household", "shelter_type"))
add_check("P4a", "Rare combinations: state, group, sex, disability, shelter",
          sprintf("%d households (%.1f%%)", p4a$n, p4a$pct), p4a$pct < 1,
          "Only state-level results are published")
add_check("P4b", "Rare combinations, adding the settlement",
          sprintf("%d households (%.1f%%)", p4b$n, p4b$pct), p4b$pct < 1,
          "Do not publish household-level data")


# P5. Settlements with very few households ------------------------------------------------
cl <- count(a, cluster_id)
add_check("P5", "Settlements with fewer than 3 households",
          sprintf("%d of %d settlements", sum(cl$n < 3), nrow(cl)), FALSE,
          "Used only for confidence intervals; never reported or mapped")


# P6. Free-text answers: count those that contain a phone-like number --------------------
text_vars <- c("What_is_the_main_language_you_specify", "originally_country",
               "bad_host_relations_idp", "bad_idp_relations_host")
answers   <- str_trim(unlist(raw[text_vars]))
answers   <- answers[!is.na(answers) & answers != ""]
phone     <- sum(str_detect(answers, "\\d{7,}"))
add_check("P6", "Free-text answers with a phone-like number",
          sprintf("%d of %d free-text answers", phone, length(answers)), phone == 0,
          "Free text is not used, published or quoted")


write_csv(checks, "output/disclosure_check.csv")
print(select(checks, check, status, result))
