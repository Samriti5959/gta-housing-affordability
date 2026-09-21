-- 12_region_summary.sql
-- One row per region (plus Ontario for comparison).
-- Income and renter stress come straight from the census region rows.
-- Region rent is a renter-household-weighted average of the municipalities with a published
-- 2025 2-bedroom rent, so check municipalities_with_rent before comparing regions.

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.region_summary` AS
WITH muni AS (
  SELECT
    region,
    COUNT(*) AS municipalities,
    COUNT(rent_2br_2025) AS municipalities_with_rent,
    SUM(population_2025) AS population_2025,
    SAFE_DIVIDE(SUM(rent_2br_2025 * renter_households_2021),
                SUM(CASE WHEN rent_2br_2025 IS NOT NULL THEN renter_households_2021 END)) AS rent_2br_2025_weighted,
    MIN(rent_2br_2025) AS rent_2br_2025_min,
    MAX(rent_2br_2025) AS rent_2br_2025_max
  FROM `gta-housing-508813.gta_analytics.fact_affordability`
  GROUP BY region
),
cpi AS (
  SELECT MAX(CASE WHEN year = 2025 THEN all_items_cpi END) / MAX(CASE WHEN year = 2020 THEN all_items_cpi END) AS factor
  FROM `gta-housing-508813.cleaned_cmhc.cpi_annual`
)
SELECT
  i.geo_name AS region,
  m.municipalities,
  m.municipalities_with_rent,
  m.population_2025,
  i.households_2021,
  s.renter_share_pct AS renter_share_2021_pct,
  i.median_hh_income_2020,
  ROUND(i.median_hh_income_2020 * cpi.factor, -2) AS median_hh_income_2025_est,
  ROUND(m.rent_2br_2025_weighted, 0) AS rent_2br_2025_weighted,
  m.rent_2br_2025_min,
  m.rent_2br_2025_max,
  ROUND(100 * SAFE_DIVIDE(m.rent_2br_2025_weighted * 12, i.median_hh_income_2020 * cpi.factor), 1) AS rti_2br_2025_est_pct,
  s.renters_30_plus_pct AS renters_30_plus_2021_pct
FROM `gta-housing-508813.cleaned_cmhc.income_clean` AS i
CROSS JOIN cpi
LEFT JOIN `gta-housing-508813.cleaned_cmhc.renter_shelter_clean` AS s
  ON s.geo_level = i.geo_level AND s.geo_code = i.geo_code
LEFT JOIN muni AS m ON m.region = i.geo_name
WHERE i.geo_level IN ('Region', 'Province');
