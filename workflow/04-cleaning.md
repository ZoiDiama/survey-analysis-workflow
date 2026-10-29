# Step 4. Cleaning: treat and document

**Purpose.** Apply the decisions taken in [step 3](03-data-quality.md), build the analysis variables, and record every change, so that anyone can see what was done to the data and repeat it.

**Output.** A clean analysis file and the cleaning log: one line per change, linked to the data quality decision behind it (the *Cleaning log* tab).

**Based on:** [ACAPS, *Data Cleaning* (2016)](https://alnap.org/help-library/resources/technical-brief-data-cleaning/) (treatment and documentation) · [UNHCR, *Resources for checking and cleaning data for analysis*](https://www.unhcr.org/handbooks/assessment/sites/assessment/files/2023-11/Resources%20for%20checking%20and%20cleaning%20data%20for%20analysis.pdf) · [GSBPM 5.4 "Edit and impute" and 5.5 "Derive new variables"](https://unece.github.io/GSBPM-5.2/#vi.-descriptions-of-phases-and-sub-processes)

This step has four parts:

| | Part | It answers |
|---|---|---|
| 1 | Protect the raw data | Can we always go back to the original? |
| 2 | Apply the decisions | In what order are the changes made? |
| 3 | Build the analysis variables | How are groups and indicators created? |
| 4 | Document and check | Is every change recorded, and did it work? |

---

## 1. Protect the raw data

- **Never edit the raw file.** Keep it as received, read-only. All changes are made on a copy.
- **Make changes in a way that can be repeated.** A script (R, Stata, SPSS syntax) or, in Excel, a documented sequence of steps on a separate sheet. Manual edits in cells cannot be checked or repeated.

## 2. Apply the decisions

- **Apply only what the issue log decided.** If a new problem appears, go back to step 3, log it and decide; then clean.
- **Follow a fixed order**, because later changes depend on earlier ones:
  1. blank cells and spaces converted to missing;
  2. duplicates removed;
  3. impossible values set to missing;
  4. recodes (for example, combining two variables);
  5. groups and indicators built.
- **Do not guess values.** If the correct value is not certain, set it to missing. If you impute, say how and test the effect.

## 3. Build the analysis variables

- **Build each indicator exactly as its reference sheet defines it:** same numerator, same denominator, same treatment of "don't know".
- **Build the groups once**, in one place, and use them everywhere.
- **Keep the original variables.** Create new variables next to them; do not overwrite. This lets you compare before and after.
- **Prepare the alternative version** needed for the sensitivity check (for example, a different group definition), so step 6 can rerun the analysis.

## 4. Document and check

- **One line per change in the cleaning log:** the variable, the number of rows changed, the rule applied, and the issue in the data quality log that it answers.
- **Check the result.** Compare counts before and after each change; check that each indicator's denominator matches the reference sheet; tabulate each new variable against its source variables.
- **Rerun from the raw file.** Running the cleaning again from the original file must give exactly the same clean file.

---

## Common pitfalls

- **Fixing problems by hand in the spreadsheet.** The change disappears from the record, and the next person cannot repeat it.
- **Cleaning one group differently from the other.** IDP and host data must go through the same rules, or the comparison is biased.
- **Overwriting the original variable.** Once overwritten, you cannot show what changed.
- **Counting missing answers as "no".** A blank is not an answer. Leave it out of the denominator, unless the plan says otherwise.
- **Cleaning without a log.** Without a log, a reviewer cannot trust any number that follows.

**Template:** *Cleaning log* tab of the [templates workbook](../templates/survey-analysis-workflow-templates.xlsx). One way to run the cleaning in R: [`implementation/`](../implementation/README.md).

---

## In the Sudan example

The raw file from HDX was never edited. All changes were made by one script that reads the raw file and writes a clean copy, so the cleaning can be rerun at any time.

### What was changed

| Order | Variable | Rows changed | Rule | From check |
|---|---|---|---|---|
| 1 | All columns | 188,632 cells | Blank or space-only cells set to missing | B1 |
| 2 | All columns | 3 | Rows identical to an earlier row removed | A2 |
| 3 | Respondent age | 13 | Ages over 100 set to missing; under 18 kept and flagged | D1 |
| 3 | Year of displacement | 146 | "Unknown" and years outside 1950–2024 set to missing | A3, D3 |
| 4 | Disability in the household | 1,257 households with a disability | Yes if either the other-members variable or the respondent variable is Yes | E2 |
| 4 | Sex of respondent | 1 | "Unsure" set to missing (one case, too few to report) | F |
| 4 | Cluster | 1,358 | State and settlement name replaced by a number (for confidence intervals; names not published) | G1 |
| 5 | School attendance | 1,294 children | Children aged outside 6–14 left out of the denominator | C4 |
| 5 | All 7 indicators | — | Missing answers left out of the denominator; "don't know" and "prefer not to answer" kept | Plan rule |
| 5 | Sensitivity version | 520 respondents (515 non-IDPs who answered the IDP questions, and 5 IDPs in White Nile who answered only the host questions) | Indicators rebuilt with the group defined by the questions answered | C2 |

Full log: [Sudan cleaning log](../sudan-example/cleaning-log.csv). Indicators were built from the definitions in the [indicator sheets](../sudan-example/indicator-sheets.md).

### What was not changed

- **Contradictory answers** (for example, "enough food" but no meals a day) were flagged and reported, not corrected: there is no way to know which answer is right.
- **Implausible household counts** (for example, 20,008 children) were flagged only; the variable is not used in any indicator.
- **The published IDP/host status** was kept as it is; the alternative is tested in step 6.

**Decisions recorded:** 5, 17, 19 and 24 in the [decision log](../sudan-example/decision-log.md).
