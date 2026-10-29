# Step 3. Data quality: screen and diagnose

**Purpose.** Find out what is wrong with the data and decide what to do about each problem, **before** changing anything. This step only looks; [step 4](04-cleaning.md) applies the decisions.

**Output.** The data quality plan and issue log: each check, its result, and the decision taken, with the reason (the *Data quality plan* tab).

**Based on:** [ACAPS, *Data Cleaning* (2016)](https://alnap.org/help-library/resources/technical-brief-data-cleaning/) (screening, diagnosis, treatment, documentation) · [UNHCR, *Resources for checking and cleaning data for analysis*](https://www.unhcr.org/handbooks/assessment/sites/assessment/files/2023-11/Resources%20for%20checking%20and%20cleaning%20data%20for%20analysis.pdf) · [GSBPM 5.3 "Review and validate"](https://unece.github.io/GSBPM-5.2/#vi.-descriptions-of-phases-and-sub-processes)

This step has four parts:

| | Part | It answers |
|---|---|---|
| 1 | Plan the checks | What will we check, and which rule decides each case? |
| 2 | Screen | What is unusual in the data? |
| 3 | Diagnose | Is each problem an error, a true value, or unclear? |
| 4 | Record | What did we find and decide, and what could we not check? |

---

## 1. Plan the checks

- **Write the checks and the decision rules before running them.** For example: "ages over 100 are set to missing"; "answers given against the skip logic are set to missing". Deciding the rule in advance stops the results from steering the cleaning.
- **Focus on the variables the analysis uses.** Check every variable in the analysis plan in depth, and the rest of the file only for structure.
- **Start from the questionnaire or codebook.** The skip logic, the answer options and the universe (who was asked) are what most checks compare the data against.

## 2. Screen

Look for problems of six kinds:

| Kind | What to look for | Example |
|---|---|---|
| **Structure** | Rows, columns and IDs match the codebook; no duplicates | Repeated household IDs; identical rows |
| **Completeness** | Missing answers among people who should have answered; blank cells that are not really blank | Cells holding only spaces |
| **Routing** | Answers that follow the skip logic; denominators that match the questionnaire | An answer recorded for someone who should have skipped the question |
| **Plausibility** | Values within a believable range | An age of 2023; 20,008 children in a household |
| **Consistency** | Answers that agree with each other; derived variables that match their source questions | "Enough food" but no meals a day |
| **Comparability and classification** | Groups defined as the report says; the same answer options for each group; sample sizes that match the published report | Respondents classed in one group who answered the other group's questions |

## 3. Diagnose

For each problem found, decide which of three it is:
- **An error** (a typo, a wrong code): correct it only if the correct value is certain; otherwise set it to missing.
- **A true but unusual value**: keep it. Outliers are not errors just because they are rare.
- **Unclear**: keep it, flag it, and check whether it changes the results (a sensitivity check in [step 6](06-validation.md)).

Possible decisions: none needed · recode · set to missing · exclude from an indicator · flag only · drop the indicator.

## 4. Record

- **One line per issue in the issue log:** the check, what was found, how many rows, the decision and the reason.
- **Note what could not be checked.** For example, without interviewer IDs or interview times you cannot detect rushed or invented interviews. Say so in the limitations.
- **Bring the decisions that matter into the decision log**, especially those that change an indicator or a group.

---

## Common pitfalls

- **Correcting while checking.** If the data change during screening, nobody can tell later what the original problem was. Screen first, change in step 4.
- **Deleting outliers because they look odd.** A rare value can be true. Remove only what is clearly impossible.
- **Checking ranges but not logic.** Most serious problems are in routing, derived variables and group definitions, not in single values.
- **Trusting derived variables.** A variable built by someone else (a disability flag, an age group) must be checked against its source questions.
- **Skipping the reconciliation.** If a report was published from the same data, compare your sample sizes with its own. A difference usually reveals a definition you need to know.

**Template:** *Data quality plan* tab of the [templates workbook](../templates/survey-analysis-workflow-templates.xlsx). One way to run the checks in R: [`implementation/`](../implementation/README.md).

---

## In the Sudan example

Twenty-one checks were agreed before any were run. All six kinds found problems.

### The checks and what they found

| ID | Kind | Check | Result | Decision |
|---|---|---|---|---|
| A1 | Structure | Rows, columns, codebook | 10,735 × 1,250; codebook matches | — |
| A2 | Structure | Duplicates | No repeated IDs; 3 identical rows | Keep the first, remove the copies |
| A3 | Structure | Numbers stored as text | Year of displacement = "Unknown" in 146 rows | Set to missing |
| A4 | Structure | Survey design | One round per state; all passed screening | — |
| B1 | Completeness | Cells holding only spaces | 188,632 cells in 311 columns | Converted to missing first |
| B2 | Completeness | Missing answers among those asked | Above 10% only for school attendance (up to 45%) | Flagged |
| B3 | Completeness | Don't know / prefer not to answer | Above 5% in 3 cases | Shown separately |
| C1 | Classification | Sample by state vs the published report | Exact in 2 states; the report counts hosts by the questions they answered | Explained in validation |
| C2 | Classification | Published status vs questions answered | 515 classed as non-IDPs answered the IDP questions; 238 answered neither | Keep the published status; mismatches left out of indicators; sensitivity check |
| C3 | Routing | Skip logic for every variable used | No violations | Follow the routing |
| C4 | Routing | Education: child's age vs 6–14 | 860 IDP and 434 host children outside 6–14 | Excluded from indicator 7 |
| D1 | Plausibility | Respondent age | 57 under 18; 13 over 100 (e.g. 2023) | Over 100 set to missing; under 18 flagged |
| D2 | Plausibility | Household counts | e.g. 20,008 children aged 6–14 | Flagged only |
| D3 | Plausibility | Year of displacement | None outside range | — |
| D4 | Comparability | Answer options by group | Hosts offered 1, 2 or 3 meals; IDPs also "no regular meals" | Meals indicator dropped |
| E2 | Consistency | Derived variables vs source questions | Disability variable leaves out the respondent; older-people variable unknown for 1,081 IDP households | Disability: combine both variables; older people dropped |
| E3 | Consistency | Contradictory answers | e.g. 317 IDPs with "enough food" but one meal a day or none | Flagged and reported, not corrected |
| F | Codebook | Labels and answer lists | "Sex of household head" asked of the respondent | Reported as "sex of respondent" |
| G1 | Design | Clusters | Settlement names are free text | Use as recorded; noted in limitations |
| G2 | Design | Cell sizes by group and state | e.g. rented accommodation under 30 in two states | Not reported |
| H | Not checkable | Interviewer ID, interview times, GPS | Not in the public file | Stated in limitations |

The issue log behind this table has 46 lines: [Sudan issue log](../sudan-example/dq-issue-log.csv).

### What the checks changed

- **The groups.** The dataset's status and the published report define IDPs differently. The analysis keeps the published status and tests the alternative in step 6.
- **The disability group.** Using the derived variable alone would have found 673 households instead of 1,257.
- **The scope.** Older people and the meals indicator were dropped.
- **The education denominator.** Children outside the 6–14 age range were removed.

### What could not be checked or fixed

- Settlement names cannot be cleaned without local knowledge, so confidence intervals may be slightly too narrow.
- The likely miscoded status of 515 respondents cannot be corrected without the original records.
- Without interviewer and timing data, interview quality cannot be checked.

**Decisions recorded:** 16–19, 21–22 in the [decision log](../sudan-example/decision-log.md).
