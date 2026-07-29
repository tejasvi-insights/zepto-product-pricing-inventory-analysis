# 🛒 Zepto Product, Pricing & Inventory Analysis (SQL + Python)

**Data Quality Investigation | Anomaly Detection | Revenue Analysis**

---

## Overview

Built an end-to-end product catalog analysis on **3,731 SKUs** from Zepto's e-commerce
platform to surface pricing anomalies, revenue leakage, and inventory risks using
PostgreSQL and Python.

This project reflects a real-world **data analyst workflow**: SQL for validation,
anomaly detection, and business logic; Python for visualization and insight communication.

---

## 1. Business Objective

Investigate Zepto's product catalog data to answer:
1. Are there pricing inconsistencies or data integrity issues affecting revenue reporting?
2. Where are the revenue optimization opportunities?
3. Which inventory gaps represent measurable revenue risk?
4. What purchasing behavior patterns can be detected from discount and pricing data?

---

## 2. Dataset Overview

- **Source:** Kaggle (originally scraped from Zepto's public product listings)
- **Type:** E-commerce product catalog snapshot
- **Scale:** 3,731 SKUs across multiple categories
- **Granularity:** One row per SKU (Stock Keeping Unit)

Each record represents a unique SKU. Duplicate product names exist because the same
product can appear with different package sizes, weights, discounts, or category
placements — a pattern commonly observed in real-world e-commerce catalogs.

### Columns
- `sku_id` – Unique identifier for each product entry (synthetic primary key)
- `name` – Product name as displayed in the app
- `category` – Product category (e.g., Fruits, Snacks, Beverages)
- `mrp` – Maximum Retail Price (converted from paise to ₹)
- `discountPercent` – Discount applied on MRP
- `discountedSellingPrice` – Final selling price after discount (₹)
- `availableQuantity` – Units available in inventory
- `weightInGms` – Product weight in grams
- `outOfStock` – Boolean flag indicating stock availability
- `quantity` – Units per package (mixed with grams for loose produce)

---

## 3. Data Exploration & Quality Checks

- Total record count and sample data preview
- Column-wise NULL analysis
- Detection of duplicate product names across SKUs
- Invalid pricing checks:
  - Discounted price > MRP
  - MRP ≤ 0
- Zero or missing weights flagged by category
- Stock distribution analysis

---

## 4. Data Cleaning & Standardization

- Removal of invalid pricing records (MRP ≤ 0 or selling price ≤ 0)
- Conversion of prices stored in **paise → rupees**
- Validation of corrected pricing fields

---

## 5. Pricing Consistency & Anomaly Detection

- Derived discount percentage vs stored `discountPercent`
- Selling price recalculated from discount vs stored selling price
- **1,877 of 3,731 SKUs (~50%) flagged as pricing mismatches under strict validation**

**Root Cause Finding:**
Traced a high mismatch rate to **rounding in stored discount percentages** rather than data corruption. Determined that a bulk correction would introduce errors, while clarifying the business rule was the appropriate resolution.


**Key Observation:**
- `mrp` and `discountedSellingPrice` are the **source-of-truth fields**
- `discountPercent` is rounded and informational — deviations here are expected
- True anomalies are where selling price cannot be reconciled with MRP even within tolerance

---

## 6. Category Mapping & Double-Counting Detection

- Identified the same products mapped to **multiple categories**
- This causes **double-counting in category-level revenue** — a silent but significant
  reporting error
- Resolved using **canonical product-category mapping** in SQL to ensure each product
  is counted once in revenue aggregations

---

## 7. Ad-Hoc Analytical Queries

- **Q1:** Top 10 best-value products by discount percentage
- **Q2:** High-MRP products currently out of stock
- **Q3:** Estimated revenue per category
- **Q4:** Premium products with low discounts
- **Q5:** Categories with highest average discount
- **Q6:** Best value products by price per gram (≥100g)
- **Q7:** Weight-based product segmentation (Small, Medium, Bulk packs)
- **Q8:** Total inventory weight per category

---

## 8. Analytical Views (Portfolio Outputs)

Built **4 reusable SQL views** as a persistent analytics layer:

| View | Purpose |
|------|---------|
| `pricing_inconsistencies` | Strict vs tolerant validation of pricing consistency |
| `product_category` | Canonical category mapping to prevent revenue double-counting |
| `revenue_opportunity` | Actual vs potential revenue (at MRP) — discount cost per category |
| `inventory_risk` | Out-of-stock counts and estimated revenue loss due to stockouts |

---

## 9. Key Insights

| Area | Finding |
|------|---------|
| **Pricing Anomalies** | ~50% mismatch rate traced to discount rounding — needs business rule clarification, not a data fix |
| **Category Mapping** | Product duplication across categories overstates segment revenue without canonical mapping |
| **Inventory Risk** | ₹39018.50 potential revenue loss across 9 categories due to stockouts |
| **Discount Leakage** | ₹79,107 discount cost in Chocolates & Candies — highest gap between actual vs potential revenue |
| **Highest Risk Segments** | Chocolates & Candies and Cooking Essentials show highest combined stockout loss and discount leakage |

---

## 10. Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL | Data validation, anomaly detection, analytical views |
| SQL | CTEs, window functions, aggregations, data quality queries |
| Python (Pandas) | Data cleaning, transformation |
| Python (Matplotlib) | Visualization |
| Jupyter Notebook | Analysis documentation |
| Git | Version control |

---

## 11. Portfolio Value

This project demonstrates:
- SQL-driven data quality investigation on a real-world e-commerce dataset
- Root cause analysis mindset — distinguishing rounding artifacts from genuine data errors
- Business-aligned thinking — anomalies framed in terms of revenue impact, not just technical flags
- Reusable SQL views as a scalable analytics layer
- Clear insight communication with quantified, actionable recommendations

---

## 12. Next Steps

- Extend analysis with time-series sales data for demand forecasting
- Build interactive Power BI dashboard for pricing and inventory monitoring
- Add deeper Python EDA notebooks for category-level trend analysis

---

## Acknowledgement

This project was inspired by a public tutorial using a Zepto e-commerce dataset.
While the dataset source and initial idea were shared, all SQL analysis, validation
logic, analytical views, and Python visualizations were independently developed
and extended as part of my portfolio work.

---

**Author:** Tejasvi Bhavsar
Data Analyst | SQL • Python • Power BI
