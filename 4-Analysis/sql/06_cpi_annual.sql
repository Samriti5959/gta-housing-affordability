-- 06_cpi_annual.sql
-- Toronto Consumer Price Index, annual average (StatCan table 18-10-0004, 2002 = 100).
-- Only complete years (12 months) are kept.
--   all_items_cpi -> used to express incomes and rents in the same year's dollars
--   rent_cpi      -> StatCan's rent index, a cross-check on CMHC rent growth

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.cpi_annual` AS
SELECT
  CAST(SUBSTR(REF_DATE, 1, 4) AS INT64) AS year,
  ROUND(AVG(CASE WHEN Products_and_product_groups = 'All-items' THEN VALUE END), 2) AS all_items_cpi,
  ROUND(AVG(CASE WHEN Products_and_product_groups = 'Rent' THEN VALUE END), 2) AS rent_cpi
FROM `gta-housing-508813.raw_cmhc.18100004_gta`
WHERE GEO = 'Toronto, Ontario'
GROUP BY year
HAVING COUNT(CASE WHEN Products_and_product_groups = 'All-items' THEN 1 END) = 12;
