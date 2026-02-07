/*====================================================
PROJECT: Zepto Product, Pricing & Inventory Analysis
AUTHOR: Tejasvi Bhavsar
DATABASE: PostgreSQL
======================================================

BUSINESS OBJECTIVE:
Analyze Zepto product data to identify:
1. Pricing inconsistencies
2. Revenue optimization opportunities
3. Inventory risks
4. Discount-driven customer behavior

====================================================*/

/*====================================================
1. DATA EXPLORATION & QUALITY CHECKS
   (Read-only validation queries)
====================================================*/

-- Total number of records
SELECT COUNT(*) AS total_rows
FROM zepto;

-- Sample data
SELECT *
FROM zepto
LIMIT 10;

-- Column-wise NULL analysis
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE category IS NULL) AS category_nulls,
    COUNT(*) FILTER (WHERE name IS NULL) AS name_nulls,
    COUNT(*) FILTER (WHERE mrp IS NULL) AS mrp_nulls,
    COUNT(*) FILTER (WHERE discountPercent IS NULL) AS discount_percent_nulls,
    COUNT(*) FILTER (WHERE availableQuantity IS NULL) AS available_qty_nulls,
    COUNT(*) FILTER (WHERE discountedSellingPrice IS NULL) AS discounted_price_nulls,
    COUNT(*) FILTER (WHERE weightInGms IS NULL) AS weight_nulls,
    COUNT(*) FILTER (WHERE outOfStock IS NULL) AS out_of_stock_nulls
FROM zepto;

-- Rows containing any NULL values
SELECT *
FROM zepto
WHERE category IS NULL
   OR name IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR outOfStock IS NULL;

-- Distinct product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- Stock distribution
SELECT outOfStock, COUNT(*) AS sku_count
FROM zepto
GROUP BY outOfStock;

-- Duplicate product names across SKUs
SELECT
    name,
    COUNT(sku_id) AS sku_count
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY sku_count DESC;

-- Discounted price greater than MRP (invalid pricing)
SELECT *
FROM zepto
WHERE discountedSellingPrice > mrp;

-- Invalid or zero weights
SELECT category, name, weightInGms
FROM zepto
WHERE weightInGms <= 0;

-- Categories with missing or zero weight products
SELECT
    category,
    COUNT(*) AS missing_weight_count
FROM zepto
WHERE weightInGms <= 0
GROUP BY category
ORDER BY missing_weight_count DESC;


/*====================================================
2. DATA CLEANING & STANDARDIZATION
====================================================*/

-- Preview invalid price rows before deletion
SELECT *
FROM zepto
WHERE mrp <= 0
   OR discountedSellingPrice <= 0;

-- Delete confirmed invalid pricing records
DELETE FROM zepto
WHERE mrp <= 0
   OR discountedSellingPrice <= 0;

-- Detect prices stored in paise instead of rupees
SELECT COUNT(*) AS paise_rows
FROM zepto
WHERE mrp >= 100;

-- Convert paise to rupees
UPDATE zepto
SET
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0
WHERE mrp >= 100;

-- Validate conversion
SELECT mrp, discountedSellingPrice
FROM zepto
ORDER BY mrp DESC
LIMIT 10;


/*====================================================
3. PRICING CONSISTENCY & DISCOUNT VALIDATION
====================================================*/

-- Check 1: discount percentage derived from prices
SELECT
    sku_id,
    name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent,
    ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2) AS derived_discount_percent
FROM zepto
WHERE ABS(
    discountPercent -
    ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2)
) > 1;

-- Check 2: Selling price mismatch (discount-derived vs stored)
SELECT
  sku_id,
  name,
  category,
  mrp,
  discountPercent,
  discountedSellingPrice,
  ROUND(mrp * (1 - discountPercent / 100), 2) AS calculated_selling_price
FROM zepto
WHERE ABS(
    discountedSellingPrice -
    ROUND(mrp * (1 - discountPercent / 100), 2)
) > 1; 	

-- Observation:
-- Discount percentage is consistent when derived from prices.
-- However, recalculating selling price from discount percentage
-- shows deviations, indicating that MRP and selling price are
-- source-of-truth fields, while discountPercent is rounded or
-- informational.


/*====================================================
4. AD-HOC ANALYTICAL QUERIES
====================================================*/

-- Q1: Top 10 best-value products by discount percentage
SELECT
    sku_id,
    name,
    mrp,
    discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2: High-MRP products that are out of stock
SELECT
    name,
    mrp
FROM zepto
WHERE outOfStock = TRUE
  AND mrp > 300
ORDER BY mrp DESC;

-- Q3: Estimated revenue per category
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4: Premium products with low discounts
SELECT
    name,
    mrp,
    discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC;

-- Q5: Categories with highest average discount
SELECT
    category,
    ROUND(AVG(discountPercent), 2) AS avg_discount_percent
FROM zepto
GROUP BY category
ORDER BY avg_discount_percent DESC
LIMIT 5;

-- Q6: Best value products by price per gram (>=100g)
SELECT
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice / weightInGms, 4) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7: Weight-based product segmentation
SELECT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 500 THEN 'Small Pack'
        WHEN weightInGms < 2000 THEN 'Medium Pack'
        ELSE 'Bulk Pack'
    END AS weight_category
FROM zepto;

-- Q8: Total inventory weight per category
SELECT
    category,
    SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;


/*====================================================
5. ANALYTICAL VIEWS (FINAL PORTFOLIO OUTPUTS)
====================================================*/

-- View 1: Pricing inconsistencies
CREATE VIEW pricing_inconsistencies AS
SELECT
    sku_id,
    name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent,
    ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2) AS calculated_discount_percent,
    
    -- Strict check
    CASE 
        WHEN discountPercent = ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2) 
            THEN 'Consistent'
        ELSE 'Mismatch'
    END AS strict_check,
    
    -- Tolerant check
    CASE 
        WHEN ABS(discountPercent - ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2)) <= 1 
            THEN 'Consistent'
        ELSE 'Mismatch'
    END AS tolerant_check

FROM zepto;


-- View 2: Canonical category per product
-- Purpose: Prevent double counting when products appear in multiple categories
CREATE OR REPLACE VIEW product_category AS
SELECT
    name AS product_name,
    MIN(category) AS category
FROM zepto
GROUP BY name;


-- View 3: Revenue opportunity analysis
-- Business Insight:
-- Compares actual revenue vs potential revenue (at MRP)
CREATE OR REPLACE VIEW revenue_opportunity AS
WITH product_revenue AS (
    SELECT
        z.name AS product_name,
        pc.category,
        SUM(z.discountedSellingPrice * z.availableQuantity) AS actual_revenue,
        SUM(z.mrp * z.availableQuantity) AS potential_revenue,
        SUM((z.mrp - z.discountedSellingPrice) * z.availableQuantity) AS discount_cost
    FROM zepto z
    JOIN product_category pc
      ON z.name = pc.product_name
    WHERE z.outOfStock = FALSE
    GROUP BY z.name, pc.category
)
SELECT
    category,
    SUM(actual_revenue) AS actual_revenue,
    SUM(potential_revenue) AS potential_revenue,
    SUM(discount_cost) AS discount_cost
FROM product_revenue
GROUP BY category
ORDER BY actual_revenue DESC;


-- View 4: Inventory risk analysis
-- Business Insight:
-- Estimates potential revenue loss due to out-of-stock products
CREATE OR REPLACE VIEW inventory_risk AS
SELECT
    pc.category,
    COUNT(DISTINCT z.name) FILTER (WHERE z.outOfStock = TRUE) AS out_of_stock_products,
    SUM(z.availableQuantity) AS total_available_units,
    SUM(
        CASE
            WHEN z.outOfStock = TRUE
            THEN z.discountedSellingPrice * z.availableQuantity
            ELSE 0
        END
    ) AS estimated_revenue_loss
FROM zepto z
JOIN product_category pc
  ON z.name = pc.product_name
GROUP BY pc.category
ORDER BY estimated_revenue_loss DESC;
