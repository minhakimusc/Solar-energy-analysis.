// ============================================
// U.S. Solar Energy Potential Analysis
// MongoDB Aggregation Pipelines
// Authors: Minha Kim, Charles Huang
// Course: TAC 249, USC Marshall School of Business
// ============================================

// 1. Max, avg, min solar suitability for West region
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

// 2. Region with highest average solar suitability
db.sunroof.aggregate([
  { $group: { _id: "$region", avg_q: { $avg: "$percent_qualified" } } },
  { $sort: { avg_q: -1 } },
  { $limit: 1 }
])

// 3. Total yearly sunlight by roof orientation (scaled by 10M)
db.sunroof.aggregate([
  { $group: {
      _id: null,
      north_sum: { $sum: "$yearly_sunlight_kwh_n" },
      south_sum: { $sum: "$yearly_sunlight_kwh_s" },
      east_sum:  { $sum: "$yearly_sunlight_kwh_e" },
      west_sum:  { $sum: "$yearly_sunlight_kwh_w" },
      flat_sum:  { $sum: "$yearly_sunlight_kwh_f" }
  }},
  { $project: {
      _id: 0,
      north_sum: { $divide: ["$north_sum", 10000000] },
      south_sum: { $divide: ["$south_sum", 10000000] },
      east_sum:  { $divide: ["$east_sum", 10000000] },
      west_sum:  { $divide: ["$west_sum", 10000000] },
      flat_sum:  { $divide: ["$flat_sum", 10000000] }
  }}
])

// 4. Top 3 West region states by panel count
db.sunroof.aggregate([
  { $match: { region: "West" } },
  { $project: { _id: 0, state_name: 1, number_of_panels_total: 1 } },
  { $sort: { number_of_panels_total: -1 } },
  { $limit: 3 }
])

// 5. States per region with 1,000+ solar installations
db.sunroof.aggregate([
  { $match: { existing_installs_count: { $gt: 1000 } } },
  { $group: { _id: "$region", stateCount: { $sum: 1 } } }
])

// 6. Region with lowest install-to-qualified ratio
db.sunroof.aggregate([
  { $group: {
      _id: "$region",
      totalInstalls: { $sum: "$existing_installs_count" },
      totalQualified: { $sum: "$count_qualified" }
  }},
  { $project: { installRatio: { $divide: ["$totalInstalls", "$totalQualified"] } } },
  { $sort: { installRatio: 1 } },
  { $limit: 1 }
])

// 7. Top 3 Northeast states by carbon offset
db.sunroof.aggregate([
  { $match: { region: "Northeast" } },
  { $project: { _id: 0, state_name: 1, region: 1, carbon_offset_metric_tons: 1 } },
  { $sort: { carbon_offset_metric_tons: -1 } },
  { $limit: 3 }
])

// 8. State name initials with 4+ states
db.sunroof.aggregate([
  { $project: { initial: { $substr: ["$state_name", 0, 1] } } },
  { $group: { _id: "$initial", stateCount: { $sum: 1 } } },
  { $match: { stateCount: { $gte: 4 } } }
])
