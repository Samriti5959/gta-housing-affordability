Core datasets

1. CMHC Rental Market Survey (rent data)

Source: CMHC Housing Market Information Portal — https://www03.cmhc-schl.gc.ca/hmip-pimh/
What you want: Rental Market Survey (RMS) data, historical time series, by CMA/CSD (Census Subdivision) — this lets you break out Brampton, Mississauga, Toronto, Oshawa, etc. separately rather than lumping into "Toronto CMA"
Data includes: average rent, vacancy rate, rent by bedroom type (bachelor/1BR/2BR/3BR+), by structure type (purpose-built rental vs condo)
Format: downloadable as Excel/CSV tables per year, also has a bulk data extraction tool. There's also a CMHC Open Data portal with more programmatic access (Socrata-style API)
Granularity note: CMHC reports at the "zone" level within a CMA sometimes — for municipal-level cuts you may need the CSD-level tables specifically, not just the CMA rollup

2. StatCan Census / income data

Source: Statistics Canada — https://www12.statcan.gc.ca/census-recensement/ and StatCan's data portal (statcan.gc.ca) via Table/CODR data
Census Profile (2021 Census, next one 2026 but won't be out yet) — median household income, median individual income, by Census Subdivision (matches CMHC's CSD geography — important for joining)
Also look at: Canadian Income Survey (CIS) and T1FF (Taxfiler) family income data — these update more frequently than the census and can give you income trends between census years
Access via StatCan's WDS (Web Data Service) API if you want to pull programmatically instead of manual CSV downloads — good fit for your PySpark extraction step

3. Rent growth trend supplement (optional but strong)

CMHC's historical RMS tables go back years, so you can build rent CAGR by municipality from that alone
Rentals.ca / Zumper monthly rent reports are more current (monthly cadence) if you want a "how does this compare to census-lag data" angle — but treat these as secondary/directional, not your core dataset, since methodology isn't as rigorous as CMHC
Geography alignment (the tricky part)

CMHC and StatCan don't always use identical boundary names — you'll need a CSD-to-CMA crosswalk or StatCan's Standard Geographical Classification (SGC) codes to join cleanly. StatCan publishes this correspondence file — grab it early since mismatched geography keys are the most common failure point in a join like this.



raw vs arragreative 
