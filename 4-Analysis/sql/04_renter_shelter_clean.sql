-- 04_renter_shelter_clean.sql
-- Shelter-cost-to-income ratio by tenure, 2021 Census (StatCan table 98-10-0255).
-- One row per geography with renter and owner household counts above / below the 30% line.
--
-- The share uses households whose ratio could be calculated as the denominator
-- ("less than 30%" + "30% or more"), which excludes "Not applicable" households
-- (zero or negative income). This matches how StatCan reports the percentage.

CREATE OR REPLACE VIEW `gta-housing-508813.cleaned_cmhc.renter_shelter_clean` AS
WITH base AS (
  SELECT
    DGUID, GEO,
    Shelter_cost_to_income_ratio__5 AS ratio_group,
    Tenure_including_presence_of_mortgage_payments_and_subsidized_housing__8__Renter_5 AS renters,
    Tenure_including_presence_of_mortgage_payments_and_subsidized_housing__8__Owner_2 AS owners
  FROM `gta-housing-508813.raw_cmhc.98100255_gta`
  WHERE Residence_on_or_off_reserve__3 = 'Total - Residence on or off reserve'
    AND STARTS_WITH(Household_type_including_census_family_structure__9, 'Total')
    AND Statistics__3C = 'Number of private households'
),
pivoted AS (
  SELECT
    DGUID, GEO,
    SUM(CASE WHEN ratio_group = 'Total - Shelter-cost-to-income ratio' THEN renters END) AS renter_households,
    SUM(CASE WHEN ratio_group = 'Spending less than 30% of income on shelter costs' THEN renters END) AS renters_under_30,
    SUM(CASE WHEN ratio_group = 'Spending 30% or more of income on shelter costs' THEN renters END) AS renters_30_plus,
    SUM(CASE WHEN ratio_group = 'Total - Shelter-cost-to-income ratio' THEN owners END) AS owner_households,
    SUM(CASE WHEN ratio_group = 'Spending less than 30% of income on shelter costs' THEN owners END) AS owners_under_30,
    SUM(CASE WHEN ratio_group = 'Spending 30% or more of income on shelter costs' THEN owners END) AS owners_30_plus
  FROM base
  GROUP BY DGUID, GEO
)
SELECT
  CASE
    WHEN SUBSTR(DGUID, 5, 5) = 'A0005' THEN 'Municipality'
    WHEN SUBSTR(DGUID, 5, 5) = 'A0003' THEN 'Region'
    WHEN SUBSTR(DGUID, 5, 5) = 'A0002' THEN 'Province'
    ELSE 'Country'
  END AS geo_level,
  SAFE_CAST(SUBSTR(DGUID, 10) AS INT64) AS geo_code,
  GEO AS geo_name,
  renter_households,
  renters_30_plus,
  ROUND(100 * SAFE_DIVIDE(renters_30_plus, renters_under_30 + renters_30_plus), 1) AS renters_30_plus_pct,
  ROUND(100 * SAFE_DIVIDE(renter_households, renter_households + owner_households), 1) AS renter_share_pct,
  ROUND(100 * SAFE_DIVIDE(owners_30_plus, owners_under_30 + owners_30_plus), 1) AS owners_30_plus_pct
FROM pivoted;
