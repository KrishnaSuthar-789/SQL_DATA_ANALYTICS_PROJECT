/*

---------------------------------------------------------------------------
Customer report 
---------------------------------------------------------------------------
Purpose:
	- This script creates a View in DatawarehouseAnalytics Data Base 
	  it contains report that combines key customer metrics and behaviors. 

Script includes:
	- Gather essential fields such as name, age and transactions details.
	- Segment customers into categories (VIP, Regular, New)
	- Aggregate customer level metrics such as: 
		Total orders,
		Total sales, 
		Total quantity purchased.
	- Calculate valuable KPIs such as: 
		Months since last order, 
		Average order value, 
		Average monthly spend.
---------------------------------------------------------------------------

*/

USE DatawarehouseAnalytics;
GO

-- Retrive core columns from tables 

CREATE OR ALTER VIEW customer_report AS
WITH cust_basic_details AS (
	SELECT f.order_number,
		f.product_key,
		f.order_date,
		f.sales,
		f.quantity,
		c.customer_key,
		c.customer_num,
		TRIM(CONCAT(c.first_name,' ',c.last_name)) AS customer_name,
		DATEDIFF(YEAR,birthdate,CURRENT_DATE) AS age
	FROM fact_sales f
	LEFT JOIN dim_customers c
	ON f.customer_key = c.customer_key
	WHERE order_date IS NOT NULL
),
-- aggeregating customer key metrics
customer_agg AS (
	SELECT
		customer_key,
		customer_num,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS cust_life_span_months
	FROM cust_basic_details
	GROUP BY 
		customer_key,
		customer_num,
		customer_name,
		age)
SELECT 
	customer_key,
	customer_num,
	customer_name,
	age,
	CASE 
		WHEN age < 20 THEN 'Below 20'
		WHEN age BETWEEN 20 AND 30 THEN '20s'
		WHEN age BETWEEN 30 AND 40 THEN '30s'
		WHEN age BETWEEN 40 AND 50 THEN '40s'
		ELSE 'Above 50'
	END AS age_group,
	CASE 
		WHEN cust_life_span_months >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN  cust_life_span_months >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS status,
	total_orders,
	total_sales,
	-- Calculating Average order value (AOV)
	CAST(
		total_sales / NULLIF(total_orders,0) AS DECIMAL(10,2)
		) AS average_order_value , 
	-- Calculating Average monthly spend 
	CASE 
		WHEN cust_life_span_months = 0 THEN total_sales
		ELSE CAST( 
			total_sales / cust_life_span_months AS DECIMAL(10,2)
			)
	END AS average_monthly_spend,
	total_quantity,
	total_products,
	last_order_date,
	cust_life_span_months,
	DATEDIFF(MONTH,last_order_date,CURRENT_DATE) AS months_since_order
FROM customer_agg
;
