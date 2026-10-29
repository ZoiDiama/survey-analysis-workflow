# Step 2. Analysis plan: indicators and rules, fixed in advance

**Purpose.** Decide which indicators answer each sub-question, how each one is calculated, how it is broken down, and which rules decide what counts as a real difference, all **before** seeing any results. A plan written after the results can be bent to fit them.

**Output.** Part 2 of the analysis plan: indicators and rules. It has an indicator table (the *Analysis plan* tab) and one reference sheet per indicator (the *Indicator sheet* tab). Part 1 is the framing from [step 1](01-framing.md).

**Based on:** [GSBPM 2 "Design"](https://unece.github.io/GSBPM-5.2/#vi.-descriptions-of-phases-and-sub-processes) · [UNHCR data analysis plan template](https://www.unhcr.org/handbooks/assessment/) · [OHCHR, *A Human Rights-Based Approach to Data*](https://www.aidsdatahub.org/resource/human-rights-based-approach-data-leaving-no-one-behind-2030-development-agenda) · [Washington Group analytic guidelines](https://www.washingtongroup-disability.com/)

The plan has five parts:

| | Part | It answers |
|---|---|---|
| 1 | The indicators | Which indicators, and why these? |
| 2 | The definitions | How exactly is each one calculated? |
| 3 | The breakdowns | For which groups and areas? |
| 4 | The rules | What counts as a real difference? |
| 5 | Tables and validation | What will the results look like, and what will they be checked against? |

---

## 1. The indicators

- **Start from the questionnaire.** Read it section by section, with the skip logic, before looking at the variables. It shows the exact wording, who was asked each question, the order of questions and any interviewer instructions. If only a codebook is available, use it, and note what it may not show: question order, instructions and the wording in the language of the interview.
- **Selection criteria.** Write the criteria first, then test every candidate indicator against them. Typical criteria:
  - *Relevant*: it measures something in the framing, ideally close to an established indicator.
  - *Comparable*: the same question was asked of each group, about the same moment.
  - *Full coverage*: it was asked of everyone in the group, not only a subgroup selected by an earlier answer.
  - *Clear*: yes/no or clearly ordered answers.
- **Fewer, better indicators.** One indicator per topic, fully checked and explained, is worth more than many that are not.
- **Keep a list of rejected candidates.** Each one with the criterion it failed. This shows the choice was not made by availability.

## 2. The definitions

For each indicator, write a reference sheet. The fields are in the *Indicator sheet* tab:
- the exact **question** and answer options, and the **variables**;
- **who was asked**, following the questionnaire's routing;
- the **numerator** (which answers count) and the **denominator** (which households are counted);
- how **"don't know" and "prefer not to answer"** are treated;
- **comparability** between groups, the **reference standard**, a **validation source** if one exists, and the **limitations**.

## 3. The breakdowns

- **Which groups and areas?** Break down every indicator by the groups the framing compares, and by area if the data cannot be pooled.
- **Use standard questions where they exist**, for example the Washington Group questions for disability and sex for sex.
- **Check that each breakdown has enough cases** before promising it. A breakdown that cannot be reported is not worth planning.
- **Plan only breakdowns you will use.** Each one should answer a sub-question.

## 4. The rules

Decide and write down, before the analysis:
- **Unit and level.** Household or person; by area or overall.
- **Minimum cell size.** Below which number a figure is not reported, and below which it is flagged.
- **Uncertainty.** How confidence intervals are calculated, and how they take the sample design (clusters, weights) into account.
- **What counts as a real difference.** Statistical significance alone is not enough in large samples, because tiny differences become "significant". Set a minimum size as well: for example, the confidence interval excludes zero **and** the difference is at least 5 percentage points.
- **Patterns, not single results.** With many comparisons, a few will look like real differences by chance. Decide how a pattern is judged (for example, "in at least half of the states").
- **Sensitivity check.** Name the one or two choices most likely to change the results, and plan to rerun the analysis with the alternative.

Thresholds such as 5 points or 30 households are the analyst's own choices, not international standards. Write them down as such, with the reason.

## 5. Tables and validation

- **Table shells.** Draw the empty tables (rows, columns, what each cell contains) before running the analysis. This fixes what will be reported.
- **Validation plan.** List the published figures you will check your results against, how close counts as "reproduced", and what you will do when a figure does not match. See [step 6](06-validation.md).

---

## Common pitfalls

- **Choosing indicators because the data are there.** Without written criteria, nobody can tell why these indicators and not others.
- **Changing a rule after seeing the results.** If a rule must change, record it in the decision log and say that it changed after the results.
- **Leaving "don't know" out of the denominator.** This inflates percentages. Keep them in and show them separately if they are frequent.
- **Calling every significant difference meaningful.** In a sample of thousands, a 1-point difference can be significant and still not matter.
- **Planning breakdowns that are too small to report.** Check cell sizes in the plan, not after the analysis.

**Templates:** *Analysis plan* and *Indicator sheet* tabs of the [templates workbook](../templates/survey-analysis-workflow-templates.xlsx). The *Analysis plan* tab builds on UNHCR's data analysis plan template.

---

## In the Sudan example

### 1. The indicators

**Source used for selection.** The data file contains no questionnaire. Candidates were read from the dataset's *Metadata* sheet, a codebook built from the questionnaire. For each of the 1,250 variables it gives the section, the exact question wording, who was asked (IDPs, hosts or all), the skip logic and the answer options. It does not give the Arabic wording or interviewer instructions.

Every indicator had to pass four criteria: **relevant** (an IASC durable-solutions criterion, close to an established indicator where possible), **comparable** (same question for IDPs and hosts, about now), **full coverage** (asked of every household in the group) and **clear** (yes/no or ordered answers). The first selection had 13 indicators; it was reduced to **7, one per topic**, so that each could be fully checked, validated and explained.

| # | Topic | % of households… | Standard |
|---|---|---|---|
| 1 | Food | not able to access enough food now | Proxy (no standard food security scale collected) |
| 2 | Livelihoods | with no member earning money from work | IASC: livelihoods |
| 3 | Water | with difficulty accessing safe drinking water now | IASC: standard of living |
| 4 | Sanitation | with no latrine where they live | JMP: "no facility" |
| 5 | Housing | in urgent need of non-food items | Shelter/NFI sector |
| 6 | Health | without free access to a health professional | IASC: access to services |
| 7 | Education | with a child aged 6–14 who attends school now | SDG 4: attendance |

**Rejected, with the criterion failed:** feeling safe and freedom of movement (not comparable, partial coverage); income amounts (not clear); overcrowding, handwashing, cost of health visits (partial coverage); satisfaction questions and food assistance (not comparable); meals per day (different answer options for each group). Safety and documentation could not be compared between IDPs and hosts at all: a finding about the questionnaire.

### 2. The definitions

Full reference sheets for the 7 indicators and the 3 recall indicators: [indicator sheets](../sudan-example/indicator-sheets.md). The common definitions:
- **Denominator:** households asked the question, with an answer recorded. "Don't know" and "prefer not to answer" stay in, and are shown separately when above 5%.
- **Unit:** the household, as reported by the person most knowledgeable about income. Education: one child aged 6–14 per household.

### 3. The breakdowns

- **SQ1:** every indicator by state and group (IDP, host).
- **SQ2:** 4 of the indicators (food, livelihoods, water, education) for three groups of IDP households: sex of the respondent; disability in the household (Washington Group cut-off); type of shelter (camps and sites, host family, rented, other).
- **Dropped at the planning stage:** older people and multiple displacement, because the data could not support them reliably or the groups were too small.

### 4. The rules

| Rule | Decision |
|---|---|
| Reporting level | By state only. No figures for all states together: no weights, and state samples differ in size and round |
| Minimum cell size | Under 30 households: not reported. 30–49: flagged "interpret with caution". Every figure shown with its n (analyst's rule; common practice) |
| Uncertainty | 95% confidence intervals that take account of clustering by settlement, labelled *indicative* because of the mixed sampling |
| Clear difference | The confidence interval excludes zero **and** the difference is at least 5 points (analyst's rule). The word "significant" is not used |
| Comparison for SQ2 | Each IDP group against all other IDPs in the same state |
| Pattern | A group is "consistently worse off" on an indicator only with a clear difference in at least half of the states where it can be reported, and in at least 4 states |
| Sensitivity check | Rerun SQ1 with respondents classified by the questions they answered instead of the published status |

### 5. Tables and validation

| Table | Content |
|---|---|
| T1 Sample | IDPs and hosts analysed and excluded, by state |
| T2 IDP and host | 7 indicators × state: IDP %, host %, difference, confidence interval, clear or not |
| T3 Differences among IDPs | Group × indicator × state, against other IDPs |
| T4 Recall | Before and now, and lost documents by type |
| T5 Don't know / prefer not to answer | Where either is above 5% |
| T6 Validation | 24 published figures checked |
| S1 Sensitivity | Verdicts by published status vs by questions answered |

**Validation plan:** 24 figures from the published report, for the six August states. Within 2 points = reproduced; 2–5 = close; more than 5 = not reproduced, then investigated.

**Decisions recorded:** 7–15, 20–22 and 25 in the [decision log](../sudan-example/decision-log.md). The filled-in plan: [Sudan analysis plan workbook](../sudan-example/analysis-plan.xlsx).
