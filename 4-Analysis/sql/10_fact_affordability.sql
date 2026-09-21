-- 10_fact_affordability.sql
-- The main KPI table: one row per municipality (all 25, even where data is missing).
--
-- Rent-to-income ratio (RTI) = average annual rent / median household income.
--   * rti_2br_2020_pct      observed: Oct 2020 CMHC rent vs 2020 census income (same year, both real data)
--   * rti_2br_2025_est_pct  estimated: Oct 2025 rent vs 2020 income carried forward with Toronto CPI.
--                           Assumes incomes grew with inflation since 2020. Label it an estimate.
-- Income needed = income at which the average 2-bedroom rent is 30% of gross income (CMHC benchmark).
-- Affordability band (on rti_2br_2025_est_pct): under 30% affordable, 30-40% unaffordable, 40%+ severely unaffordable.
--
-- READ THIS BEFORE QUOTING RTI: the income is the median of ALL households (owners and renters).
-- Renters earn much less, so a low RTI here does not mean renters can afford the rent;
-- renters_30_plus_2021_pct is the direct measure of renter affordability. StatCan does not publish
-- renter-only median income by municipality. Also, 2020 incomes were lifted by pandemic benefits (CERB),
-- which inflates 2015 -> 2020 income growth, especially in lower-income places.
--
-- NULL means "not published" (CMHC suppressed or no data), never zero.

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.fact_affordability` AS
WITH rent AS (
  SELECT
    csd_code,
    MAX(CASE WHEN year = 2025 AND bedroom_type = '2 Bedroom' THEN avg_monthly_rent END) AS rent_2br_2025,
    MAX(CASE WHEN year = 2025 AND bedroom_type = '2 Bedroom' THEN quality_flag END) AS rent_2br_2025_quality,
    MAX(CASE WHEN year = 2020 AND bedroom_type = '2 Bedroom' THEN avg_monthly_rent END) AS rent_2br_2020,
    MAX(CASE WHEN year = 2015 AND bedroom_type = '2 Bedroom' THEN avg_monthly_rent END) AS rent_2br_2015,
    MAX(CASE WHEN year = 2025 AND bedroom_type = 'Total' THEN avg_monthly_rent END) AS rent_total_2025,
    MAX(CASE WHEN year = 2025 AND bedroom_type = '1 Bedroom' THEN avg_monthly_rent END) AS rent_1br_2025
  FROM `gta-housing-508813.cleaned_cmhc.rent_clean`
  GROUP BY csd_code
),
vacancy AS (
  SELECT
    csd_code,
    MAX(CASE WHEN bedroom_type = 'Total' THEN vacancy_rate_pct END) AS vacancy_total_2025_pct,
    MAX(CASE WHEN bedroom_type = '2 Bedroom' THEN vacancy_rate_pct END) AS vacancy_2br_2025_pct
  FROM `gta-housing-508813.cleaned_cmhc.vacancy_clean`
  WHERE year = 2025
  GROUP BY csd_code
),
cpi AS (
  SELECT
    MAX(CASE WHEN year = 2025 THEN all_items_cpi END) / MAX(CASE WHEN year = 2020 THEN all_items_cpi END) AS factor_2020_to_2025,
    MAX(CASE WHEN year = 2020 THEN all_items_cpi END) / MAX(CASE WHEN year = 2015 THEN all_items_cpi END) AS factor_2015_to_2020
  FROM `gta-housing-508813.cleaned_cmhc.cpi_annual`
),
joined AS (
  SELECT
    d.csd_code, d.municipality, d.region, d.cma,
    p.population AS population_2025,
    i.households_2021,
    s.renter_households AS renter_households_2021,
    s.renter_share_pct AS renter_share_2021_pct,
    i.median_hh_income_2020,
    i.median_hh_income_2015_in_2020_dollars,
    ROUND(i.median_hh_income_2020 * cpi.factor_2020_to_2025, -2) AS median_hh_income_2025_est,
    r.rent_2br_2015, r.rent_2br_2020, r.rent_2br_2025, r.rent_2br_2025_quality,
    r.rent_1br_2025, r.rent_total_2025,
    s.renters_30_plus_pct AS renters_30_plus_2021_pct,
    v.vacancy_total_2025_pct, v.vacancy_2br_2025_pct,
    cpi.factor_2020_to_2025, cpi.factor_2015_to_2020
  FROM `gta-housing-508813.cleaned_cmhc.dim_municipality` AS d
  CROSS JOIN cpi
  LEFT JOIN rent AS r USING (csd_code)
  LEFT JOIN vacancy AS v USING (csd_code)
  LEFT JOIN `gta-housing-508813.cleaned_cmhc.income_clean` AS i
    ON i.geo_level = 'Municipality' AND i.geo_code = d.csd_code
  LEFT JOIN `gta-housing-508813.cleaned_cmhc.renter_shelter_clean` AS s
    ON s.geo_level = 'Municipality' AND s.geo_code = d.csd_code
  LEFT JOIN `gta-housing-508813.cleaned_cmhc.population_clean` AS p
    ON p.csd_code = d.csd_code AND p.year = 2025
)
SELECT
  csd_code, municipality, region, cma,
  population_2025, households_2021, renter_households_2021, renter_share_2021_pct,

  -- Income
  median_hh_income_2020,
  median_hh_income_2025_est,

  -- Rent
  rent_2br_2025, rent_2br_2025_quality, rent_1br_2025, rent_total_2025, rent_2br_2020,

  -- KPI 1: rent-to-income
  ROUND(100 * SAFE_DIVIDE(rent_2br_2020 * 12, median_hh_income_2020), 1) AS rti_2br_2020_pct,
  ROUND(100 * SAFE_DIVIDE(rent_2br_2025 * 12, median_hh_income_2025_est), 1) AS rti_2br_2025_est_pct,
  ROUND(100 * SAFE_DIVIDE(rent_total_2025 * 12, median_hh_income_2025_est), 1) AS rti_total_2025_est_pct,

  -- KPI 2: income needed for the average 2-bedroom at 30% of income
  ROUND(rent_2br_2025 * 12 / 0.30, -2) AS income_needed_2br_2025,
  ROUND(rent_2br_2025 * 12 / 0.30 - median_hh_income_2025_est, -2) AS income_gap_2br_2025,
  ROUND(100 * SAFE_DIVIDE(rent_2br_2025 * 12 / 0.30, median_hh_income_2025_est), 1) AS income_needed_pct_of_median_2025,

  CASE
    WHEN rent_2br_2025 IS NULL OR median_hh_income_2025_est IS NULL THEN 'No published rent'
    WHEN rent_2br_2025 * 12 / median_hh_income_2025_est < 0.30 THEN 'Affordable (<30%)'
    WHEN rent_2br_2025 * 12 / median_hh_income_2025_est < 0.40 THEN 'Unaffordable (30-40%)'
    ELSE 'Severely unaffordable (40%+)'
  END AS affordability_band_at_median_income_2025,

  -- KPI 3: renters already over the 30% line (2021 Census)
  renters_30_plus_2021_pct,

  -- KPI 4: vacancy (CMHC: about 3% is a balanced market)
  vacancy_total_2025_pct,
  vacancy_2br_2025_pct,

  -- KPI 5: rent growth vs income growth
  ROUND(100 * (POW(SAFE_DIVIDE(rent_2br_2025, rent_2br_2015), 1 / 10) - 1), 1) AS rent_2br_cagr_2015_2025_pct,
  ROUND(100 * (POW(SAFE_DIVIDE(rent_2br_2025, rent_2br_2020), 1 / 5) - 1), 1) AS rent_2br_cagr_2020_2025_pct,
  -- 2015 -> 2020, both in 2020 dollars (real): rent adjusted with Toronto CPI, income already in constant dollars
  ROUND(100 * (SAFE_DIVIDE(rent_2br_2020, rent_2br_2015 * factor_2015_to_2020) - 1), 1) AS real_rent_2br_growth_2015_2020_pct,
  ROUND(100 * (SAFE_DIVIDE(median_hh_income_2020, median_hh_income_2015_in_2020_dollars) - 1), 1) AS real_income_growth_2015_2020_pct,

  CASE
    WHEN rent_2br_2025 IS NOT NULL THEN 'Full'
    WHEN rent_total_2025 IS NOT NULL THEN 'Total rent only (2-bedroom suppressed)'
    ELSE 'No 2025 rent published'
  END AS rent_coverage_2025
FROM joined;
