-- 01_dim_municipality.sql
-- One row per project municipality (the 25 in City of Toronto + Peel, York, Durham, Halton).
-- csd_code is the join key for every other table.

CREATE SCHEMA IF NOT EXISTS `gta-housing-508813.gta_analytics`;

CREATE OR REPLACE VIEW `gta-housing-508813.gta_analytics.dim_municipality` AS
SELECT 3520005 AS csd_code, 'Toronto' AS municipality, 'Toronto' AS region, 3520 AS region_code, 'Toronto' AS cma
UNION ALL SELECT 3521005, 'Mississauga', 'Peel', 3521, 'Toronto'
UNION ALL SELECT 3521010, 'Brampton', 'Peel', 3521, 'Toronto'
UNION ALL SELECT 3521024, 'Caledon', 'Peel', 3521, 'Toronto'
UNION ALL SELECT 3519036, 'Markham', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519028, 'Vaughan', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519038, 'Richmond Hill', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519048, 'Newmarket', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519046, 'Aurora', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519054, 'East Gwillimbury', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519070, 'Georgina', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519049, 'King', 'York', 3519, 'Toronto'
UNION ALL SELECT 3519044, 'Whitchurch-Stouffville', 'York', 3519, 'Toronto'
UNION ALL SELECT 3518013, 'Oshawa', 'Durham', 3518, 'Oshawa'
UNION ALL SELECT 3518009, 'Whitby', 'Durham', 3518, 'Oshawa'
UNION ALL SELECT 3518005, 'Ajax', 'Durham', 3518, 'Toronto'
UNION ALL SELECT 3518001, 'Pickering', 'Durham', 3518, 'Toronto'
UNION ALL SELECT 3518017, 'Clarington', 'Durham', 3518, 'Oshawa'
UNION ALL SELECT 3518020, 'Scugog', 'Durham', 3518, NULL
UNION ALL SELECT 3518029, 'Uxbridge', 'Durham', 3518, 'Toronto'
UNION ALL SELECT 3518039, 'Brock', 'Durham', 3518, NULL
UNION ALL SELECT 3524002, 'Burlington', 'Halton', 3524, 'Hamilton'
UNION ALL SELECT 3524001, 'Oakville', 'Halton', 3524, 'Toronto'
UNION ALL SELECT 3524009, 'Milton', 'Halton', 3524, 'Toronto'
UNION ALL SELECT 3524015, 'Halton Hills', 'Halton', 3524, 'Toronto';
