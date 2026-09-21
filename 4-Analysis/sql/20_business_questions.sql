-- 20_business_questions.sql
-- The six business questions, answered from the gta_analytics views.
-- Main question: where in the GTA is renting affordable, for whom, and how is that changing?

-- Q1. Is renting outside Toronto more affordable once local income is considered?
--     Municipalities ranked by 2-bedroom rent-to-income (2025 estimate), compared with Toronto.
SELECT
  RANK() OVER (ORDER BY rti_2br_2025_est_pct) AS rank_most_affordable,
  municipality, region,
  rent_2br_2025,
  median_hh_income_2025_est,
  rti_2br_2025_est_pct,
  ROUND(rti_2br_2025_est_pct - (SELECT rti_2br_2025_est_pct FROM `gta-housing-508813.gta_analytics.fact_affordability`
                                WHERE municipality = 'Toronto'), 1) AS pts_vs_toronto,
  rent_2br_2025 - (SELECT rent_2br_2025 FROM `gta-housing-508813.gta_analytics.fact_affordability`
                   WHERE municipality = 'Toronto') AS rent_diff_vs_toronto,
  rent_2br_2025_quality
FROM `gta-housing-508813.gta_analytics.fact_affordability`
WHERE rti_2br_2025_est_pct IS NOT NULL
ORDER BY rti_2br_2025_est_pct;

-- Q2. How much income does a household need to afford the average 2-bedroom (rent = 30% of income),
--     and how does that compare with what the median household earns?
SELECT
  municipality, region,
  rent_2br_2025,
  income_needed_2br_2025,
  median_hh_income_2025_est,
  income_needed_pct_of_median_2025,
  income_gap_2br_2025
FROM `gta-housing-508813.gta_analytics.fact_affordability`
WHERE income_needed_2br_2025 IS NOT NULL
ORDER BY income_needed_2br_2025 DESC;

-- Q3. For whom? Where are renters already under the most strain?
--     Share of renter households spending 30%+ of income on shelter (2021 Census) vs owners.
SELECT
  municipality, region,
  renter_households_2021,
  renter_share_2021_pct,
  renters_30_plus_2021_pct,
  rti_2br_2025_est_pct,
  affordability_band_at_median_income_2025
FROM `gta-housing-508813.gta_analytics.fact_affordability`
ORDER BY renters_30_plus_2021_pct DESC;

-- Q4. Did rent outpace income? Real (inflation-adjusted) growth 2015 -> 2020, 2-bedroom rent vs median income.
SELECT
  municipality, region,
  real_rent_2br_growth_2015_2020_pct,
  real_income_growth_2015_2020_pct,
  ROUND(real_rent_2br_growth_2015_2020_pct - real_income_growth_2015_2020_pct, 1) AS rent_minus_income_pts,
  CASE WHEN real_rent_2br_growth_2015_2020_pct > real_income_growth_2015_2020_pct
       THEN 'Rent grew faster' ELSE 'Income grew faster' END AS verdict
FROM `gta-housing-508813.gta_analytics.fact_affordability`
WHERE real_rent_2br_growth_2015_2020_pct IS NOT NULL
ORDER BY rent_minus_income_pts DESC;

-- Q5. How fast are rents rising now? 2-bedroom rent growth per year, last 5 and 10 years,
--     against Toronto CPI inflation over the same 5 years.
SELECT
  municipality, region,
  rent_2br_2020, rent_2br_2025,
  rent_2br_cagr_2020_2025_pct,
  rent_2br_cagr_2015_2025_pct,
  ROUND(100 * (POW((SELECT MAX(CASE WHEN year = 2025 THEN all_items_cpi END) / MAX(CASE WHEN year = 2020 THEN all_items_cpi END)
                    FROM `gta-housing-508813.gta_analytics.cpi_annual`), 1 / 5) - 1), 1) AS cpi_inflation_2020_2025_pct
FROM `gta-housing-508813.gta_analytics.fact_affordability`
WHERE rent_2br_cagr_2020_2025_pct IS NOT NULL
ORDER BY rent_2br_cagr_2020_2025_pct DESC;

-- Q6. How much choice do renters have? 2025 vacancy rate (about 3% = balanced market) next to rent growth,
--     and a region roll-up.
SELECT
  municipality, region,
  vacancy_total_2025_pct,
  CASE WHEN vacancy_total_2025_pct < 3 THEN 'Tight (<3%)' ELSE 'Balanced or loose (3%+)' END AS market,
  rent_2br_cagr_2020_2025_pct,
  rent_2br_2025
FROM `gta-housing-508813.gta_analytics.fact_affordability`
WHERE vacancy_total_2025_pct IS NOT NULL
ORDER BY vacancy_total_2025_pct;

SELECT *
FROM `gta-housing-508813.gta_analytics.region_summary`
ORDER BY rti_2br_2025_est_pct DESC;
