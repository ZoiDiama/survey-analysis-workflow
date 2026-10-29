# Step 1. Framing: the question before the data

**Purpose.** Before opening the data, decide what you are asking, what the data can support, who the answer is for and which standard applies. Every later step follows from these choices.

**Output.** Part 1 of the analysis plan: the framing (one to two pages). Part 2, the indicators and rules, is written in [step 2](02-analysis-plan.md).

**Based on:** [GSBPM 1 "Specify needs"](https://unece.github.io/GSBPM-5.2/#vi.-descriptions-of-phases-and-sub-processes) · [IRIS](https://egrisstats.org/recommendations/international-recommendations-on-idp-statistics-iris/) · [IASC Framework on Durable Solutions](https://interagencystandingcommittee.org/other/iasc-framework-durable-solutions-internally-displaced-persons) · [Protection Analytical Framework](https://www.globalprotectioncluster.org/index.php/field-support/Protection-Analytical-Framework)

The framing has four parts:

| | Part | It answers |
|---|---|---|
| 1 | The question | What exactly are we asking? |
| 2 | The data | What can this survey support, and what can it not? |
| 3 | The users | Who needs the answer, and for which decision? |
| 4 | The reference | Which standard does the analysis follow? |

---

## 1. The question

- **Main question.** Write it in one sentence. It should be answerable with figures from the survey, such as a share of households or a difference between two groups. "What is life like for displaced people?" is a topic; "How do displaced households compare with host households on food, work and services?" is a question.
- **Sub-questions.** Break the main question into two to four sub-questions. For each, say which population it covers and at what level (households or people; by area or overall). Move from broad to detailed: question → sub-questions → the data each one needs.
- **Options considered.** Write down the other ways you could frame the question and why you are not choosing them.

## 2. The data

- **Who, where, when, how.** Who was interviewed, in which areas, when, and how were they selected? Are there weights? Without weights or a probability sample, results describe the people surveyed, not the whole population.
- **Same question for each group?** Check, question by question, that each group was asked the same wording, with the same answer options, about the same moment. Questions about change are the usual problem: each group may be comparing with a different "before".
- **Who answered?** The household head, any adult, or the person who knows most about income? This decides whether results are about households or about individual people.
- **How old are the data?** If the data are a year old when the results are read, the output is an evidence base and a method, not a picture of current needs.
- **What can the data not answer?** For example: national figures, causes, individuals within the household, or standard measures that were not collected.

## 3. The users

- **Who will use the answer, and which decision will it inform?** List each user with one decision. If a user has no decision, the question may not be needed.

## 4. The reference

- **Is there a standard for this kind of comparison?** For displaced people, IRIS recommends comparing them with a non-displaced group in the same place, and the IASC Framework gives the criteria to compare them on. Say whether you follow the standard fully or use it as a reference.

---

## Common pitfalls

- **Starting from the variables, not the question.** A long list of indicators is not a question.
- **Promising national figures from an unweighted sample.** State once, early, which level the results describe.
- **Reading a gap as a cause.** If displaced households are 30 points more likely than hosts to have no one earning, that does not prove displacement caused it. Displaced households may also differ in where they live, in household make-up, or in who was reachable for an interview. Write "displaced households are more likely to have no earner", not "displacement leaves households without an earner".
- **Taking over the framing of a published report.** If a report exists, it is more useful as an independent check (step 6) than as your question.

**Template:** none for the framing itself. Record the framing decisions in the *Decision log* tab of the [templates workbook](../templates/survey-analysis-workflow-templates.xlsx).

---

## In the Sudan example

The data are described in the [README](../README.md#about-this-project): 10,735 displaced and host households in eight states, 2024.

### 1. The question

> **How do the current living conditions of displaced (IDP) households in the surveyed sites compare with those of host households in the same states, and do conditions differ between groups of IDP households?**

| Sub-question | What it asks | What is measured | Who |
|---|---|---|---|
| SQ1 | How do IDP and host households compare on food, livelihoods, water, sanitation, housing, health and education? | Share of households on each of 7 indicators; difference between IDPs and hosts | IDPs and hosts, by state |
| SQ2 | Among IDP households, do conditions differ by sex of the respondent, disability in the household or type of shelter? | Share of IDP households in each group on 4 of the indicators; difference from other IDPs in the same state | IDPs, by state |
| SQ3 | What share of IDP households report not having enough food, or no one earning, before they left home and now; and what share lost personal documents while displaced? | Share before and now (as recalled by the respondent); share with at least one lost document, by type | IDPs only, by state |

**Options considered**

| Option | Why | Decision |
|---|---|---|
| **A. IDPs compared with hosts, and differences among IDPs** | Uses the questions both groups were asked in the same way | **Chosen** |
| B. The displacement shock (IDPs, before vs now) | Rests entirely on recall, with no comparison group | Kept only as SQ3 |
| C. Pressure on host communities | The angle of the published report; hosts compare with a moving "before" | Rejected; the report is used for validation instead |
| Social cohesion (trust, relations) | Sensitive perception questions; hosts were asked about IDPs, not themselves | Dropped |

### 2. The data

- **Who, where, when, how.** 5,968 IDP and 4,767 host households in eight states, interviewed in August and November 2024. Sampling mixed systematic random, random-walk and respondent-driven methods. **There are no weights**, so results are reported **by state only**, never as a national figure.
- **Same question for each group?** Questions about the current situation were asked the same way. Questions about change were not: IDPs were asked "compared to before you left your home", hosts "compared to before displaced people arrived". The analysis therefore uses current-situation questions only.
- **Who answered?** The person most knowledgeable about household income, so all indicators are about households, not individuals.
- **How old are the data?** August–November 2024. The project is an evidence base and a reusable method, not a statement of current needs.
- **What the data cannot answer.** Figures for Sudan or for all IDPs; causes of any differences; conditions of individual household members; standard food security scores (only simple food questions were asked).

### 3. The users

| User | Decision it informs |
|---|---|
| Humanitarian sector coordination (food security, water and sanitation, shelter, protection) | Which sectors and groups to prioritise; whether shelter type matters |
| UN agencies working on displacement and protection | Targeting vulnerable groups; follow-up on lost documents |
| Durable-solutions and development actors | Whether IDPs are moving towards parity with hosts, and whether support should reach hosts too |
| Human-rights monitors | Evidence of unequal access to an adequate standard of living, health and education |

### 4. The reference

The comparison of IDPs with host households follows IRIS, and the indicators are grouped by the IASC criteria for durable solutions. IRIS is used as a reference, not a claim: **the project is not a durable-solutions measure**, because the data are not representative.

**Decisions recorded:** 1–4 in the [decision log](../sudan-example/decision-log.md).
