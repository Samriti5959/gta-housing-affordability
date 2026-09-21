-- 13_gold_dimensions.sql
-- Pass-through views so Power BI only needs the gold dataset (gta_analytics).
--   dim_municipality   -> slicers and the relationship key (csd_code) for every fact table
--   fact_vacancy_trend -> vacancy history for trend charts

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.dim_municipality` AS
SELECT * FROM `gta-housing-508813.cleaned_cmhc.dim_municipality`;

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.fact_vacancy_trend` AS
SELECT * FROM `gta-housing-508813.cleaned_cmhc.vacancy_clean`;
