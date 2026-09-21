-- 11_fact_rent_trend.sql
-- Yearly rent per municipality and bedroom type, with year-over-year change,
-- inflation-adjusted rent (2025 dollars) and a rent index (2015 = 100) for trend charts.

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.fact_rent_trend` AS
WITH base AS (
  SELECT
    r.csd_code, d.municipality, d.region, r.year, r.bedroom_type,
    r.avg_monthly_rent, r.quality_flag, r.quality_level,
    c.all_items_cpi, c.rent_cpi
  FROM `gta-housing-508813.cleaned_cmhc.rent_clean` AS r
  JOIN `gta-housing-508813.cleaned_cmhc.dim_municipality` AS d USING (csd_code)
  LEFT JOIN `gta-housing-508813.cleaned_cmhc.cpi_annual` AS c USING (year)
),
with_lag AS (
  SELECT
    *,
    LAG(avg_monthly_rent) OVER w AS prev_rent,
    LAG(year) OVER w AS prev_year,
    FIRST_VALUE(CASE WHEN year = 2015 THEN avg_monthly_rent END IGNORE NULLS) OVER (
      PARTITION BY csd_code, bedroom_type ORDER BY year
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS rent_2015
  FROM base
  WINDOW w AS (PARTITION BY csd_code, bedroom_type ORDER BY year)
)
SELECT
  csd_code, municipality, region, year, bedroom_type,
  avg_monthly_rent, quality_flag, quality_level,
  -- only a true year-over-year change when the previous published year is the year before
  CASE WHEN prev_year = year - 1
       THEN ROUND(100 * (avg_monthly_rent / prev_rent - 1), 1) END AS yoy_change_pct,
  ROUND(avg_monthly_rent * (SELECT all_items_cpi FROM `gta-housing-508813.cleaned_cmhc.cpi_annual` WHERE year = 2025)
        / all_items_cpi, 0) AS rent_in_2025_dollars,
  ROUND(100 * avg_monthly_rent / rent_2015, 1) AS rent_index_2015_100
FROM with_lag;
