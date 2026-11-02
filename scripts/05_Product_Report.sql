/*
**************************************************************************************************
--------------------------------------------------------------------------------------------
Product Report 
--------------------------------------------------------------------------------------------
Purpose:
	- This script creates a View in DatawarehouseAnalytics Data Base 
	  it contains report that combines key product metrics and behaviors. 

Script includes:
	- Gather essential fields such as name, category, subcategory and cost.
	- Segment products by revenue to identify High Performance, Mid Range, Low Performance.
	- Aggregate product level metrics such as: 
		Total orders,
		Total sales, 
		Total quantity sold, 
		Total customers, 
		lifespan of product (months).
	- Calculate valuable KPIs such as: 
		Months since last sold, 
		Average order revenue (AOR), 
		Average monthly revenue.
--------------------------------------------------------------------------------------------
**************************************************************************************************
*/

USE DatawarehouseAnalytics;
GO

/*
**********************************************
Retrive core columns from tables 
**********************************************
*/

CREATE OR ALTER VIEW product_report AS 
	WITH product_basic_info AS (
		SELECT 
			f.order_number,
			f.product_key,
			f.customer_key,
			f.sales,
			f.quantity,
			p.product_name,
			p.sub_category,
			p.category,
			f.order_date,
			p.start_date
		FROM fact_sales f
		LEFT JOIN dim_products p 
		ON f.product_key = p.product_key),
/*
**********************************************
Aggregating product key metrics
**********************************************
*/
	product_agg AS (
		SELECT 
			product_name,
			sub_category,
			category,
			DATEDIFF(MONTH,MIN(start_date),MAX(order_date)) AS lifespan_months,
			DATEDIFF(MONTH,MAX(order_date),CURRENT_DATE) AS months_since_last_order ,
			COUNT(DISTINCT order_number) AS total_orders,
			SUM(sales) AS total_sales,
			SUM(quantity) AS total_quantity_sold,
			COUNT(DISTINCT customer_key) AS total_customers
		FROM product_basic_info
		GROUP BY 
			product_name,
			sub_category,
			category)

	SELECT 
		product_name,
		sub_category,
		category,
		-- Segmenting the product by revenue into: High Performer, Mid Range, Low Performer
		CASE 
			WHEN total_sales > 50000 THEN 'High Performer'
			WHEN total_Sales >= 10000 THEN 'Mid Range'
			ELSE 'Low Performer'
		END AS product_segment,
		lifespan_months,
		months_since_last_order,
		total_orders,
		total_sales,
		-- Calculating Average Order Revenue (AOR)
		CASE -- Handling div with 0 error
			WHEN total_orders = 0 THEN total_sales
			ELSE CAST(
			total_sales/total_orders AS DECIMAL(10,2))
		END AS Average_Order_Revenue,
		-- Calculating Average Monthly Revenue
		CASE 
			WHEN lifespan_months = 0 THEN total_sales
			ELSE CAST (
				total_sales / lifespan_months AS DECIMAL(10,2))
		END AS Avg_monthly_revenue,
		total_quantity_sold,
		total_customers
	FROM product_agg;
