# Data sources — explained

## Core datasets

### 1. CMHC Rental Market Survey (rent data)

**Source:** CMHC Housing Market Information Portal — https://www03.cmhc-schl.gc.ca/hmip-pimh/

This is CMHC's official rental survey — average rent, by bedroom type (studio/1BR/2BR/3BR+), for purpose-built rental apartments. It's reported at two different levels of detail, and which one you pull matters:

- **Aggregate (CMA-level):** "Toronto CMA" as one lumped number. Easy to find, but useless for this project — it hides Brampton inside Toronto.
- **Raw / granular (CSD or zone level):** individual municipalities (Brampton, Mississauga, Toronto, Oakville, etc.) as separate rows, or even finer "zones" within a city (e.g., CMHC splits Brampton into "Brampton West" and "Brampton East"). This is what this project actually needs, and what's in `data/bronze/`.

**What we pulled:** average rent by bedroom type by **census subdivision** (October 2025) for 12 GTA municipalities, plus % change of rent by **zone** (finer than CSD, but only published for Toronto, Mississauga, and Brampton) for the year-over-year trend.

**Format:** the portal renders these as on-screen tables (exportable per view) rather than a bulk file — see `extract/cmhc_extract.py` for a script that automates the pull. CMHC's public tables don't require an account.

### 2. Statistics Canada — Census / income data

**Source:** 2021 Census of Population (2026 Census results aren't published yet), via the Census Profile tool and StatCan's WDS (Web Data Service) API.

Same raw-vs-aggregate split applies here:
- **Aggregate:** province (Ontario), country (Canada), or a whole census division like **Peel Region** (which bundles Brampton + Mississauga + Caledon together).
- **Raw / granular:** median household income at the **census subdivision** level — one number per municipality, which is what actually lines up with CMHC's CSD-level rent data for a real join.

**What we used:** median total household income (2020, from the 2021 Census), sourced via a municipal census bulletin that republished the CSD-level figures for Brampton and Toronto directly alongside the Ontario, Canada, and Peel Region aggregates. Where a municipality's own CSD-level number wasn't available (see gap below), the aggregate was used instead — and labelled as an aggregate, not presented as if it were that city's real number.

**For programmatic access:** StatCan's WDS API (no key required) is the right integration point for the PySpark extraction step — see `extract/statcan_extract.py`. The Census Profile *website*, by contrast, is a stateful JS app that doesn't respond reliably to a plain scripted request.

### 3. Rent trend supplement (secondary, not core)

CMHC's own historical Rental Market Survey tables go back multiple years, which is enough to build a rent growth trend without a second source. Monthly rent-report sites (Rentals.ca, Zumper, etc.) are more current but use their own listing-based methodology rather than CMHC's surveyed methodology — fine as a directional sanity check, not something to mix into the core numbers.

## Raw vs. aggregate — why it matters here

The whole point of this project is comparing *specific municipalities* against each other. An aggregate number (a whole CMA, a whole province, a whole region like Peel) is only useful when a raw, city-specific number isn't available — every time this project falls back to an aggregate, it's a real loss of precision, not a free substitute. That's why every row in `data/gold/fact_affordability.csv` carries an `income_basis` column (`exact_city_2021_census`, `peel_region_proxy`, or `ontario_provincial_benchmark`) — so anyone using the output can immediately see which numbers are the real, granular thing and which are a stand-in.

## Geography alignment (the tricky part)

CMHC and StatCan don't use identical geography labels, and this project ran into that directly:

- CMHC's zone-level rent breakdown uses its own zone names (e.g., "Brampton (West)", "Brampton (East)", "Mississauga (Northeast)") that don't exist as StatCan geographies at all — they had to be rolled up to the city level by name-matching before they could join to anything (see `notebooks/01_bronze_to_gold.py`).
- StatCan's own census subdivision names carry official-but-verbose suffixes — "Brampton, City (CY)", "Toronto, City (C)" — that had to be stripped down to a plain city name to match CMHC's CSD table.
- Even after that cleanup, one join still failed outright: Mississauga's own CSD-level income figure wasn't found in this pass, so it's carried as a labelled Peel Region proxy rather than guessed at.

**The more rigorous fix**, for a future pass: Statistics Canada publishes a Standard Geographical Classification (SGC) correspondence file that formally crosswalks CSD codes to CMA/region codes. Grabbing that up front — rather than matching on city-name strings — is the more reliable way to do this join at scale, and worth doing before extending this project to more municipalities.

## Known gap
Mississauga's own city-level median household income was not located in this pass — Statistics Canada's Census Profile web tool renders through a stateful JS app that returned 404s on direct URL fetches rather than the profile data. Peel Region's income ($107,000) was used as a labelled **proxy** for Mississauga in the gold table (`income_basis = 'peel_region_proxy'`), not presented as Mississauga's own figure. See `extract/statcan_extract.py` for the WDS API call that would resolve this properly with normal internet access.

## Interpretation caveats (read before quoting these numbers)
- Household income is **household-level**, not per-person — a city with a higher median household income may simply have larger households or more income-earners per household, not necessarily higher individual prosperity. Brampton's relatively strong affordability ratio in this dataset should be read with that in mind.
- CMHC's rent figures are for **purpose-built rental apartments** surveyed in October 2025 — they don't capture condo rentals, basement/secondary suites, or newly-built units not yet in the survey universe, all of which are common in the GTA.
- Only Toronto, Brampton, and Mississauga have zone-level detail in CMHC's public breakdown, so year-over-year rent growth could only be computed for those three; every other municipality in this dataset shows a rent snapshot only, no trend.
- The 9 municipalities without a specific income figure (Oakville, Markham, Richmond Hill, Ajax, Aurora, Milton, Newmarket, Halton Hills, Bradford West Gwillimbury) are compared to rent only, or to the Ontario provincial benchmark — not to a precise local income, so their `annual_rent_to_income_pct` is a rougher estimate than Toronto/Brampton/Mississauga's.
