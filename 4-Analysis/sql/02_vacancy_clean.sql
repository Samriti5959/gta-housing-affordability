-- 02_vacancy_clean.sql
-- CMHC vacancy rate history, same long shape as cleaned_cmhc.rent_clean:
-- one row per municipality x year x bedroom type, published values only.
--
-- Built from the 24 raw_cmhc.vacancy_history_* tables. King is left out: CMHC publishes
-- no rental data for it, so its table only holds the source line.
-- East Gwillimbury's table has no Studio columns, so those are NULL.
-- Suppressed values (**) were already loaded as NULL and are dropped here, never set to 0.

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.vacancy_clean` AS
WITH wide AS (
  SELECT 3518001 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518001_pickering`
  UNION ALL
  SELECT 3518005 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518005_ajax`
  UNION ALL
  SELECT 3518009 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518009_whitby`
  UNION ALL
  SELECT 3518013 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518013_oshawa`
  UNION ALL
  SELECT 3518017 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518017_clarington`
  UNION ALL
  SELECT 3518020 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518020_scugog`
  UNION ALL
  SELECT 3518029 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518029_uxbridge`
  UNION ALL
  SELECT 3518039 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3518039_brock`
  UNION ALL
  SELECT 3519028 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519028_vaughan`
  UNION ALL
  SELECT 3519036 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519036_markham`
  UNION ALL
  SELECT 3519038 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519038_richmond_hill`
  UNION ALL
  SELECT 3519044 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519044_whitchurch_stouffville`
  UNION ALL
  SELECT 3519046 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519046_aurora`
  UNION ALL
  SELECT 3519048 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519048_newmarket`
  UNION ALL
  SELECT 3519054 AS csd_code, municipality AS reference_period,
         NULL AS studio, NULL AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519054_east_gwillimbury`
  UNION ALL
  SELECT 3519070 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3519070_georgina`
  UNION ALL
  SELECT 3520005 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3520005_toronto`
  UNION ALL
  SELECT 3521005 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3521005_mississauga`
  UNION ALL
  SELECT 3521010 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3521010_brampton`
  UNION ALL
  SELECT 3521024 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3521024_caledon`
  UNION ALL
  SELECT 3524001 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3524001_oakville`
  UNION ALL
  SELECT 3524002 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3524002_burlington`
  UNION ALL
  SELECT 3524009 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3524009_milton`
  UNION ALL
  SELECT 3524015 AS csd_code, municipality AS reference_period,
         SAFE_CAST(`Studio` AS FLOAT64) AS studio, CAST(`Studio_flag` AS STRING) AS studio_flag,
         SAFE_CAST(`1_Bedroom` AS FLOAT64) AS br1, CAST(`1_Bedroom_flag` AS STRING) AS br1_flag,
         SAFE_CAST(`2_Bedroom` AS FLOAT64) AS br2, CAST(`2_Bedroom_flag` AS STRING) AS br2_flag,
         SAFE_CAST(`3_Bedroom` AS FLOAT64) AS br3, CAST(`3_Bedroom_flag` AS STRING) AS br3_flag,
         SAFE_CAST(`Total` AS FLOAT64) AS total, CAST(`Total_flag` AS STRING) AS total_flag
  FROM `gta-housing-508813.raw_cmhc.vacancy_history_3524015_halton_hills`
),
long AS (
  SELECT csd_code, reference_period, 'Studio' AS bedroom_type, studio AS vacancy_rate_pct, studio_flag AS quality_flag FROM wide
  UNION ALL SELECT csd_code, reference_period, '1 Bedroom', br1, br1_flag FROM wide
  UNION ALL SELECT csd_code, reference_period, '2 Bedroom', br2, br2_flag FROM wide
  UNION ALL SELECT csd_code, reference_period, '3 Bedroom', br3, br3_flag FROM wide
  UNION ALL SELECT csd_code, reference_period, 'Total', total, total_flag FROM wide
)
SELECT
  l.csd_code,
  d.municipality,
  d.region,
  CAST(SUBSTR(l.reference_period, 1, 4) AS INT64) AS year,
  TRIM(SUBSTR(l.reference_period, 6)) AS survey_month,
  l.bedroom_type,
  l.vacancy_rate_pct,
  l.quality_flag,
  CASE l.quality_flag WHEN 'a' THEN 'Excellent' WHEN 'b' THEN 'Very good'
                      WHEN 'c' THEN 'Good' WHEN 'd' THEN 'Poor (use with caution)' END AS quality_level
FROM long AS l
JOIN `gta-housing-508813.gta_analytics.dim_municipality` AS d USING (csd_code)
WHERE l.vacancy_rate_pct IS NOT NULL;
