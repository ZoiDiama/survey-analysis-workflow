# Sudan example · Decision log

Every choice that shaped the results of the [Sudan example](../README.md), in the order it was made: what was decided, what else was considered, and why. Decisions were taken before the results they affect were seen, except where the entry says the data quality check prompted them.

| # | Step | Decision | Alternatives considered | Reason |
|---|---|---|---|---|
| 1 | 1 Framing | Main question: IDPs compared with hosts, and differences among IDPs | Displacement shock (recall); pressure on hosts | Uses the questions both groups answered in the same way; the other two rest on recall or a moving baseline |
| 2 | 1 Framing | Drop social cohesion (SQ4) | Keep it | Perception questions near sensitive topics; host questions ask about IDPs, not themselves |
| 3 | 1 Framing | Report by state only, no pooled figures | Pooled figures with caveats | No weights; state samples differ in size and round |
| 4 | 1 Framing | IRIS as a reference, not in the title | Explicit IRIS framing; leave it out | Shows the standard behind the IDP–host comparison without claiming a durable-solutions measure |
| 5 | All steps | Diagnose and treat in separate scripts; rules agreed in advance; raw file never edited | Clean as you go | Keeps the evidence of each problem and makes every change reproducible |
| 6 | All steps | Validate against the published NRC report | No external validation | Tests both the data and the analysis against an independent source |
| 7 | 2 Analysis plan | Selection criteria: relevant, comparable, full coverage, clear | Choose by availability | Makes the choice explainable and repeatable; every rejected candidate is listed with its reason |
| 8 | 2 Analysis plan | Safety and documentation analysed for IDPs only | Compare with hosts anyway | Hosts were not asked comparable questions |
| 9 | 2 Analysis plan | Minimum cell size: under 30 not reported, 30–49 flagged | 50/100 | Common practice in humanitarian assessments; also protects small groups |
| 10 | 2 Analysis plan | "Don't know" and "prefer not to answer" kept in denominators, shown separately above 5% | Exclude them | Excluding them would inflate percentages |
| 11 | 2 Analysis plan | Sex reported as "sex of respondent" | "Sex of household head" (codebook label) | Questions are asked to the respondent, who may not be the head |
| 12 | 2 Analysis plan | Shelter type in 4 groups: camps and sites, host family, rented, other | 2 or 5 groups | Keeps the camp vs out-of-camp contrast and the host-family vs rented difference, with enough cases |
| 13 | 2 Analysis plan | Food assistance dropped | Keep with a caveat | Only the IDP question lists the types of assistance |
| 14 | 2 Analysis plan | A gap is clear when the 95% CI excludes zero and it is at least 5 points | Significance alone; 3 or 10 points | Avoids calling tiny gaps meaningful in large samples |
| 15 | 2 Analysis plan | SQ2: each subgroup against all other IDPs in the same state | Against hosts; pooled | The question is whether conditions differ among IDPs, within the same context |
| 16 | 3 Data quality | Classify by the published `idp_status`; respondents who answered the other group's questions, or none, left out of indicators; sensitivity check by questions answered | Classify by questions answered; follow NRC's rule | Keeps the published definition; the sensitivity check shows the effect (1 verdict out of 56 changes) |
| 17 | 3 Data quality | Answers given against the routing are set to missing | Keep and flag | Denominators must match the questionnaire (none occurred) |
| 18 | 3 Data quality | Indicators flagged when over 10% of eligible households did not answer | Other thresholds | Item non-response at that level can bias a figure |
| 19 | 3 Data quality (prompted by E2) | Disability in the household = `disability_hh` OR `disability_hh_head` | `disability_hh` alone | `disability_hh` covers other members only; the respondent is in the second variable |
| 20 | 2 Analysis plan | Reduce from 13 to 7 indicators, one per domain; SQ2 from 5 to 3 groups; SQ3 from 7 to 3 indicators | Keep all | Depth over breadth: each indicator fully checked, validated and explained |
| 21 | 2 Analysis plan (prompted by E2) | Older people dropped from SQ2 | Use with a missing share; impute | Status unknown for 1,081 IDP households even with the respondent's own age |
| 22 | 2 Analysis plan (prompted by D4) | Meals per day dropped | Redefine | Hosts and IDPs were offered different answers |
| 23 | 5 Analysis | Confidence intervals clustered by settlement name as recorded | Clean the names; ignore clustering | Uses what the data have; limitation stated (intervals may be slightly too narrow) |
| 24 | 4 Cleaning | Answers missing although asked are left out of the denominator | Count them as "no" | A blank cannot be classified |
| 25 | 5 Analysis | "Consistently worse off" needs at least 4 reportable states, as well as a clear gap in at least half of them | Half of reportable states only | Prevents a verdict from 1 of 2 states |
| 26 | 6 Validation | Show both pooled and mean-of-state shares for six-state figures | Pick the closer one per figure | Each reproduces 17 of 24; picking per figure would flatter the match |
| 27 | 7 Data protection | Publish code and state-level results only; no raw or household-level data | Publish the cleaned data; re-host the raw file | Adding the settlement makes about 1 household in 4 rare; the raw file stays with its publisher |
