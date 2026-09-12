# How to get the data

## Rent numbers (CMHC)
1. Go to CMHC's data-tables page: cmhc-schl.gc.ca → Professionals → Housing Data → Data Tables → Rental Market
2. Pick your geography (Toronto CMA) and the year you want
3. Download the Excel file it gives you — no login needed
4. Upload that Excel file into the Fabric Lakehouse (Files section)
5. Turn it into a table (a quick Dataflow Gen2 step or a short PySpark read)

## Income numbers (Statistics Canada)
1. This one has a real API, so no manual download needed: Statistics Canada's WDS API
2. In Fabric, open a Dataflow Gen2 → add a Web source → point it at the StatCan API URL
3. It pulls the JSON straight back and lands it in the Lakehouse as a table

## After that
Both tables now live in the same Lakehouse. Clean and join them, then run the SQL business questions against them — same six questions as before, just querying Fabric tables instead of local files.
