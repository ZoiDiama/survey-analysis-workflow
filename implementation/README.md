# Implementation in R

The workflow does not depend on a software package. This folder shows one way to carry out steps 3 to 8 for the Sudan example, in R. The scripts are kept short and plain: one script per step, sections named after the check or table they produce, and comments that refer back to the step pages.

| Script | Step | What it does | Output |
|---|---|---|---|
| [`01_data_quality.R`](R/01_data_quality.R) | [3 Data quality](../workflow/03-data-quality.md) | Runs the checks; changes nothing | Issue log, flags |
| [`02_cleaning.R`](R/02_cleaning.R) | [4 Cleaning](../workflow/04-cleaning.md) | Applies the decisions; builds groups and indicators | Clean file (not published), cleaning log |
| [`03_analysis.R`](R/03_analysis.R) | [5 Analysis](../workflow/05-analysis.md) | Compares groups by state, with confidence intervals and small-cell rules; sensitivity check | Tables T1–T5, S1 |
| [`04_validation.R`](R/04_validation.R) | [6 Validation](../workflow/06-validation.md) | Recalculates 24 published figures with two definitions; tests explanations | Table T6 |
| [`05_disclosure_check.R`](R/05_disclosure_check.R) | [7 Data protection](../workflow/07-data-protection.md) | Checks the outputs before publishing | Disclosure check |
| [`06_charts.R`](R/06_charts.R) | [8 Reporting](../workflow/08-reporting.md) | The three charts in the brief | Charts |
| [`reports/brief.qmd`](reports/brief.qmd) | [8 Reporting](../workflow/08-reporting.md) | The text of the brief; every number is read from the tables | Brief text (HTML and PDF). The [final brief](../sudan-example/brief.pdf) uses this text in a designed layout |

`theme_zd.R` holds the chart style. `data/reference/` holds the figures typed from the published report (sample sizes, and the 24 figures with their wording and page).

## How to run

1. Download the survey file from [HDX](https://data.humdata.org/dataset/socio-economic-impacts-of-internal-displacement-in-sudan) and save it in `data/raw/` with its original name, `idmc_sudan_socioeconomicimpact_idps_06122024_10012025.xlsx`. The data are not stored in this repository (see [step 7](../workflow/07-data-protection.md)).
2. Open R in this folder (the one that contains `R/` and `data/`) and run the scripts in order:

```r
source("R/01_data_quality.R")
source("R/02_cleaning.R")
source("R/03_analysis.R")
source("R/04_validation.R")
source("R/05_disclosure_check.R")
source("R/06_charts.R")
```

Then render the brief from the `reports/` folder: `quarto render brief.qmd` (requires Quarto 1.4 or later).

The whole run takes about a minute and a half. Requires R 4.1 or later and the packages `tidyverse`, `readxl`, `survey` and `ragg`; the charts use the Poppins font.

## How the code was written and checked

The scripts were written with the help of an AI assistant (Claude). They were checked by rerunning the full sequence from a clean copy of the raw file, and the results were compared with the figures published from the same survey ([step 6](../workflow/06-validation.md)).
