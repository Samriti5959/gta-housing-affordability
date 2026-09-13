# Data collection plan — Step 1 (Get the data)

**Owner:** Samir · **Due:** Sep 13 · **Hands off to:** Step 2, Extract (Samriti)

> **Status (Sep 13): done.** Scripts written and run; data is in [`raw/`](raw/README.md). The municipality list was set to the 25 in City of Toronto + Peel, York, Durham and Halton regions, so decision 1 below is settled.

Goal for today: pull every dataset the team needs as **raw files plus a repeatable script**, so Step 2 can load them into the Fabric Lakehouse without re-downloading anything by hand.

---

## 1. What "raw" vs "aggregate" means for this project

| Level | Meaning | Examples | Use it for |
|---|---|---|---|
| **Raw (granular)** | One row per municipality (census subdivision, CSD) or per CMHC survey zone | Brampton, Mississauga, Toronto (city) | The core comparison and the join |
| **Aggregate** | Many cities rolled into one number | Toronto CMA, Peel Region, Ontario, Canada | Benchmarks and context lines on the dashboard, never as a stand-in for a city |

> These are all published statistics, not survey microdata. "Raw" here means the most detailed geography published.

## 2. Verified sources (tested Sep 13, all return data, no login or API key)

### A. Rent — CMHC Housing Market Information Portal (HMIP)

The portal has a CSV export endpoint (the same one the open-source [`cmhc` R package](https://github.com/mountainMath/cmhc) uses):

`POST https://www03.cmhc-schl.gc.ca/hmip-pimh/en/TableMapChart/ExportTable`

| # | Dataset | Level | Request body | Returns |
|---|---|---|---|---|
| A1 | Average rent by bedroom type, **all Toronto CMA municipalities** CMHC lists, Oct 2025 | Raw (CSD) | `TableId=2.1.11.4&GeographyId=2270&GeographyTypeId=3&exportType=csv&ForTimePeriod.Year=2025&Frequency=Annual` | 21 municipalities + CMA total row |
| A2 | Rent history 1990–2025 for **one municipality** (loop over CSD codes) | Raw (CSD) | `TableId=2.2.11&GeographyId=<CSD code>&GeographyTypeId=4&exportType=csv` | 36 years × bedroom type |
| A3 | Vacancy rate by bedroom type, all Toronto CMA municipalities | Raw (CSD) | `TableId=2.1.1.4&GeographyId=2270&GeographyTypeId=3&exportType=csv&ForTimePeriod.Year=2025&Frequency=Annual` | 21 municipalities + total |
| A4 | Average rent by bedroom type by survey zone | Raw (zone) | `TableId=2.1.11.3&GeographyId=2270&GeographyTypeId=3&exportType=csv&ForTimePeriod.Year=2025&Frequency=Annual` | Zones within Toronto CMA |
| A5 | Average rent, Toronto CMA, 1987–2025 | Aggregate (CMA) | StatCan table `34-10-0133` (CMHC data republished via WDS) | Benchmark line |

Sample check (Oct 2025, total rent): Brampton $1,935 · Mississauga $1,917 · Toronto $1,916 · Oakville $2,192.

### B. Income — Statistics Canada WDS API

Base: `https://www150.statcan.gc.ca/t1/wds/rest/`. Whole table as CSV zip: `GET getFullTableDownloadCSV/<table id>/en`.

| # | Table | Level | What it gives | Years |
|---|---|---|---|---|
| B1 | `98-10-0057` Household income statistics by household type | Raw (CSD) + aggregates (region, Ontario, Canada) | **Median household total and after-tax income** | 2020 (and 2015) |
| B2 | `98-10-0255` Shelter-cost-to-income ratio by tenure | Raw (CSD) | **Number of renter households spending 30%+ of income on shelter**, a ready-made affordability measure | 2021 |
| B3 | `11-10-0009` Selected income characteristics of census families (T1FF, tax data) | Aggregate (Toronto CMA only) | Median family income, yearly | 2000–2023 |
| B4 | `17-10-0155` Population estimates by CSD | Raw (CSD) | Population per municipality, yearly | 2001–2025 |
| B5 | `18-10-0004` Consumer Price Index (rent + all-items, Toronto) | Aggregate (CMA) | To express 2020 income in 2025 dollars | Monthly to 2026 |
| B6 | `46-10-0092` Asking vs paid rent (experimental) | Aggregate (CMA) | Market asking rent vs what tenants pay | 2019–2026 |

Sample check (B1, median household income 2020): Brampton $111,000 · **Mississauga $102,000** · Toronto $84,000 · Peel Region $107,000.
**This closes the "known gap" in `DATA_SOURCES.md`.** Mississauga no longer needs the Peel Region proxy.

## 3. Join key: use CSD codes, not names

- CMHC's A2 request takes the **StatCan CSD code** directly (e.g. Brampton = `3521010`), and StatCan tables carry the same code.
- So the join is `csd_code` ↔ `csd_code`. The only name cleaning needed is for A1/A3, whose rows are labelled like `Brampton (CY)`; map those to codes once in a small lookup file.

| Municipality | CSD code | Region |
|---|---|---|
| Toronto | 3520005 | Toronto |
| Mississauga | 3521005 | Peel |
| Brampton | 3521010 | Peel |
| Caledon | 3521024 | Peel |

The full lookup (all municipalities) gets built as `raw/lookup_municipalities.csv` in step 4 below.

## 4. Today's steps

| # | Task | Output | Time |
|---|---|---|---|
| 1 | Agree on the municipality list (see decisions below) | `raw/lookup_municipalities.csv` (name, CSD code, region, CMA) | 30 min |
| 2 | Write `extract_cmhc.py`: pull A1, A3, A4 snapshots and loop A2 over every CSD code | `raw/cmhc/*.csv` | 1.5 h |
| 3 | Write `extract_statcan.py`: download B1–B6 zips via WDS | `raw/statcan/*.zip` | 1 h |
| 4 | Quick check: row counts, sample values match the numbers above, note suppressed `**` cells | `raw/README.md` (source URL, pull date, notes per file) | 45 min |
| 5 | Update `DATA_SOURCES.md` (Mississauga gap closed, new tables) and push on a branch | Pull request for Samriti | 30 min |

Keep the files exactly as downloaded (CMHC's reliability letters `a`–`d` and `**` included). Cleaning happens in Step 3, not here.

### Folder layout after today

```
1-Get the data/
├── DATA_COLLECTION_PLAN.md   # this file
├── extract_cmhc.py
├── extract_statcan.py
└── raw/
    ├── README.md                   # what each file is, source, pull date
    ├── lookup_municipalities.csv
    ├── cmhc/                       # A1–A4 CSVs
    └── statcan/                    # B1–B6 zips
```

## 5. Decisions for the team

1. **Which municipalities count as "GTA"?** The Toronto CMA (CMHC's area) is not the same as the GTA. The GTA also includes Oshawa, Whitby and Clarington (Oshawa CMA) and Burlington (Hamilton CMA).
   *Recommendation:* use all Toronto CMA municipalities where CMHC publishes a total rent (16 of the 22; Caledon, East Gwillimbury, Georgina, Uxbridge, Vaughan and Whitchurch-Stouffville are suppressed), plus Oshawa CMA as a stretch.
2. **Which bedroom type is the headline?** *Recommendation:* 2-bedroom (most complete coverage) with the total as a secondary view.
3. **Raw files in git or only in Fabric?** The files are small (well under 50 MB), so committing them makes the project reproducible. The big StatCan census zips may be the exception; check their size after download.

## 6. Watch-outs

- **Suppressed values (`**`)** are common for small towns and studio units. Treat them as missing, never as zero.
- **Reliability codes (`a`–`d`)** sit next to each CMHC number. Keep them; `d` means "use with caution".
- **Time gap:** census income is 2020 and rent is 2025. Use CPI (B5) or T1FF (B3) to show the effect; don't silently mix years.
- **Encoding:** CMHC CSVs are Latin-1, not UTF-8, and have title and notes lines above and below the table.
- **Undocumented endpoint:** the HMIP export is what the website itself calls, not an official API. If it breaks, the fallback is exporting the same tables by hand from the portal.
