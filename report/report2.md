# Report 2: Cleaning review and SQL analysis

**Author:** Samir · **Date:** Sep 21, 2026 · **Covers:** review of step 3 (rent cleaning) and the step 4 SQL analysis

---

## Summary

- **The rent cleaning is correct.** `rent_clean.csv` matches the raw CMHC data exactly: 2,952 of 2,952 published values, with no missing, extra or changed values.
- **Built the analysis layer in BigQuery SQL,** in bronze / silver / gold layers: 6 clean views in `cleaned_cmhc` (silver) and 6 dashboard views in `gta_analytics` (gold), plus 6 business-question queries. Everything was tested locally against an exact copy of the `raw_cmhc` tables.
- **Main finding:** relative to the median household, renting outside Toronto is more affordable, and Toronto has the highest rent-to-income (24.6%). But renters are under strain everywhere: 37–51% spend 30% or more of income on shelter. The worst is in York and Halton suburbs (Richmond Hill 51%, Vaughan 50%).

## 1. Cleaning review

### What I checked

| Check | Result |
|---|---|
| Every published value in the raw CMHC rent history is in `rent_clean` | ✅ 2,952 / 2,952 |
| No extra rows in `rent_clean` | ✅ 0 extra |
| Rent values and quality flags match the raw data | ✅ 0 differences |
| Suppressed values (`**`) kept out, not turned into 0 | ✅ |
| King, Vaughan and East Gwillimbury have no rent history | ✅ Confirmed in the raw CMHC files: CMHC suppresses them |

### Answers to open questions in Reports 1 and 2

| Open question | Answer |
|---|---|
| The unidentified 2025 row with no municipality (Report 2, section 12) | It's the **Toronto CMA total**. CMHC leaves the label blank on its total row; `1-Get the data/raw/README.md` documents it. Safe to label "Toronto CMA (total)" or drop |
| Which income measure to use (Report 1, section 12) | Not `11100009` (family income, CMA level only). Use **`98100057`**: median **household** income for each municipality. Done in `income_clean` |
| Why the 2025 CSD table has 22 rows, not 25 | It covers the Toronto CMA only; the history tables cover all 25. Report 2's choice to use the history tables is right |
| Can the zone table fill the Vaughan gap? | No. The "Richmond Hill/Vaughan/King" zone has the same rents as Richmond Hill alone. Also, zone "York" is the old City of York in Toronto, not York Region |

### Issues to fix

1. **Vacancy cleaning wasn't done yet.** I built it as a SQL view (`cleaned_cmhc.vacancy_clean`) with the same shape as `rent_clean`. If the Colab version gets finished, compare the two.
2. **`rent_clean` isn't in BigQuery yet** (Report 2 plans `cleaned_cmhc`). The SQL expects `cleaned_cmhc.rent_clean`; please upload the CSV there.
3. **The cleaning code lives only in Colab.** Export the notebook (`.ipynb`) into `3-Clean/` so it's versioned with the data.
4. **The two cleaning reports have no `.md` extension**, so GitHub shows them as plain text. Renaming them to `.md` fixes that.
5. **About 64 MB of raw zips and census metadata were committed to `main`** after the `.gitignore` lines were removed. They're re-created by `extract_statcan.py`, so they don't need to be in git. Low priority, but they make every clone slower.

## 2. SQL analysis

All SQL is in [`4-Analysis/sql/`](../4-Analysis/sql/); the model, KPI definitions and run steps are in [`4-Analysis/readme.md`](../4-Analysis/readme.md).

| Layer | Dataset | Views |
|---|---|---|
| Bronze | `raw_cmhc` | The raw tables from step 2 (unchanged) |
| Silver | `cleaned_cmhc` | `rent_clean` (team) + `dim_municipality`, `vacancy_clean`, `income_clean`, `renter_shelter_clean`, `population_clean`, `cpi_annual` |
| Gold | `gta_analytics` | `fact_affordability` (main KPI table), `fact_rent_trend`, `fact_vacancy_trend`, `region_summary`, `dim_municipality`. Power BI reads only this |

### KPIs

1. **Rent-to-income:** observed 2020 (same-year rent and income) and estimated 2025 (income carried forward with CPI).
2. **Income needed** for the average 2-bedroom at 30% of income.
3. **Renter stress:** share of renter households spending 30%+ on shelter (2021).
4. **Vacancy rate** (2025).
5. **Rent growth vs income growth**, inflation-adjusted.

### Findings

| # | Question | Answer |
|---|---|---|
| Q1 | Is renting outside Toronto more affordable once income is considered? | Yes, relative to the median household. Toronto's 2-bedroom rent-to-income is the highest (24.6%); Halton Hills (12.1%), Scugog (13.5%) and Whitby (13.7%) are lowest |
| Q2 | What income does the average 2-bedroom need? | $51,800 (Brock) to $95,400 (Newmarket). Toronto needs $82,200, which is 82% of its median household income |
| Q3 | For whom is it unaffordable? | Renters. 37–51% of renter households spend 30%+ on shelter everywhere except Brock (32%). The worst: Richmond Hill 51.2%, Vaughan 50.4%, Markham 47.8%, Oakville 45.8% |
| Q4 | Did rent outpace income, 2015–2020? | In 12 of 19 municipalities. Biggest gaps: Georgina, Oakville, Newmarket |
| Q5 | How fast are rents rising now? | 2.7–9.3% a year from 2020–2025, vs 3.6% inflation. Newmarket is the outlier: $1,527 → $2,384 |
| Q6 | How much choice do renters have? | 8 of 13 municipalities with a 2025 vacancy rate are below 3%, including Toronto (2.8%). Brampton (4.3%) has the most choice |

### Caveats to show on the dashboard

- Median household income includes owners, so rent-to-income understates the burden on renters. Renter stress is the renter-specific measure.
- 2025 income is an estimate (2020 income × CPI).
- 2020 incomes were lifted by pandemic benefits (CERB).
- 2025 2-bedroom rent is published for 17 of 25 municipalities.

## 3. How it was tested

No BigQuery access was needed. `4-Analysis/local_test/run_local.py`:
1. rebuilds the `raw_cmhc` tables in DuckDB using the **same parsing functions as the step 2 notebook**, so table and column names match BigQuery exactly;
2. translates each SQL file from BigQuery to DuckDB syntax and runs it;
3. writes every view and query result to `4-Analysis/results/`.

Several results were also checked by hand. For example, Toronto: $2,055 × 12 ÷ $100,400 = 24.6%.

## 4. Next steps

| # | Task | Owner |
|---|---|---|
| 1 | Upload `rent_clean.csv` to `cleaned_cmhc.rent_clean` | Cleaning owner |
| 2 | Run `4-Analysis/sql/` 01 → 20 in BigQuery Studio | Samir / Samriti |
| 3 | Review the KPI definitions and the 30% / 40% band thresholds | Team |
| 4 | Build the dashboard on the `gta_analytics` views (see `4-Analysis/readme.md`, "For the Power BI dashboard") | Samriti |
