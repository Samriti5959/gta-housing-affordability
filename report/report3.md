# Report 3: Cleaning (step 3) and SQL analysis (step 4)

**Author:** Samir · **Date:** Sep 21, 2026 · **Status:** SQL merged into `main` ([PR #2](https://github.com/Samriti5959/gta-housing-affordability/pull/2)); next step is the Power BI dashboard (Samriti)

---

## Summary

| Step | Who | Result |
|---|---|---|
| 2. Load into BigQuery | Samriti | 111 raw tables in `raw_cmhc` (project `gta-housing-508813`) |
| 3. Clean rent data | Rebal | `rent_clean`: 2,952 rent values for 22 municipalities, 1990–2025 |
| 3. Review the cleaning | Samir | ✅ `rent_clean` matches the raw data exactly |
| 3. Clean the other datasets | Samir | Vacancy, income, renter shelter cost, population, CPI: done in SQL |
| 4. SQL analysis | Samir | 11 SQL files: bronze / silver / gold layers, 5 KPIs, 6 business questions |

**Headline finding:** relative to the median household, renting outside Toronto is more affordable; Toronto has the highest 2-bedroom rent-to-income in the GTA (24.6%). But renters are under strain everywhere: 37–51% of renter households spend 30% or more of income on shelter, and the worst is in the affluent York and Halton suburbs (Richmond Hill 51%, Vaughan 50%).

---

## Part 1 — Cleaning (3-Clean)

### 1.1 What the team did (Rebal, Sep 20)

Documented in `3-Clean/Data-Cleaning- Rent - Report 1` and `Report 2`; the code is in Google Colab.

1. Connected Colab to BigQuery, treating `raw_cmhc` as read-only.
2. Inventoried the 111 raw tables and grouped them by type (rent, vacancy, StatCan data, metadata).
3. Built a municipality reference table from the table names (25 municipalities, CSD codes, regions).
4. Combined the 24 municipal rent-history tables (King has no data), fixed the mislabelled period column, and split it into year and month.
5. Kept suppressed values out rather than setting them to zero, and kept CMHC's reliability rating (a–d) on every value.
6. Reshaped the data from wide to long: one row per municipality × year × bedroom type.
7. Output: `3-Clean/Cleaned_Data/rent_clean.csv`.

### 1.2 Review

I compared `rent_clean.csv` value by value against the raw CMHC rent history.

| Check | Result |
|---|---|
| Every published raw value is in `rent_clean` | ✅ 2,952 / 2,952 |
| No extra rows | ✅ 0 |
| Rents and reliability ratings match | ✅ 0 differences |
| Suppressed values not turned into 0 | ✅ |
| King, Vaughan, East Gwillimbury have no rent history | ✅ Confirmed: CMHC suppresses them at the source |

**Verdict: the rent cleaning is correct and was used as-is for the analysis.**

### 1.3 Open questions from the cleaning reports, answered

| Question | Answer |
|---|---|
| What is the 2025 row with no municipality name? | The **Toronto CMA total**. CMHC leaves the label blank on its total row |
| Which income measure should we use? | Table **98-10-0057**: median **household** income per municipality. Table 11-10-0009 (in the reports) is family income for metro areas only |
| Why does the 2025 table have 22 rows, not 25? | It only covers the Toronto CMA. The history tables cover all 25, so using them (as Report 2 chose) is right |
| Can CMHC's zone table fill the Vaughan gap? | No. The "Richmond Hill/Vaughan/King" zone has exactly the same rents as Richmond Hill alone. Also, zone "York" is the old City of York in Toronto, not York Region |

### 1.4 Remaining cleaning, done in SQL

Only rent had been cleaned, so the other datasets were cleaned as SQL views (Part 2, silver layer):

| Dataset | Source | Cleaning done |
|---|---|---|
| Vacancy | 24 `vacancy_history_*` tables | Combined, reshaped to long like `rent_clean`, suppressed values dropped, reliability kept |
| Income | 98-10-0057 | Total households only; municipality, region, Ontario, Canada rows labelled by level |
| Renter shelter cost | 98-10-0255 | Renter and owner counts pivoted; % spending 30%+ of income |
| Population | 17-10-0155 | Municipality rows, 2001–2025 |
| Inflation | 18-10-0004 | Toronto CPI, annual averages for complete years |

### 1.5 Still open for step 3

1. **Upload `rent_clean.csv` to BigQuery** as `cleaned_cmhc.rent_clean`. The SQL depends on it.
2. **Save the Colab notebook** (`.ipynb`) into `3-Clean/` so the cleaning code is versioned with the data.
3. **Add `.md` to the two cleaning report filenames** so GitHub displays them properly.
4. **Optional:** about 64 MB of raw zip files and census metadata were committed to `main`; `extract_statcan.py` re-creates them, so they could be removed.

---

## Part 2 — SQL analysis (4-Analysis)

### 2.1 Structure: three layers in BigQuery

| Layer | Dataset | Contents |
|---|---|---|
| Bronze (raw) | `raw_cmhc` | The 111 tables from step 2, unchanged |
| Silver (clean) | `cleaned_cmhc` | `rent_clean` + 6 clean views |
| Gold (dashboard) | `gta_analytics` | 5 views for Power BI |

Everything joins on `csd_code`, StatCan's municipality code (e.g. Brampton = 3521010), so there's no name matching.

### 2.2 The SQL files

All in `4-Analysis/sql/`, run in order:

| File | Creates | Layer |
|---|---|---|
| 01 | `dim_municipality`: 25 municipalities, region, CMA | Silver |
| 02 | `vacancy_clean` | Silver |
| 03 | `income_clean` | Silver |
| 04 | `renter_shelter_clean` | Silver |
| 05 | `population_clean` | Silver |
| 06 | `cpi_annual` | Silver |
| 10 | `fact_affordability`: **main KPI table**, one row per municipality | Gold |
| 11 | `fact_rent_trend`: rent by year, year-over-year change, 2025 dollars, index | Gold |
| 12 | `region_summary`: 5 regions + Ontario | Gold |
| 13 | `dim_municipality`, `fact_vacancy_trend`: pass-throughs so Power BI reads gold only | Gold |
| 20 | The six business-question queries | — |

### 2.3 KPIs

| KPI | Definition |
|---|---|
| Rent-to-income | 2-bedroom rent × 12 ÷ median household income. **2020 is observed** (same-year rent and income); **2025 is estimated** (2020 income × Toronto CPI, +19.5%) |
| Income needed | Income at which the average 2-bedroom costs 30% of gross income |
| Renter stress | % of renter households spending 30%+ of income on shelter (2021 Census) |
| Vacancy | CMHC October vacancy rate; about 3% is balanced |
| Rent vs income growth | 2015–2020, both inflation-adjusted; plus rent growth per year 2015–2025 and 2020–2025 |

### 2.4 Findings

| # | Question | Answer |
|---|---|---|
| Q1 | Is renting outside Toronto more affordable once income is considered? | **Yes, relative to the median household.** Toronto is highest at 24.6%: its rent ($2,055) is about the same as Peel and York, but its median income is the lowest. Lowest: Halton Hills 12.1%, Scugog 13.5%, Whitby 13.7% |
| Q2 | What income does the average 2-bedroom need? | $51,800 (Brock) to $95,400 (Newmarket). Toronto needs $82,200, which is 82% of its median household income, the tightest in the GTA |
| Q3 | For whom is it unaffordable? | **Renters.** 37–51% of renter households spend 30%+ on shelter everywhere except Brock (32%); Ontario is 38.4%. Worst: Richmond Hill 51.2%, Vaughan 50.4%, Markham 47.8%, Oakville 45.8% |
| Q4 | Did rent outpace income, 2015–2020? | Yes in 12 of 19 municipalities. Biggest gaps: Georgina (+17 pts), Oakville (+14), Newmarket (+12) |
| Q5 | How fast are rents rising now? | 2.7–9.3% a year from 2020 to 2025, against 3.6% inflation; 15 of 17 beat inflation. Newmarket: $1,527 → $2,384 |
| Q6 | How much choice do renters have? | 8 of 13 municipalities with a 2025 vacancy rate are below 3%, including Toronto (2.8%). Most choice: Brampton 4.3%, Oshawa 4.0% |

**By region:** Durham has the lowest rents ($1,737 average 2-bedroom), Toronto the highest rent-to-income, and York the highest renter stress (47.2%).

### 2.5 Caveats (to show on the dashboard)

- **Median household income includes owners**, who earn more than renters. At that income every municipality looks "affordable" (under 30%), which hides the renter burden. Renter stress (Q3) is the renter-specific measure; StatCan doesn't publish renter-only income by municipality.
- **2025 income is an estimate** (2020 income carried forward with inflation).
- **2020 incomes were lifted by pandemic benefits (CERB)**, which flatters income growth in Q4.
- **2025 2-bedroom rent is published for 17 of 25 municipalities.** Missing: Caledon, East Gwillimbury, Georgina, King, Pickering (total rent only), Uxbridge, Vaughan, Whitchurch-Stouffville. Blank means "not published", never zero.
- **CMHC covers purpose-built rentals only**, not condo rentals or basement suites.

### 2.6 How it was tested

There was no BigQuery access during development, so `4-Analysis/local_test/run_local.py`:
1. rebuilds the `raw_cmhc` tables locally using the **same parsing code as the step 2 notebook**, so table and column names match BigQuery;
2. translates each SQL file from BigQuery to a local database (DuckDB) and runs it;
3. saves every view and query result to `4-Analysis/results/`.

Several numbers were also checked by hand, e.g. Toronto: $2,055 × 12 ÷ $100,400 = 24.6%.
**The SQL has not yet been run in BigQuery itself**; the first run will confirm it.

---

## Part 3 — Hand-off and next steps

**For Power BI:** connect to BigQuery and load only the `gta_analytics` dataset. Relationships and visual suggestions are in `4-Analysis/readme.md`, section "For the Power BI dashboard".

| View | Use it for |
|---|---|
| `dim_municipality` | Slicers; relationship key `csd_code` |
| `fact_affordability` | KPI cards, rankings, map |
| `fact_rent_trend` | Rent over time |
| `fact_vacancy_trend` | Vacancy over time |
| `region_summary` | Region comparison |

| # | Next step | Owner |
|---|---|---|
| 1 | Upload `rent_clean.csv` to `cleaned_cmhc.rent_clean` | BigQuery project owner |
| 2 | Run `4-Analysis/sql/` files 01 → 13 in BigQuery Studio | BigQuery project owner |
| 3 | Build the Power BI dashboard on `gta_analytics` | Samriti |
| 4 | Save the cleaning notebook in `3-Clean/` | Rebal |
| 5 | Team review of KPI definitions and caveat wording | All |
