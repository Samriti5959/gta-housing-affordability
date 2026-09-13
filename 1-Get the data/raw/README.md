# Raw data — GTA housing affordability

Pulled **Sep 13, 2026** by `extract_cmhc.py` and `extract_statcan.py` (in the folder above).
Re-run both scripts to refresh. Values are exactly as published, nothing cleaned or converted; cleaning happens in step 3.

**Coverage:** the 25 GTA municipalities in [`lookup_municipalities.csv`](lookup_municipalities.csv) (City of Toronto + Peel, York, Durham and Halton regions), plus region, CMA, Ontario and Canada rows where the source has them.
**Join key:** `csd_code` (StatCan census subdivision code, e.g. Brampton = `3521010`). StatCan files carry it at the end of the `DGUID` column (`2021A0005` + code).

## Files

### `lookup_municipalities.csv`
One row per municipality: `csd_code`, `municipality`, `csd_type` (C city, CY city, T town, TP township, MU municipality), `region`, `region_code`, `cma` (blank = not in a CMA).

### CMHC Rental Market Survey — `cmhc/`
Source: CMHC Housing Market Information Portal export (`https://www03.cmhc-schl.gc.ca/hmip-pimh/en/TableMapChart/ExportTable`). Purpose-built rental apartments and rows, October survey.

| File | Level | Contents |
|---|---|---|
| `rent_history.csv` | Raw (municipality) | Average rent by bedroom type, each October, 1990–2025 (Toronto from 1998) |
| `vacancy_history.csv` | Raw (municipality) | Vacancy rate % by bedroom type, same years |
| `rent_by_csd_toronto_cma_2025.csv` | Raw (municipality) | Oct 2025 rent for the 21 Toronto CMA municipalities CMHC lists; `Total` row = Toronto CMA aggregate |
| `vacancy_by_csd_toronto_cma_2025.csv` | Raw (municipality) | Same, vacancy rate |
| `rent_by_zone_toronto_cma_2025.csv` | Raw (survey zone) | Oct 2025 rent for 31 CMHC zones inside the Toronto CMA (+ `Total`) |
| `vacancy_by_zone_toronto_cma_2025.csv` | Raw (survey zone) | Same, vacancy rate |
| `files/` | — | The 54 CSVs exactly as CMHC sent them (Windows-1252, with title and notes lines) |

Columns in the reshaped files: `value` is text as published (`"1,935"`, `4.3`, or `**`), `reliability` is CMHC's code: `a` excellent, `b` very good, `c` good, `d` poor (use with caution).
`**` = suppressed (confidential or unreliable). Treat as missing, never zero.

### Statistics Canada — `statcan/`
Source: WDS API (`https://www150.statcan.gc.ca/t1/wds/rest/getFullTableDownloadCSV/<table>/en`). Each `<table>_gta.csv` keeps the original StatCan columns; `<table>_MetaData.csv` has definitions and footnotes (census ones are git-ignored because of size; run the script to get them).

| File | Table | Level | Contents | Years |
|---|---|---|---|---|
| `98100057_gta.csv` | 98-10-0057 | Raw (municipality) + regions, Ontario, Canada | Number of households; median household total and after-tax income, by household size and type | 2020 income (2015 for comparison) |
| `98100255_gta.csv` | 98-10-0255 | Raw (municipality) + regions, Ontario, Canada | Households by shelter-cost-to-income ratio (<30%, 30%+) and tenure (owner / **renter**) | 2021 |
| `17100155_gta.csv` | 17-10-0155 | Raw (municipality) + Ontario, Canada | Population, July 1 | 2001–2025 |
| `11100009_gta.csv` | 11-10-0009 | Aggregate (Toronto, Oshawa, Hamilton CMAs, Ontario, Canada) | Tax-filer (T1FF) family income, yearly | 2000–2023 |
| `18100004_gta.csv` | 18-10-0004 | Aggregate (Toronto CMA, Ontario, Canada) | CPI: All-items, Shelter, Rented accommodation, Rent | Monthly to Jul 2026 |
| `46100092_gta.csv` | 46-10-0092 | Aggregate (Toronto, Oshawa, Hamilton CMAs) | Average asking rent vs paid rent (experimental) | Monthly, Jan 2019–Apr 2026 |
| `34100133_gta.csv` | 34-10-0133 | Aggregate (Toronto, Oshawa, Hamilton CMAs) + Milton, Halton Hills, Scugog, Brock | CMHC average rents republished by StatCan | 1987–2025 |

Note: in the census tables "Toronto" appears twice (the division and the city, same numbers); tell them apart by `DGUID`.

## Coverage gaps (Oct 2025 total rent)

| Municipality | Issue |
|---|---|
| King | CMHC publishes no rental data at all |
| Caledon, Vaughan, East Gwillimbury, Georgina, Whitchurch-Stouffville, Uxbridge | Total rent suppressed (`**`) in 2025; earlier years or some bedroom types may exist |
| Scugog, Brock | History only from 2008 |

Income is available for all 25 municipalities.

## Check values

| | Median household income 2020 | Avg rent Oct 2025 (total) |
|---|---|---|
| Toronto | $84,000 | $1,916 |
| Mississauga | $102,000 | $1,917 |
| Brampton | $111,000 | $1,935 |
| Oakville | $128,000 | $2,192 |
| Oshawa | $86,000 | $1,777 |
| Burlington | $110,000 | $1,977 |
