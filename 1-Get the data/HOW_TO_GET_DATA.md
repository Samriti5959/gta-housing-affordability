# How to get the data

## Rent numbers (CMHC)
1. Go to CMHC's Housing Market Information Portal: https://www03.cmhc-schl.gc.ca/hmip-pimh/ — no login needed
2. Pick the **individual municipalities** (census subdivisions: Brampton, Mississauga, Toronto, Oakville, etc.), **not** "Toronto CMA" — the CMA number lumps every city together and hides the differences this project is about
3. Open the Rental Market Survey table for average rent by bedroom type and the year you want
4. The portal shows tables on screen — export each view (one per municipality/year) rather than expecting one bulk file
5. Upload the exported files into the Fabric Lakehouse (Files section)
6. Turn them into a table (a quick Dataflow Gen2 step or a short PySpark read)

## Income numbers (Statistics Canada)
1. This one has a real API, so no manual download needed: Statistics Canada's WDS API
2. Pull median household income at the **census subdivision** level, so it lines up with CMHC's municipality-level rent
3. In Fabric, open a Dataflow Gen2 → add a Web source → point it at the StatCan API URL
4. It pulls the JSON straight back and lands it in the Lakehouse as a table

Note: the latest census income is for 2020 (2021 Census), while rent is from the latest survey (2025). Keep that gap in mind when comparing the two.

## After that
Both tables now live in the same Lakehouse. Clean and join them, then run the SQL business questions against them — same six questions as before, just querying Fabric tables instead of local files.
