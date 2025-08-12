Sales Trend Analysis Using Aggregation functions


Overview:


This project analyzes sales data to identify monthly trends, seasonal patterns, and revenue insights using SQL aggregation functions.

Steps Involved:

* Import Dataset into SQL database

* Data Cleaning – checked for missing values, corrected data types

* Aggregation Queries – calculated total revenue, order volume, and average order value

* Used EXTRACT(MONTH FROM OrderDate) and EXTRACT(YEAR FROM OrderDate) to group results.

* Calculated monthly revenue using SUM(Sales).

* Measured monthly order volume with COUNT(OrderID).

Key SQL Query:

SELECT 
    YEAR(order_date) AS order_year,
    MONTHNAME(order_date) AS order_month,
    ROUND(SUM(amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS order_volume,
    ROUND(SUM(amount) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM online_sales
GROUP BY order_year, order_month
ORDER BY order_year, MONTH(order_date);

Key Insights:

* Revenue & Order Volume Peaks: Certain months saw significantly higher sales activity.

* Seasonal Patterns: Both revenue and orders showed consistent trends during specific months.

* Business Implication: These findings can guide inventory planning, targeted promotions, and budget allocation.
