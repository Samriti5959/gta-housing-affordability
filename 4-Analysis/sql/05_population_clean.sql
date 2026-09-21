-- 05_population_clean.sql
-- Population estimates on July 1, by municipality (StatCan table 17-10-0155), 2001-2025.

CREATE OR REPLACE VIEW `gta-housing-508813.cleaned_cmhc.population_clean` AS
SELECT
  SAFE_CAST(SUBSTR(DGUID, 10) AS INT64) AS csd_code,
  REF_DATE AS year,
  VALUE AS population
FROM `gta-housing-508813.raw_cmhc.17100155_gta`
WHERE SUBSTR(DGUID, 5, 5) = 'A0005';
