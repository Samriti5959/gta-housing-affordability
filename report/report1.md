# Report 1: Repo setup and data collection (Step 1)

**Author:** Samir · **Date:** Sep 13, 2026 · **Status:** Step 1 done, waiting for review in [PR #1](https://github.com/Samriti5959/gta-housing-affordability/pull/1)

---

## Summary

- The repo is reorganized into one folder per pipeline step, with a project README.
- All rent and income data for the **25 GTA municipalities** is downloaded, checked and documented.
- Two scripts re-download everything in about 3 minutes (no login, no API key).
- **Mississauga's missing income figure is found** ($102,000), so no Peel Region stand-in is needed.
- Step 2 (loading into Fabric) can start as soon as PR #1 is merged.

## 1. Repo review and cleanup

**Review findings** (from reading every file):
- `HOW_TO_GET_DATA.md` said to download Toronto CMA rent, while `DATA_SOURCES.md` said the CMA number is useless and city-level data is needed.
- `DATA_SOURCES.md` referred to data files and scripts (`data/bronze/`, `data/gold/`, `extract/*.py`, `notebooks/`) that were never in the repo.
- Rent (2025) and census income (2020) are 5 years apart, and no doc mentioned it.
- The step 1 deadline was Sep 13 with no data yet.

**Fixes:**
- Folders renamed to one pattern: `1-Get the data`, `2-Extract`, `3-Clean`, `4-Analysis`, `5-Power BI dashboard`.
- Added `.gitignore` (macOS files, Python cache, secrets, large data downloads).
- Added a project `README.md`: goal, data sources, pipeline, folder map, schedule, caveats, team.
- `HOW_TO_GET_DATA.md` now says to pull city-level data, not the CMA total.

## 2. GTA definition

Agreed list: **City of Toronto + Peel, York, Durham and Halton regions**, 25 municipalities.

| Region | Municipalities |
|---|---|
| Toronto | Toronto |
| Peel | Mississauga, Brampton, Caledon |
| York | Markham, Vaughan, Richmond Hill, Newmarket, Aurora, East Gwillimbury, Georgina, King, Whitchurch-Stouffville |
| Durham | Oshawa, Whitby, Ajax, Pickering, Clarington, Scugog, Uxbridge, Brock |
| Halton | Burlington, Oakville, Milton, Halton Hills |

Note: this is wider than CMHC's Toronto CMA, which leaves out Oshawa, Whitby, Clarington (Oshawa CMA), Burlington (Hamilton CMA), Scugog and Brock.

## 3. Sources tested

Every source below was tested before being used.

| Source | Access | Result |
|---|---|---|
| CMHC Housing Market Information Portal | CSV export link behind the site's "Export" button | ✅ City-level rent and vacancy, 1990–2025 |
| StatCan WDS API | Official API, no key | ✅ All tables below |
| CMHC Excel data tables | Direct file links | ❌ Links return 404, not used |

## 4. Data collected

All files are in `1-Get the data/raw/`, described file by file in `raw/README.md`.

### Raw (city level)

| Dataset | Source | Years |
|---|---|---|
| Average rent by bedroom type, per city | CMHC | 1990–2025 |
| Vacancy rate by bedroom type, per city | CMHC | 1990–2025 |
| Rent and vacancy by city and by CMHC survey zone (Toronto CMA) | CMHC | Oct 2025 |
| Median household income (total and after-tax) | StatCan 98-10-0057 | 2020 |
| Households spending 30%+ of income on shelter, owners vs renters | StatCan 98-10-0255 | 2021 |
| Population | StatCan 17-10-0155 | 2001–2025 |

### Aggregate (context and benchmarks)

| Dataset | Source | Geography | Years |
|---|---|---|---|
| Family income from tax data (T1FF) | StatCan 11-10-0009 | Toronto, Oshawa, Hamilton CMAs, Ontario, Canada | 2000–2023 |
| Consumer Price Index: all-items, shelter, rent | StatCan 18-10-0004 | Toronto, Ontario, Canada | Monthly to Jul 2026 |
| Asking rent vs paid rent (experimental) | StatCan 46-10-0092 | Toronto, Oshawa, Hamilton CMAs | Monthly 2019–Apr 2026 |
| CMHC average rents | StatCan 34-10-0133 | CMAs and smaller centres | 1987–2025 |

### Check values

| Municipality | Median household income (2020) | Average rent, Oct 2025 |
|---|---|---|
| Toronto | $84,000 | $1,916 |
| Mississauga | $102,000 | $1,917 |
| Brampton | $111,000 | $1,935 |
| Oakville | $128,000 | $2,192 |
| Oshawa | $86,000 | $1,777 |
| Burlington | $110,000 | $1,977 |

## 5. How it was built

| File | What it does |
|---|---|
| `1-Get the data/extract_cmhc.py` | Downloads 54 CMHC tables, keeps the original files, and reshapes them into one long table per dataset |
| `1-Get the data/extract_statcan.py` | Downloads 7 StatCan tables and keeps only GTA, region, CMA, Ontario and Canada rows |
| `1-Get the data/raw/lookup_municipalities.csv` | The 25 municipalities with StatCan city code, region and CMA |
| `1-Get the data/DATA_COLLECTION_PLAN.md` | The plan for this step, with every source and request documented |

Design choices:
- **Join key is the StatCan city code (`csd_code`)**, e.g. Brampton = `3521010`. CMHC accepts the same code, so no name matching is needed.
- **Values are kept exactly as published** (e.g. `"1,935"`, `**`, reliability codes `a`–`d`). Cleaning is step 3.
- **Big downloads stay out of git.** The full StatCan zips (~50 MB) are ignored; the commit is about 6 MB.

## 6. Data gaps and caveats

- **King:** CMHC publishes no rent data.
- **Caledon, Vaughan, East Gwillimbury, Georgina, Whitchurch-Stouffville, Uxbridge:** 2025 total rent is suppressed (`**`). Treat it as missing, never zero.
- **Scugog, Brock:** rent history starts in 2008.
- **Time gap:** income is 2020, rent is 2025. CPI and tax-data income can show how much this matters.
- **Rent covers purpose-built rentals only**, not condo rentals or basement suites.
- **CMHC's export link is not an official API.** If it stops working, the fallback is exporting the same tables by hand from the portal.

## 7. Next steps

| # | Task | Owner |
|---|---|---|
| 1 | Review and merge PR #1 | Samriti |
| 2 | Load `raw/cmhc/*.csv` and `raw/statcan/*_gta.csv` into the Fabric Lakehouse | Step 2 owner |
| 3 | Decide the headline bedroom type (recommendation: 2-bedroom) | Team |
| 4 | Decide how to show cities with suppressed rent on the dashboard | Team |
| 5 | Define the business questions for SQL analysis | Team |
