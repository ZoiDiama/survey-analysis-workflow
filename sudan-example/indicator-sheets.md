# Sudan example · Indicator reference sheets

Part of [step 2, analysis plan](../workflow/02-analysis-plan.md).

Seven indicators compare IDP and host households (SQ1), three groups compare IDP households with each other (SQ2), and three recall indicators describe change since leaving home (SQ3). Variable names refer to the survey codebook; `_now` stands for `_now_idp` (IDPs) and `_now_host` (hosts).

## How the indicators were selected

An indicator was kept only if it passed criteria 1–4:

| # | Criterion | Test |
|---|---|---|
| 1 | Relevant | Measures an IASC durable-solutions criterion used by IRIS to compare IDPs with non-displaced people (adequate standard of living, livelihoods); close to an established indicator where possible (JIPS Durable Solutions Indicator Library, JMP water and sanitation ladders, SDG 4 attendance) |
| 2 | Comparable | The same question asked of IDPs and hosts, about the same moment ("now") |
| 3 | Full coverage | Asked of every household in the group, not a subgroup selected by skip logic (exception: education, asked of households with a child aged 6–14, a group defined in advance) |
| 4 | Clear | Yes/no or clearly ordered answers; open money amounts with unclear reference periods fail |
| 5 | Parsimony | One indicator per domain, so each can be checked and explained in depth |
| 6 | Validation (bonus) | A figure published by NRC can be used as an external check; never a reason to select on its own |

The first selection had 13 indicators. It was reduced to 7, one per domain, to give each indicator a full quality check, validation and explanation (see the [decision log](decision-log.md)).

## The seven indicators at a glance

| # | Domain | % of households… | Standard | NRC figure checked |
|---|---|---|---|---|
| 1 | Food | not able to access enough food now | Proxy (no standard food security scale collected) | Yes |
| 2 | Livelihoods | with no member earning money from work | IASC: livelihoods | Yes |
| 3 | Water | with difficulty accessing safe drinking water now | IASC: standard of living | Yes |
| 4 | Sanitation | with no latrine where they live | JMP: no facility | Yes |
| 5 | Housing | in urgent need of non-food items | Shelter/NFI sector | Yes |
| 6 | Health | without free access to a health professional | IASC: access to services | No |
| 7 | Education | with a child aged 6–14 who attends school now | SDG 4: attendance | Yes |

All denominators: households asked the question with an answer recorded; "don't know" and "prefer not to answer" included. Disaggregation: state × group (IDP, host); SQ2 groups for indicators 1, 2, 3 and 7.

---

### 1 · Not able to access enough food now

| Field | Content |
|---|---|
| Question | "Is your household able to access enough food now?" (Yes / No / Don't know / Prefer not to answer) |
| Variables | `access_food_now_idp`, `access_food_now_host` |
| Numerator | Households answering "No" |
| Comparability | Same wording and reference period for both groups |
| Validation | NRC: 70% of IDPs and 56% of hosts, plus 4 state figures for IDPs and 1 for hosts: all reproduced within 2 points except hosts overall (close, 3 points) |
| Limitations | One self-reported question; "enough" is not defined; not comparable with IPC or food consumption scores |

### 2 · No household member earning from work

| Field | Content |
|---|---|
| Question | "How many household members earn money from work, now?" (One … Five or more / No household members were earning from work / Prefer not to answer) |
| Variables | `num_earners_now_idp`, `num_earners_now_host` |
| Numerator | "No household members were earning from work" |
| Comparability | Same question for both groups |
| Validation | NRC "complete unemployment": 56% of IDPs and 24% of hosts: both reproduced |
| Limitations | Counts earners, not income or the quality of work; household size not taken into account |

### 3 · Difficulty accessing safe drinking water now

| Field | Content |
|---|---|
| Question | "Currently, do you have any difficulties accessing safe drinking water?" |
| Variables | `difficulties_water_now_idp`, `difficulties_water_now_host` |
| Numerator | "Yes" |
| Comparability | Same question for both groups |
| Validation | NRC: 41% of IDPs and 38% of hosts (close, 3–4 points); Red Sea 83% and 64% (reproduced) |
| Limitations | "Safe" is judged by the respondent; no water testing |

### 4 · No latrine where they live

| Field | Content |
|---|---|
| Question | "Are latrines available where your household lives now?" |
| Variables | `latrines_availability_idp`, `latrines_availability_host` |
| Numerator | "No" |
| Standard | JMP sanitation ladder: "no facility" is the bottom rung |
| Validation | NRC gives two versions: 14% and 8% (p. 2), 13% and 9% (p. 14): both reproduced |
| Limitations | Availability only; shared latrines count as available |

### 5 · In urgent need of non-food items

| Field | Content |
|---|---|
| Question | "Are you in urgent need of any non-food items?" |
| Variables | `urgent_nfi_need_idp`, `urgent_nfi_need_host` |
| Numerator | "Yes" |
| Validation | NRC: 91% of IDPs (reproduced); **34% of hosts: not reproduced, the data give 83%**. Dividing host "yes" answers by all respondents gives 32.5%, which suggests a denominator error in the report (a hypothesis). Hosts in Northern: 66% published, 83% in the data (not explained) |
| Limitations | Self-reported need; which items are needed is a separate question |

### 6 · No free access to a health professional

| Field | Content |
|---|---|
| Question | "Do you currently have free access to a healthcare professional?" |
| Variables | `free_healthcare_now_idp`, `free_healthcare_now_host` |
| Numerator | "No" |
| Validation | No matching NRC figure (the report uses a composite health score) |
| Limitations | Measures cost, not distance or quality; "No" can mean paid care or no care at all |

### 7 · Child aged 6–14 attends school now

| Field | Content |
|---|---|
| Question | "Does your child go to school now?", asked about the child aged 6–14 with the most recent birthday |
| Variables | `attendance_now_idp_001`, `attendance_now_host`; eligibility `idp_education_confirmation`, `host_education_confirmation`, `age_child_idp`, `age_child_host` |
| Numerator | "Yes" |
| Denominator | Households that confirmed a child aged 6–14, excluding children whose recorded age is outside 6–14 (860 IDP and 434 host children), answer recorded |
| Validation | NRC "not attending": 75% of IDPs (close) and 61% of hosts (not reproduced, 54% in the data); White Nile 95% and 98% (reproduced) |
| Limitations | One child per household; the answer list had no option for schools being closed, which likely explains 0% attendance in Sennar |

---

## SQ2: groups compared among IDP households

| Group | Variable | Categories | Note |
|---|---|---|---|
| Sex of respondent | `gender` | Female / Male | The codebook calls it "sex of HH head", but the respondent is the person most knowledgeable about income, so it is reported as sex of respondent. One "Unsure" not reported |
| Disability in the household | `disability_hh` OR `disability_hh_head` | Yes / No | The data quality check showed `disability_hh` covers other members only and `disability_hh_head` the respondent (100% match with the Washington Group cut-off each). Combined: 1,257 households |
| Shelter type | `site_type`, grouped | Camps and sites / Host family / Rented / Other | Camps and sites = formal camp, collective centre, reception centre, transit site, informal site, open area. In Sennar all IDPs live in camps and sites |

**Dropped:** older people (household age data missing for 1,690 IDP households and not always including the respondent; 1,081 still unknown with the best available rule) and multiple displacement (small cells).

## SQ3: recall indicators (IDPs only)

| # | % of IDP households… | Variables |
|---|---|---|
| R1 | not able to access enough food, before leaving home vs now | `access_food_pre_idp`, `access_food_now_idp` |
| R2 | with no member earning from work, before vs now | `num_earners_pre_idp`, `num_earners_now_idp` |
| R3 | that lost at least one personal document while displaced, and which | `lost_documentations_idp_*` (0/1 columns) |

## Candidates that were rejected, and why

| Candidate | Failed criterion |
|---|---|
| Feeling safe; unable to move freely | 2 and 3: a change question with a different "before" for each group; movement asked only of those feeling less safe |
| Lost documents (as an IDP–host comparison) | 2: asked of IDPs only (kept as R3) |
| Income amounts in USD | 4: the questions say "each month… (estimate annually in USD)" |
| Overcrowding | 3: asked only of those less satisfied with housing because it is crowded |
| Handwashing with soap | 3: asked only of those reporting no barriers |
| Cost of a health visit | 3 and 4: asked only of those without free access; open amounts |
| Satisfaction with housing, health care, education | 2: different "before" for each group |
| Food assistance | 2: only the IDP question names the types of assistance |
| Meals per day | 2: hosts were offered 1, 2 or 3 meals; IDPs also had "no regular meals" |
| Resources not enough, not enough water, paying for water, 30+ minutes to water, tenure | 5: overlap with the kept indicator in the same domain (scope reduction) |
| Social cohesion | Out of scope (SQ4 dropped) |

Two IASC criteria, **safety** and **documentation**, cannot be compared between IDPs and hosts with this questionnaire. That is a finding about the survey design: a future round could ask both groups the same current-situation questions.
