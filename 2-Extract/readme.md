## Extract — Load Data into BigQuery

Loaded both datasets (CMHC rent, StatCan income) into Google BigQuery 
as raw tables in the `raw_cmhc` dataset.

**Tool used:** Google BigQuery + BigQuery Studio Notebook (Python)

**Steps:**
1. Pulled CMHC rent/vacancy CSV files from the `1-Get the data` folder via GitHub API
2. Pulled StatCan income CSV and metadata files the same way
3. Cleaned column names and data formatting during load
4. Loaded all tables into BigQuery dataset `raw_cmhc`

**Notebook:** [[bigquery_extract.ipynb](./bigquery_extract.ipynb)](https://github.com/Samriti5959/gta-housing-affordability/blob/main/2-Extract/Bronze_Layer_load_Data_in_Tables.ipynb)

**Status:** Done — all CMHC and StatCan tables loaded. Ready for cleaning step.
