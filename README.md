# ☀️ U.S. Solar Energy Potential Analysis

**Analyzing solar adoption trends across 50 states using SQL and MongoDB**

> USC Marshall School of Business
> Authors: Minha Kim

---

## 📋 Overview

This project analyzes Google's **Project Sunroof** dataset to evaluate solar energy suitability, adoption rates, and carbon offset potential across all 50 U.S. states. We wrote **15+ SQL queries** and **8 MongoDB aggregation pipelines** to uncover regional patterns in solar infrastructure readiness.

## 📊 Key Findings

| Metric | Value |
|--------|-------|
| Highest avg solar-ready buildings | **West (88.3%)** |
| Lowest solar install ratio | **Midwest (0.14%)** |
| Highest install ratio | **West (2.86%)** |
| Best roof orientation for sunlight | **South-facing** |
| Largest untapped solar potential | **California** |
| Top West states by panels | **CA, AZ, WA** |

## 🔧 SQL Techniques Used

- **JOINs** — Linking state data with regional classifications
- **Subqueries** — Comparing states against regional averages
- **UNION ALL** — Combining sunlight data across roof orientations
- **GROUP BY + HAVING** — Aggregating and filtering regional metrics
- **Aggregate Functions** — AVG, SUM, COUNT, MAX, MIN, ROUND

### Sample Query: Region with Highest Solar Suitability
```sql
SELECT r.region, AVG(s.percent_qualified) AS avg_percent
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
GROUP BY r.region
ORDER BY avg_percent DESC
LIMIT 1;
```
**Result:** West region — 88.28% average solar-ready buildings

### Sample Query: States Above Regional Average (Subquery)
```sql
SELECT s.state_name AS state, s.carbon_offset_metric_tons
FROM project_sunroof_state s, region_lookup r
WHERE s.state_name = r.state
  AND r.region = 'Northeast'
  AND s.carbon_offset_metric_tons >
    (SELECT AVG(s2.carbon_offset_metric_tons)
     FROM project_sunroof_state s2, region_lookup r2
     WHERE s2.state_name = r2.state
       AND r2.region = 'Northeast');
```
**Result:** New Jersey, New York, Pennsylvania

### Sample Query: Untapped Solar Potential
```sql
SELECT state_name,
  (count_qualified - existing_installs_count) AS diff
FROM project_sunroof_state
ORDER BY diff DESC
LIMIT 1;
```
**Result:** California — 8,286,070 buildings with untapped solar potential

## 🍃 MongoDB Techniques Used

- **$match** — Filtering by region
- **$group** — Aggregating with $sum, $avg, $max, $min
- **$project** — Reshaping output and computed fields
- **$sort + $limit** — Ranking and top-N queries
- **$divide** — Scaling large numbers for readability

### Sample Aggregation: Solar Suitability Stats for West Region
```javascript
db.sunroof.aggregate([
  { $match: { region: "West" } },
  { $group: {
      _id: null,
      maxQualified: { $max: "$percent_qualified" },
      avgQualified: { $avg: "$percent_qualified" },
      minQualified: { $min: "$percent_qualified" }
  }},
  { $project: { _id: 0, maxQualified: 1, avgQualified: 1, minQualified: 1 }}
])
```
**Result:** Max: 96.43% · Avg: 88.28% · Min: 75.68%

## 📁 Files in This Repository

| File | Description |
|------|-------------|
| `project1_part1.pdf` | SQL queries with results and explanations (15 queries) |
| `project1_part2.pdf` | MongoDB aggregation pipelines with results (8 queries) |
| `sql_queries.sql` | All SQL queries in a standalone file |
| `mongodb_queries.js` | All MongoDB aggregation pipelines |
| `README.md` | This file |

## 📈 Tableau Dashboard

A companion Tableau dashboard visualizes the solar data by region. *(Link to Tableau Public coming soon)*

## 🗂 Data Source

Google Project Sunroof — State-level solar potential data for the United States
