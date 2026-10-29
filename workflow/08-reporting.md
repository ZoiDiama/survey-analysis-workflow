# Step 8. Reporting: the brief and the verification of key figures

**Purpose.** Give decision-makers the findings they need, in a form they can use, and make sure every number in it is right before it is released.

**Output.** A short brief (findings, charts, limitations) and a verification of key figures, recounted independently.

**Based on:** [GSBPM 7 "Disseminate"](https://unece.github.io/GSBPM-5.2/#vi.-descriptions-of-phases-and-sub-processes) · [IASC Operational Guidance on Data Responsibility](https://interagencystandingcommittee.org/operational-response/iasc-operational-guidance-data-responsibility-humanitarian-action)

This step has four parts:

| | Part | It answers |
|---|---|---|
| 1 | Know the reader | Who reads this, and what decision do they face? |
| 2 | Write the findings | What are the key messages, and how sure are we? |
| 3 | Verify the figures | Is every number in the brief right? |
| 4 | Release | Is everything ready to publish? |

---

## 1. Know the reader

- **Go back to the users in [step 1](01-framing.md).** Each finding should help one of their decisions.
- **Lead with the answer.** The key messages come first, the method last.
- **Keep it short.** Two to four pages; details in an annex or the repository.

## 2. Write the findings

- **One message per chart,** stated in the chart title.
- **Describe patterns, not single results:** "in 7 of 8 states", not the largest difference found.
- **Use neutral, precise wording.** "IDP households are more likely to…", not "displacement causes…". "Clear difference", not "significant".
- **Show how sure you are:** the number of households, confidence intervals where they help, and the flags for small groups.
- **Put the limitations where readers will see them,** not only in a footnote: who the results describe, and what they cannot show.

## 3. Verify the figures

- **Trace every number in the brief to a results table.** No number should be typed by hand.
- **Recount the key figures independently,** by a different method from the analysis code, for example a filter or pivot table in Excel on the raw file. Choose five or six figures that carry the main messages, including a count and a recall figure.
- **Rerun the analysis from a clean copy** of the raw file, following the instructions, to check that it gives the same results.
- **Record the result** in the verification table: value in the brief, recount, difference, match or check.

## 4. Release

- **Before release:** the disclosure check is passed (step 7), the decision log is complete, and every verification figure matches.
- **Credit the data source and its licence.**
- **Say how the work was done,** including any tools used, and how the results were checked.

---

## Common pitfalls

- **Writing the method before the findings.** Decision-makers stop reading before they reach the answer.
- **Typing numbers into the text by hand.** This is where most errors in reports come from.
- **Verifying with the same code that produced the numbers.** A rerun repeats any error in the code; an independent recount can catch it.
- **Hiding the limitations.** A finding read without its limits will be used beyond what it can support.

**Template:** *Verification* tab of the [templates workbook](../templates/survey-analysis-workflow-templates.xlsx). The difference and the match are calculated by formula.

---

## In the Sudan example

### The brief

A four-page brief with three charts: [Sudan brief (PDF)](../sudan-example/brief.pdf). It leads with the comparison between IDP and host households, shows work as the widest difference, and reports that no IDP group was consistently worse off. The text and every number in it are generated in R from the results tables (no number is typed by hand); the final layout was then designed from that text, using the same charts plus a chart of the recall ranges in table T4.

### Checks before release

- Every number in the brief is read from the results tables by code; none is typed by hand.
- All the scripts were rerun from a clean copy of the raw file and gave the same results.
- 17 of 24 published figures were reproduced from the data ([step 6](06-validation.md)).
- The disclosure check was passed for everything published ([step 7](07-data-protection.md)).

**Decisions recorded:** see the full [decision log](../sudan-example/decision-log.md).
