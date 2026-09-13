# Schedule — how long each step takes

| Step | Time needed | Dates | Owner |
|---|---|---|---|
| Get the data (download CMHC Excel, set up StatCan API pull) | 1–2 days | Sep 12–13 | Member 1 | -> samiromer2
| Extract — load both into the Fabric Lakehouse as tables | 1 day | Sep 13–14 | Member 1 | @Samriti5959
| Clean & join (PySpark / Dataflow Gen2) | 2 days | Sep 14–16 | Member 1 |@mallick-rebal
| SQL analysis — business questions, KPIs | 3–4 days | Sep 15–19 | Member 2 |
| Power BI dashboard build | 3–4 days | Sep 19–23 | Member 3 |
| Team review, polish, publish | 2–3 days | Sep 24–28 | All three |

SQL analysis starts a day before extraction fully wraps up, since Member 2 can begin on whatever's already clean rather than waiting for everything. Same idea for the dashboard — it starts as soon as the SQL output is ready to connect to, not after every KPI is finalized.
