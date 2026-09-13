"""Download CMHC Rental Market Survey tables from the Housing Market Information Portal.

Uses the portal's CSV export endpoint (the same one the website's "Export" button and the
open-source `cmhc` R package call). No login or key needed.

Outputs
  raw/cmhc/files/*.csv  exactly as downloaded (Windows-1252, with CMHC's title/notes lines)
  raw/cmhc/*.csv        the same values reshaped into one long table per dataset, ready to load:
                        values are kept as text ("1,935", "**") with CMHC's reliability code alongside

Usage: python3 extract_cmhc.py
"""
import csv
import io
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path

HERE = Path(__file__).parent
RAW = HERE / "raw" / "cmhc"
FILES = RAW / "files"
EXPORT_URL = "https://www03.cmhc-schl.gc.ca/hmip-pimh/en/TableMapChart/ExportTable"
TORONTO_CMA = "2270"  # CMHC's own id for the Toronto CMA

# Per-municipality history (GeographyTypeId 4 = census subdivision, id = StatCan CSD code)
HISTORY_TABLES = {
    "rent_history": "2.2.11",     # Historical average rents by bedroom type
    "vacancy_history": "2.2.1",   # Historical vacancy rates by bedroom type
}

# Latest-year snapshots for the Toronto CMA broken down by municipality / survey zone
SNAPSHOT_YEAR = 2025
SNAPSHOT_TABLES = {
    "rent_by_csd_toronto_cma": "2.1.11.4",
    "vacancy_by_csd_toronto_cma": "2.1.1.4",
    "rent_by_zone_toronto_cma": "2.1.11.3",
    "vacancy_by_zone_toronto_cma": "2.1.1.3",
}


def fetch(params, save_to):
    """Download one export, save the bytes untouched, and return the decoded text."""
    body = urllib.parse.urlencode({**params, "exportType": "csv"}).encode()
    with urllib.request.urlopen(urllib.request.Request(EXPORT_URL, data=body), timeout=60) as r:
        data = r.read()
    text = data.decode("cp1252", errors="replace")
    if text.lstrip().startswith("<"):
        raise RuntimeError(f"CMHC returned an HTML error page for {params}")
    save_to.write_bytes(data)
    time.sleep(0.5)  # be polite to the portal
    return text


def parse(text):
    """Yield (row_label, column, value, reliability) from a CMHC export.

    Layout: title line, period line, header ",Studio,,1 Bedroom,,...", data rows of
    label followed by (value, reliability) pairs, then a blank line and notes."""
    lines = text.splitlines()
    start = next((i for i, l in enumerate(lines) if l.startswith(",")), None)
    if start is None:
        return  # no table, e.g. a municipality with no rental universe
    header = next(csv.reader([lines[start]]))
    columns = [(i, header[i]) for i in range(1, len(header), 2) if header[i]]
    for line in lines[start + 1:]:
        if not line.strip():
            break
        row = next(csv.reader([line]))
        label = row[0].strip() or "Total"
        for i, col in columns:
            value = row[i].strip() if i < len(row) else ""
            reliability = row[i + 1].strip() if i + 1 < len(row) else ""
            yield label, col, value, reliability


def slug(name):
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def main():
    FILES.mkdir(parents=True, exist_ok=True)
    with open(HERE / "raw" / "lookup_municipalities.csv", newline="") as f:
        municipalities = list(csv.DictReader(f))

    for name, table_id in HISTORY_TABLES.items():
        out_rows = []
        for m in municipalities:
            text = fetch({"TableId": table_id, "GeographyId": m["csd_code"], "GeographyTypeId": "4"},
                         FILES / f"{name}_{m['csd_code']}_{slug(m['municipality'])}.csv")
            rows = list(parse(text))
            print(f"{name:<16} {m['municipality']:<24} {len(rows) // 5:>3} years")
            for period, bedroom, value, rel in rows:
                out_rows.append([m["csd_code"], m["municipality"], period, bedroom, value, rel])
        write(RAW / f"{name}.csv",
              ["csd_code", "municipality", "survey_period", "bedroom_type", "value", "reliability"], out_rows)

    for name, table_id in SNAPSHOT_TABLES.items():
        text = fetch({"TableId": table_id, "GeographyId": TORONTO_CMA, "GeographyTypeId": "3",
                      "ForTimePeriod.Year": SNAPSHOT_YEAR, "Frequency": "Annual"},
                     FILES / f"{name}_{SNAPSHOT_YEAR}.csv")
        out_rows = [[SNAPSHOT_YEAR, area, bedroom, value, rel] for area, bedroom, value, rel in parse(text)]
        print(f"{name:<28} {len(out_rows) // 5:>3} areas")
        write(RAW / f"{name}_{SNAPSHOT_YEAR}.csv",
              ["survey_year", "area", "bedroom_type", "value", "reliability"], out_rows)


def write(path, header, rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)


if __name__ == "__main__":
    main()
