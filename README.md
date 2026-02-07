# 📊 Zepto Product, Pricing & Inventory Analysis (SQL + Python)

## Overview
This project analyzes **Zepto product data** using **SQL and Python** to identify
pricing inconsistencies, revenue opportunities, and inventory risks.
The analysis reflects a real-world **data analyst workflow**, with SQL used for
data validation and business logic, and Python used for visualization.

---

## 1. Business Objective
Analyze Zepto product data to identify:
1. Pricing inconsistencies  
2. Revenue optimization opportunities  
3. Inventory risks  
4. Discount-driven customer behavior  

---

## 2. Dataset Overview

- **Source:** Kaggle (originally scraped from Zepto’s public product listings)
- **Type:** E-commerce product catalog snapshot
- **Granularity:** One row per SKU (Stock Keeping Unit)

Each record represents a unique SKU. Duplicate product names exist because the same product
can appear with different package sizes, weights, discounts, or category placements—a
pattern commonly observed in real-world e-commerce catalogs.

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

## 5. Pricing Consistency & Discount Validation
- Derived discount percentage vs stored `discountPercent`  
- Selling price recalculated from discount vs stored selling price  

**Observation:**
- Discount percentage is consistent when derived from prices  
- Deviations occur when recalculating selling price  
- `mrp` and `discountedSellingPrice` are treated as **source-of-truth fields**,  
  while `discountPercent` is rounded and informational  

---

## 6. Ad-Hoc Analytical Queries
- **Q1:** Top 10 best-value products by discount percentage  
- **Q2:** High-MRP products currently out of stock  
- **Q3:** Estimated revenue per category  
- **Q4:** Premium products with low discounts  
- **Q5:** Categories with highest average discount  
- **Q6:** Best value products by price per gram (≥100g)  
- **Q7:** Weight-based product segmentation (Small, Medium, Bulk packs)  
- **Q8:** Total inventory weight per category  

---

## 7. Analytical Views (Portfolio Outputs)

- **View 1: `pricing_inconsistencies`**  
  - Strict vs tolerant validation of pricing consistency  

- **View 2: `product_category`**  
  - Canonical category per product to prevent double counting  

- **View 3: `revenue_opportunity`**  
  - Actual vs potential revenue (at MRP)  
  - Discount cost per category  

- **View 4: `inventory_risk`**  
  - Out-of-stock product counts  
  - Estimated revenue loss due to stockouts  

---

## 8. Key Insights
- **Pricing:** `discountPercent` is rounded; rely on `mrp` and
  `discountedSellingPrice` for accuracy  
- **Revenue:** Several categories show significant gaps between
  actual and potential revenue due to discounting  
- **Inventory:** Stockouts in high-value categories represent measurable
  lost revenue  
- **Segmentation:** Weight-based grouping highlights customer
  pack-size preferences  

---

## 9. Tech Stack
- **Database:** PostgreSQL  
- **Analysis:** SQL (CTEs, Views, Aggregations)  
- **Visualization:** Python (`pandas`, `matplotlib`)  
- **Documentation:** Jupyter Notebook + Markdown  

---

## 10. Portfolio Value
This project demonstrates:
- Strong SQL data exploration, cleaning, and validation skills  
- Business-aligned analytical thinking  
- Use of SQL views as a reusable analytics layer  
- Clear visualization and insight communication  

---

## 11. Next Steps
- Extend analysis with **time-series sales data** for demand forecasting  
- Build **interactive Power BI dashboard** for real-time monitoring 
- Add additional Python notebooks for deeper exploratory analysis  

---

## Acknowledgement

This project was inspired by a public tutorial using a Zepto e-commerce
dataset. While the dataset source and initial idea were shared, all SQL
analysis, validation logic, analytical views, and Python visualizations
were independently developed and extended as part of my portfolio work.

---

**Author:** Tejasvi Bhavsar  
Aspiring Data Analyst | SQL - Python - Analytics
