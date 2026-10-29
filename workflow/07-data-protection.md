# Step 7. Data protection: what can be published without exposing people

**Purpose.** Before anything is published, check that no output makes it easier to identify, locate or single out a household, a small area or a group at risk. This applies even when the source data are already public.

**Output.** A disclosure check (each check, its result and the action taken) and a short data protection note: what is published, what is not, and why.

**Based on:** [IASC Operational Guidance on Data Responsibility in Humanitarian Action](https://interagencystandingcommittee.org/operational-response/iasc-operational-guidance-data-responsibility-humanitarian-action) · [OCHA Centre for Humanitarian Data, guidance note series](https://www.unocha.org/publications/report/world/centre-humanitarian-data-guidance-note-series-data-responsibility-humanitarian-action), including the note on statistical disclosure control · [OHCHR, *A Human Rights-Based Approach to Data*](https://www.aidsdatahub.org/resource/human-rights-based-approach-data-leaving-no-one-behind-2030-development-agenda)

This step has four parts:

| | Part | It answers |
|---|---|---|
| 1 | Identify sensitive information | Which variables could harm people if misused? |
| 2 | Assess disclosure risk | Could a person or household be singled out from what we publish? |
| 3 | Decide what to publish | Which outputs, at which level of detail? |
| 4 | Record | What did we check and decide, and what risk remains? |

---

## 1. Identify sensitive information

- **Go through the variables, not only the outputs.** Mark those that could identify people (names, phone numbers, GPS points, small place names) and those that are sensitive in this context (ethnicity, language, religion, origin, health, legal status, protection incidents).
- **Think about the context.** A variable that is harmless in one country, such as language, can be dangerous in a conflict where identity is a factor in violence.
- **Use only what the analysis needs** (data minimisation). A sensitive variable that answers no sub-question should not be analysed.

## 2. Assess disclosure risk

- **Small cells:** any published figure based on few households can point to identifiable people. Apply the minimum cell size from the analysis plan.
- **Rare combinations:** count how many households become unique or rare when characteristics are combined (area, group, sex, disability, shelter type). Risk rises sharply as you add location.
- **Place names below the reporting level** in tables, charts or maps.
- **Free text:** open answers can contain names, phone numbers or details that identify someone.

## 3. Decide what to publish

- **Aggregates are usually safe when microdata are not.** If rare combinations are frequent, publish tables and code, not household-level data.
- **Do not re-host data you did not collect.** Link to the original source and its licence.
- **When in doubt, aggregate further or leave it out.** Do no harm comes before completeness.

## 4. Record

- **The disclosure check:** each check, the result, pass or review, and the action taken.
- **The data protection note:** what is published and what is not, the sensitive variables and how each was handled, and the risks that remain.

---

## Common pitfalls

- **"The data are already public, so anything goes."** New outputs can still combine or highlight details in ways that increase risk.
- **Checking tables but not files.** A repository with a cleaned household file can expose more than any table.
- **Showing percentages for tiny groups next to their counts.** A share of 3 households is a disclosure, even if the table looks aggregated.
- **Analysing sensitive traits because they are in the data.** Ethnicity or language by small area can do harm even with good intentions.

**Template:** *Disclosure checklist* tab of the [templates workbook](../templates/survey-analysis-workflow-templates.xlsx). One way to run the checks in R: [`implementation/`](../implementation/README.md).

---

## In the Sudan example

The data concern people displaced by an ongoing armed conflict, in which identity has been a factor in violence.

### 1. Sensitive information and how it was handled

| Information | Why it is sensitive | Use |
|---|---|---|
| Main language spoken at home | Can indicate ethnic identity | Not used, not published |
| Born in Sudan, country of origin, state of origin | Nationality, migration status; can point to conflict areas and identity | Not used, not published |
| Settlement name | Small areas; can locate households | Replaced by an anonymous number, used only for confidence intervals |
| Disability | Health information | By state only, at least 30 households per figure |
| Lost documents | Legal identity | By state only |
| Safety, looting, restrictions on movement | Protection incidents | Not analysed |

### 2. The disclosure checks

| Check | What was tested | Result | Status |
|---|---|---|---|
| P1 | Shares based on fewer than 30 households | None. An earlier version showed some next to their count; they are now blanked, counts kept | Pass |
| P2 | Place names below state level in outputs | None | Pass |
| P3 | Identifying or sensitive variables in the analysis file | None of 11 checked variables present | Pass |
| P4a | Rare combinations of state, group, sex, disability and shelter | 46 households (0.5%) | Pass: only state-level results published |
| P4b | The same, adding the settlement | **2,373 households (23.8%)** | Review: the household file is not published |
| P5 | Settlements with fewer than 3 households | 822 of 1,302 | Review: settlements never reported or mapped |
| P6 | Personal details in free-text answers (counted, never printed) | 3,799 answers; none with a phone-like number | Pass: free text not used |

### 3. What is published

| Published | Not published |
|---|---|
| Method pages, templates and code | The raw survey file (download it from HDX under its own licence) |
| Tables by state, every figure based on at least 30 households | The household-level analysis file |
| Charts by state | Settlement and locality names |
| Issue log and cleaning log (counts and rules only) | Free text, language, origin |

### 4. Remaining risks

- **The source file already contains the sensitive detail** (settlement names, languages, disability). This project adds nothing identifying, but cannot reduce what is already public.
- **Some groups cannot be reported in some states** because they fall below 30 households, for example disability in Sennar, or rented accommodation in Kassala and White Nile. This is a deliberate trade-off between detail and protection.

**Decisions recorded:** 9 and 27 in the [decision log](../sudan-example/decision-log.md).
