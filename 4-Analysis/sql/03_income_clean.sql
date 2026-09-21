-- 03_income_clean.sql
-- Median household income from the 2021 Census (StatCan table 98-10-0057), all households.
-- One row per geography: the 25 municipalities, the 5 regions, Ontario and Canada.
--
-- Income is for calendar year 2020. The 2015 figure is also in 2020 constant dollars,
-- so 2015 -> 2020 growth is real (inflation-adjusted) growth.
-- Note: this covers all households (owners and renters). StatCan does not publish
-- renter-only median income by municipality in its standard tables.

CREATE OR REPLACE VIEW `gta-housing-508813.cleaned_cmhc.income_clean` AS
WITH totals AS (
  SELECT *
  FROM `gta-housing-508813.raw_cmhc.98100057_gta`
  WHERE STARTS_WITH(Household_size__7, 'Total')
    AND STARTS_WITH(Household_type_including_census_family_structure___11, 'Total')
)
SELECT
  -- DGUID = <vintage><A|S><4-digit schema><code>; A0005 = municipality (CSD), A0003 = region (CD)
  CASE
    WHEN SUBSTR(DGUID, 5, 5) = 'A0005' THEN 'Municipality'
    WHEN SUBSTR(DGUID, 5, 5) = 'A0003' THEN 'Region'
    WHEN SUBSTR(DGUID, 5, 5) = 'A0002' THEN 'Province'
    ELSE 'Country'
  END AS geo_level,
  SAFE_CAST(SUBSTR(DGUID, 10) AS INT64) AS geo_code,   -- CSD code for municipalities, CD code for regions
  GEO AS geo_name,
  REF_DATE AS census_year,
  Household_income_statistics__6__Number_of_households__2021__1 AS households_2021,
  Household_income_statistics__6__Median_household_total_income__2020___2020_constant_dollars__3 AS median_hh_income_2020,
  Household_income_statistics__6__Median_household_after_tax_income__2020___2020_constant_dollars__5 AS median_hh_after_tax_income_2020,
  Household_income_statistics__6__Median_household_total_income__2015___2020_constant_dollars__4 AS median_hh_income_2015_in_2020_dollars
FROM totals;
