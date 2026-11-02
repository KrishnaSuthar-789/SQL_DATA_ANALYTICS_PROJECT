/*
**************************************************************
Using advance SQL techniques to further analyze the data 
**************************************************************
*/

USE DatawarehouseAnalytics;

/*
**************************************************************
-- Change ove time analysis
-- Tracking YoY revenue change/trend
**************************************************************
*/

SELECT YEAR(order_date) AS order_year, 
		SUM(sales) AS total_revenue,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(quantity) AS total_quantity_sold
FROM fact_sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

/*
**************************************************************
-- Tracking MoM revenue change/ Monthly Trends
**************************************************************
*/

SELECT MONTH(order_date) AS order_month, 
		SUM(sales) AS total_revenue,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(quantity) AS total_quantity_sold
FROM fact_sales 
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY order_month;

/*
**************************************************************
-- Cumulative Analysis
-- total sales over year and running total of sales over time 
**************************************************************
*/

SELECT order_year,
	total_sales,
	SUM(total_sales)OVER(
		ORDER BY order_year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS running_total_sales
FROM(
	SELECT  YEAR(order_date) AS order_year,
			SUM(sales) AS total_sales
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date)
	) t
;

/*
****************************************************************
-- total sales over year and moving average of sales over time
****************************************************************
*/

SELECT order_year,
	total_revenue,
	avg_price,
	AVG(avg_price)OVER(ORDER BY order_year) AS moving_average
FROM (
	SELECT YEAR(order_date) AS order_year,
		SUM(sales) AS total_revenue,
		AVG(sales) AS avg_price
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date)
)t;

/*
**************************************************************************
Performance analysis
**************************************************************************
- Analysing the yearly performance by comparing the 
  sales to previous year sales and Calculating 
  total_revenue vs previous_year_revenue, Difference and % difference 
**************************************************************************
*/

WITH YoY_sales AS (
	SELECT YEAR(order_date) AS order_year, 
			SUM(sales) AS current_year_revenue,
			LAG(SUM(sales)) OVER(
				 ORDER BY YEAR(order_date)
				) previous_year_revenue
	FROM fact_sales 
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date)
)
SELECT order_year,
		current_year_revenue,
		previous_year_revenue,
		(current_year_revenue - previous_year_revenue) AS total_diff,
		((current_year_revenue - previous_year_revenue)/ previous_year_revenue)*100 AS '% diff'
FROM YoY_sales;

/* 
**************************************************************************
Analysing the yearly perfromance of products with 
its previous year sales and overall average of the product 
**************************************************************************
*/

WITH sales_summary AS (
	SELECT YEAR(s.order_date) AS order_year,
			p.product_name,
			SUM(s.sales) AS total_sales
	FROM fact_sales s 
	JOIN dim_products p 
	ON s.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(s.order_date), p.product_name
	)
SELECT order_year, 
		product_name,
		total_sales,
		CAST(
			AVG(total_sales)OVER(PARTITION BY product_name ORDER BY order_year)
			AS DECIMAL (10,2)) AS avgerage,
		LAG(total_sales)OVER(PARTITION BY product_name ORDER BY order_year) previous_year_sales
FROM sales_summary
;

/* 
**************************************************************************
Analysing the difference between total yearly sales and average
**************************************************************************
*/

WITH sales_summary AS (
	SELECT YEAR(s.order_date) AS order_year,
			p.product_name,
			SUM(s.sales) AS total_sales
	FROM fact_sales s 
	JOIN dim_products p 
	ON s.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(s.order_date), p.product_name
	)
SELECT  order_year,
		product_name,
		total_sales,
		CAST(AVG(total_sales)OVER(PARTITION BY product_name) AS DECIMAL(10,2)) AS avg_sales,
		total_sales - AVG(total_sales)OVER(PARTITION BY product_name) AS avg_diff,
		CASE 
			WHEN total_sales - AVG(total_sales)OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
			WHEN total_sales - AVG(total_sales)OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
			ELSE 'Avg'
		END AS avg_change
FROM sales_summary ;

/*
******************************************************************
Part to whole Analysis 
******************************************************************
- Analysing the category that contributed the most to total sales  
*/

WITH sales_summary AS (
	SELECT p.category,
			SUM(s.sales) AS total_sales
	FROM dim_products p
	JOIN fact_sales s 
	ON p.product_key = s.product_key 
	GROUP BY p.category
)

SELECT category,
		total_sales,
		SUM(total_Sales)OVER() AS overall_sales,
		CONCAT(
			(total_sales / SUM(total_Sales)OVER()) * 100,'%'
			) AS total_contro_percent
FROM sales_summary
ORDER BY total_contro_percent DESC;

/* 
************************************************************
Analysing the products that brings most customers and 
their contribution to total_customers 
************************************************************
*/

WITH customer_summary AS (
	SELECT  p.product_name,
			COUNT(DISTINCT s.customer_key) AS total_customers
	FROM dim_products p
	JOIN fact_sales s 
	ON p.product_key = s.product_key
	GROUP BY p.product_name
)

SELECT  product_name,	
		total_customers, 
		SUM(total_customers)OVER() overall_customers,
		CONCAT(
			ROUND((CAST(total_customers AS FLOAT)/SUM(total_customers)OVER()) * 100,2),'%'
			) AS product_contribution_customers
FROM customer_summary
ORDER BY product_contribution_customers DESC;

/*
************************************************************
Data Segmentation
************************************************************
- Segmenting products into cost range
  Counting how many products fall into each range 
*/

WITH product_cost_range AS (
	SELECT product_name,
			product_key,
			cost,
			CASE 
				WHEN cost < 100 THEN 'Below 100'
				WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
				WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
				ElSE 'Above 1000'
			END cost_range
	FROM dim_products)

SELECT cost_range,
		COUNT(product_key) total_counts
FROM product_cost_range
GROUP BY cost_range;

/* Grouping customers based on their spending behaviour 
	Flagging them based on customer's history and spending 
		- VIP : 12 month of history and 5000+ spend 
		- Regular : 12 month of history but < 5000 spend 
		- New : customer with lifespan of less than 12 months, 
	Then finding the total number of customers in each group */ 

WITH customer_history AS (
	SELECT 
	c.customer_key,
	SUM(f.sales) AS total_spend,
	MIN(f.order_date) AS first_order,
	MAX(f.order_date) AS last_order
	FROM dim_customers c
	JOIN fact_sales f
	ON c.customer_key = f.customer_key 
	GROUP BY c.customer_key),
customer_status AS (
	SELECT 
	customer_key,
	total_spend,
	first_order,
	last_order,
	CASE WHEN DATEDIFF(MONTH,first_order,last_order) >= 12 AND total_spend > 5000 THEN 'VIP'
		WHEN  DATEDIFF(MONTH,first_order,last_order) >= 12 AND total_spend <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS status
	FROM customer_history)
SELECT 
status,
COUNT(customer_key) AS total_count 
FROM customer_status
GROUP BY status
ORDER BY total_count DESC
;
