-- ============================================
-- U.S. Solar Energy Potential Analysis
-- SQL Queries — Google Project Sunroof Dataset
-- Authors: Minha Kim, Charles Huang
-- Course: TAC 249, USC Marshall School of Business
-- ============================================

-- 1. Region with highest average percentage of solar-suitable buildings
SELECT r.region, AVG(s.percent_qualified) AS avg_percent
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
GROUP BY r.region
ORDER BY avg_percent DESC
LIMIT 1;

-- 2. Total yearly sunlight by roof orientation (scaled by 10M)
SELECT
  ROUND(SUM(yearly_sunlight_kwh_n) / 10000000, 2) AS north_sum,
  ROUND(SUM(yearly_sunlight_kwh_s) / 10000000, 2) AS south_sum,
  ROUND(SUM(yearly_sunlight_kwh_e) / 10000000, 2) AS east_sum,
  ROUND(SUM(yearly_sunlight_kwh_w) / 10000000, 2) AS west_sum,
  ROUND(SUM(yearly_sunlight_kwh_f) / 10000000, 2) AS flat_sum
FROM project_sunroof_state;

-- 3. Top 3 West region states by total panel count
SELECT s.state_name, s.number_of_panels_total
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
  AND r.region = 'West'
ORDER BY s.number_of_panels_total DESC
LIMIT 3;

-- 4. States per region with 1,000+ existing solar installations
SELECT r.region, COUNT(*) AS state_count
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
  AND s.existing_installs_count > 1000
GROUP BY r.region;

-- 5. Region with lowest install-to-qualified ratio
SELECT r.region,
  SUM(s.existing_installs_count) / SUM(s.count_qualified) AS install_ratio
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
GROUP BY r.region
ORDER BY install_ratio ASC
LIMIT 1;

-- 6. Northeast states with above-average carbon offset (subquery)
SELECT s.state_name AS state, s.carbon_offset_metric_tons
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
  AND r.region = 'Northeast'
  AND s.carbon_offset_metric_tons >
    (SELECT AVG(s2.carbon_offset_metric_tons)
     FROM project_sunroof_state s2, region_lookup r2
     WHERE s2.state_name = r2.state
       AND r2.region = 'Northeast');

-- 7. Top 3 Northeast states by carbon offset
SELECT r.region, s.state_name AS state
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
  AND r.region = 'Northeast'
ORDER BY s.carbon_offset_metric_tons DESC
LIMIT 3;

-- 8. Roof direction with greatest total yearly sunlight (UNION ALL)
SELECT direction, SUM(yearly_sunlight) AS yearly_sunlight
FROM (
  SELECT 'north' AS direction, yearly_sunlight_kwh_n AS yearly_sunlight FROM project_sunroof_state
  UNION ALL
  SELECT 'south', yearly_sunlight_kwh_s FROM project_sunroof_state
  UNION ALL
  SELECT 'east', yearly_sunlight_kwh_e FROM project_sunroof_state
  UNION ALL
  SELECT 'west', yearly_sunlight_kwh_w FROM project_sunroof_state
) t
GROUP BY direction
ORDER BY yearly_sunlight DESC
LIMIT 1;

-- 9. Max, avg, min solar suitability for West region
SELECT 'max_qualified' AS attribute, ROUND(MAX(s.percent_qualified), 2) AS percent_qual
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'West'
UNION ALL
SELECT 'avg_qualified', ROUND(AVG(s.percent_qualified), 2)
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'West'
UNION ALL
SELECT 'min_qualified', ROUND(MIN(s.percent_qualified), 2)
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'West';

-- 10. State name initials with 5+ states (GROUP BY + HAVING)
SELECT LEFT(state_name, 1) AS initial, COUNT(*) AS numStates
FROM project_sunroof_state
GROUP BY initial
HAVING COUNT(*) >= 5
ORDER BY initial;

-- 11. State with highest total yearly sunlight (excluding north)
SELECT state_name,
  (yearly_sunlight_kwh_s + yearly_sunlight_kwh_e + yearly_sunlight_kwh_w + yearly_sunlight_kwh_f) AS yearlyKw
FROM project_sunroof_state
ORDER BY yearlyKw DESC
LIMIT 1;

-- 12. Regional solar adoption percentage
SELECT r.region,
  (SUM(s.existing_installs_count) / SUM(s.count_qualified)) * 100 AS install_percentage
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
GROUP BY r.region;

-- 13. Top solar-suitable state per region (subqueries + UNION ALL)
SELECT r.region, s.state_name, s.percent_qualified
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'South'
  AND s.percent_qualified = (SELECT MAX(s2.percent_qualified) FROM project_sunroof_state s2, region_lookup r2 WHERE s2.state_name = r2.state AND r2.region = 'South')
UNION ALL
SELECT r.region, s.state_name, s.percent_qualified
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'West'
  AND s.percent_qualified = (SELECT MAX(s2.percent_qualified) FROM project_sunroof_state s2, region_lookup r2 WHERE s2.state_name = r2.state AND r2.region = 'West')
UNION ALL
SELECT r.region, s.state_name, s.percent_qualified
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'Northeast'
  AND s.percent_qualified = (SELECT MAX(s2.percent_qualified) FROM project_sunroof_state s2, region_lookup r2 WHERE s2.state_name = r2.state AND r2.region = 'Northeast')
UNION ALL
SELECT r.region, s.state_name, s.percent_qualified
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state AND r.region = 'Midwest'
  AND s.percent_qualified = (SELECT MAX(s2.percent_qualified) FROM project_sunroof_state s2, region_lookup r2 WHERE s2.state_name = r2.state AND r2.region = 'Midwest');

-- 14. State with largest untapped solar potential
SELECT state_name, (count_qualified - existing_installs_count) AS diff
FROM project_sunroof_state
ORDER BY diff DESC
LIMIT 1;

-- 15. State with highest carbon offset per installed building
SELECT state_name,
  carbon_offset_metric_tons / existing_installs_count AS offset_per_building
FROM project_sunroof_state
WHERE existing_installs_count > 0
ORDER BY offset_per_building DESC
LIMIT 1;
