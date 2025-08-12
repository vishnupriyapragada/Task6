use online_sales
/* =========================
   STEP 1: DATA CHECKS
   ========================= */
ALTER TABLE salesdata
CHANGE `ï»¿Order Line` `Order Line` INT;
-- 1.1 Check missing Order Dates or Sales
SELECT * 
FROM salesdata
WHERE `Order Date` IS NULL OR Sales IS NULL;

-- 1.2 Check duplicate rows (Order ID + Product ID + Sales)
SELECT `Order ID`, `Product ID`, Sales, COUNT(*) AS duplicate_count
FROM salesdata
GROUP BY `Order ID`, `Product ID`, Sales
HAVING COUNT(*) > 1;

-- 1.3 Check invalid or negative sales
SELECT *
FROM salesdata
WHERE Sales <= 0;

-- 1.4 Check for invalid date formats (non-date strings)
-- MySQL will throw an error if dates are invalid when converting
SELECT *
FROM salesdata
WHERE STR_TO_DATE(`Order Date`, '%Y-%m-%d') IS NULL;


/* =========================
   STEP 2: DATA CLEANING
   ========================= */

-- 2.1 Remove rows with missing critical fields
DELETE FROM salesdata
WHERE `Order Date` IS NULL OR Sales IS NULL;

-- 2.3 Remove negative or zero sales (if not handling returns separately)
DELETE FROM salesdata
WHERE Sales <= 0;

-- 2.4 Standardize date format to YYYY-MM-DD
UPDATE salesdata
SET `Order Date` = STR_TO_DATE(`Order Date`, '%m/%d/%Y');


/* =========================
   STEP 3: MONTHLY REVENUE & ORDER VOLUME ANALYSIS
   ========================= */

SELECT 
    YEAR(`Order Date`) AS order_year,
    MONTH(`Order Date`) AS order_month_number,
    MONTHNAME(`Order Date`) AS order_month_name,
    ROUND(SUM(Sales), 2) AS total_revenue,
    COUNT(DISTINCT `Order ID`) AS order_volume,
    ROUND(SUM(Sales) / COUNT(DISTINCT `Order ID`), 2) AS avg_order_value
FROM salesdata
GROUP BY order_year, order_month_number, order_month_name
ORDER BY order_year, order_month_number;

-- 1. Monthly Revenue & Order Volume (with Month Name in One Column)
SELECT 
    DATE_FORMAT(`Order Date`, '%M %Y') AS month_year,
    ROUND(SUM(Sales), 2) AS total_revenue,
    COUNT(DISTINCT `Order ID`) AS order_volume
FROM salesdata
GROUP BY month_year
ORDER BY STR_TO_DATE(month_year, '%M %Y');

-- 2. Yearly Revenue & Orders
SELECT 
    YEAR(`Order Date`) AS order_year,
    ROUND(SUM(Sales), 2) AS total_revenue,
    COUNT(DISTINCT `Order ID`) AS order_volume
FROM salesdata
GROUP BY order_year
ORDER BY order_year;

-- 3. Average Order Value per Month
SELECT 
    DATE_FORMAT(`Order Date`, '%M %Y') AS month_year,
    ROUND(SUM(Sales) / COUNT(DISTINCT `Order ID`), 2) AS avg_order_value
FROM salesdata
GROUP BY month_year
ORDER BY STR_TO_DATE(month_year, '%M %Y');

-- 4. Best Month in Each Year (by Revenue)
SELECT order_year, order_month_name, total_revenue
FROM (
    SELECT 
        YEAR(`Order Date`) AS order_year,
        MONTHNAME(`Order Date`) AS order_month_name,
        ROUND(SUM(Sales), 2) AS total_revenue,
        RANK() OVER (PARTITION BY YEAR(`Order Date`) ORDER BY SUM(Sales) DESC) AS rank_in_year
    FROM salesdata
    GROUP BY order_year, order_month_name
) ranked_months
WHERE rank_in_year = 1;

