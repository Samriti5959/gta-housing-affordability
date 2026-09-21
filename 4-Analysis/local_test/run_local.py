"""Run the BigQuery SQL in ../sql against a local DuckDB copy of the raw data.

No Google Cloud account needed. The script:
  1. rebuilds the raw_cmhc tables from 1-Get the data/raw/ using the same parsing
     functions as 2-Extract/Bronze_Layer_load_Data_in_Tables.ipynb (so table and
     column names match BigQuery exactly), and loads 3-Clean/Cleaned_Data/rent_clean.csv
     as cleaned_cmhc.rent_clean;
  2. translates each SQL file from BigQuery to DuckDB syntax with sqlglot and runs it;
  3. writes every view (cleaned_cmhc and gta_analytics) and query result to ../results/.

Setup:  pip install duckdb sqlglot pandas
Usage:  python3 run_local.py
"""
import ast
import csv
import json
from collections import Counter
from pathlib import Path

import duckdb
import pandas as pd
import sqlglot
from sqlglot import exp

HERE = Path(__file__).resolve().parent
ANALYSIS = HERE.parent
REPO = ANALYSIS.parent
PROJECT = "gta-housing-508813"
RESULTS = ANALYSIS / "results"


def notebook_functions():
    """Load the parsing functions from the extract notebook, reading local files instead of GitHub."""
    nb = json.loads((REPO / "2-Extract" / "Bronze_Layer_load_Data_in_Tables.ipynb").read_text())

    class LocalRequests:
        @staticmethod
        def get(path):
            return type("Resp", (), {"content": Path(path).read_bytes()})()

    ns = {"pd": pd, "csv": csv, "Counter": Counter, "requests": LocalRequests}
    for cell in nb["cells"]:
        if cell["cell_type"] != "code":
            continue
        for node in ast.parse("".join(cell["source"])).body:
            if isinstance(node, ast.FunctionDef):
                exec(compile(ast.Module([node], []), "notebook", "exec"), ns)
    return ns


def build_raw(con):
    fns = notebook_functions()
    con.execute("CREATE SCHEMA raw_cmhc; CREATE SCHEMA cleaned_cmhc; CREATE SCHEMA gta_analytics;")
    raw = REPO / "1-Get the data" / "raw"
    for f in sorted((raw / "cmhc" / "files").glob("*.csv")):
        load(con, "raw_cmhc", f.stem.lower(), fns["smart_read_csv"](str(f)))
    for f in sorted((raw / "statcan").glob("*_gta.csv")):
        load(con, "raw_cmhc", f.stem.lower(), fns["read_plain_csv"](str(f)))
    load(con, "cleaned_cmhc", "rent_clean", pd.read_csv(REPO / "3-Clean" / "Cleaned_Data" / "rent_clean.csv"))


def load(con, schema, table, df):
    con.register("df", df)
    con.execute(f'CREATE TABLE {schema}."{table}" AS SELECT * FROM df')
    con.unregister("df")


def to_duckdb(sql):
    """Yield (duckdb_sql, is_query) for each statement in a BigQuery SQL file."""
    sql = sql.replace(f"`{PROJECT}.", "`")
    for expr in sqlglot.parse(sql, read="bigquery"):
        if expr is None:
            continue
        if isinstance(expr, exp.Create) and expr.kind == "SCHEMA":
            continue  # schemas are created in build_raw
        yield expr.sql(dialect="duckdb"), isinstance(expr, exp.Query)


def main():
    con = duckdb.connect()
    build_raw(con)
    for path in sorted((ANALYSIS / "sql").glob("*.sql")):
        for n, (stmt, is_query) in enumerate(to_duckdb(path.read_text()), start=1):
            try:
                result = con.execute(stmt)
            except Exception as e:
                raise SystemExit(f"\n{path.name} failed:\n{e}\n\n{stmt[:2000]}")
            if is_query:
                df = result.df()
                RESULTS.mkdir(exist_ok=True)
                df.to_csv(RESULTS / f"{path.stem}_q{n}.csv", index=False)
                print(f"\n-- {path.name} query {n}\n{df.to_string(index=False, max_rows=40)}")
        print(f"ok  {path.name}")

    RESULTS.mkdir(exist_ok=True)
    views = con.execute(
        "SELECT table_schema, table_name FROM information_schema.tables "
        "WHERE table_type = 'VIEW' AND table_schema IN ('cleaned_cmhc', 'gta_analytics') ORDER BY 1, 2"
    ).fetchall()
    for schema, view in views:
        df = con.execute(f"SELECT * FROM {schema}.{view}").df()
        df = df.sort_values(list(df.columns), ignore_index=True)  # views have no order; keep files stable
        df.to_csv(RESULTS / f"{view}.csv", index=False)
        print(f"results/{view}.csv  {len(df):,} rows")


if __name__ == "__main__":
    main()
