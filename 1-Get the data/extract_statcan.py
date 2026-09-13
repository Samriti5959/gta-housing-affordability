"""Download Statistics Canada tables via the WDS API and keep only GTA rows.

For each table the full zip is saved to raw/statcan/zips/ (not committed, too big)
and a GTA-only copy of the data is written to raw/statcan/<table>_gta.csv with the
original columns and values untouched. Rows kept: the 25 GTA municipalities, the
5 regions, the Toronto / Oshawa / Hamilton CMAs, Ontario and Canada.

Usage: python3 extract_statcan.py
"""
import csv
import io
import json
import sys
import urllib.request
import zipfile
from pathlib import Path

HERE = Path(__file__).parent
RAW = HERE / "raw" / "statcan"
ZIPS = RAW / "zips"
WDS = "https://www150.statcan.gc.ca/t1/wds/rest"

TABLES = {
    "98100057": "Household income statistics by household type (2021 Census, CSD)",
    "98100255": "Shelter-cost-to-income ratio by tenure (2021 Census, CSD)",
    "11100009": "Selected income characteristics of census families (T1FF, CMA)",
    "17100155": "Population estimates, July 1, by census subdivision",
    "18100004": "Consumer Price Index, monthly, not seasonally adjusted",
    "46100092": "Asking rent and paid rent prices (experimental, CMA)",
    "34100133": "CMHC average rents for areas with a population of 10,000+",
}

# CPI has every product since 1914; keep only the housing-related series.
CPI_PRODUCTS = {"All-items", "Shelter", "Rented accommodation", "Rent"}

CMA_CODES = {"535", "532", "537"}  # Toronto, Oshawa, Hamilton


def load_lookup():
    with open(HERE / "raw" / "lookup_municipalities.csv", newline="") as f:
        rows = list(csv.DictReader(f))
    return {r["csd_code"] for r in rows}, {r["region_code"] for r in rows}


def is_gta(geo, dguid, csd_codes, region_codes):
    """Match on DGUID (<vintage><A|S><4-digit schema><code>) so names like
    'Toronto' (city vs. division) or 'Peel' (Ontario vs. New Brunswick) can't collide."""
    if geo == "Canada":
        return True
    schema, code = dguid[4:9], dguid[9:]
    return (
        (schema == "A0005" and code in csd_codes)
        or (schema == "A0003" and code in region_codes)
        or (schema == "S0503" and code in CMA_CODES)
        or (schema == "A0002" and code == "35")
    )


def download_zip(pid):
    with urllib.request.urlopen(f"{WDS}/getFullTableDownloadCSV/{pid}/en", timeout=60) as r:
        resp = json.load(r)
    if resp.get("status") != "SUCCESS":
        raise RuntimeError(f"{pid}: WDS returned {resp}")
    dest = ZIPS / f"{pid}-eng.zip"
    print(f"  downloading {resp['object']}")
    urllib.request.urlretrieve(resp["object"], dest)
    return dest


def extract(pid, zip_path, csd_codes, region_codes):
    kept = total = 0
    with zipfile.ZipFile(zip_path) as z:
        with z.open(f"{pid}.csv") as raw_csv:
            reader = csv.reader(io.TextIOWrapper(raw_csv, encoding="utf-8-sig", newline=""))
            header = next(reader)
            geo_i, dguid_i = header.index("GEO"), header.index("DGUID")
            prod_i = header.index("Products and product groups") if pid == "18100004" else None
            out_path = RAW / f"{pid}_gta.csv"
            with open(out_path, "w", newline="", encoding="utf-8") as out:
                writer = csv.writer(out)
                writer.writerow(header)
                for row in reader:
                    if len(row) <= dguid_i:
                        continue  # blank lines / footnotes at the end of census tables
                    total += 1
                    if prod_i is not None and row[prod_i] not in CPI_PRODUCTS:
                        continue
                    if is_gta(row[geo_i], row[dguid_i], csd_codes, region_codes):
                        writer.writerow(row)
                        kept += 1
        z.extract(f"{pid}_MetaData.csv", RAW)
    return kept, total


def main():
    ZIPS.mkdir(parents=True, exist_ok=True)
    csd_codes, region_codes = load_lookup()
    pids = sys.argv[1:] or list(TABLES)
    for pid in pids:
        print(f"{pid}  {TABLES[pid]}")
        zip_path = download_zip(pid)
        kept, total = extract(pid, zip_path, csd_codes, region_codes)
        print(f"  kept {kept:,} of {total:,} rows -> raw/statcan/{pid}_gta.csv")


if __name__ == "__main__":
    main()
