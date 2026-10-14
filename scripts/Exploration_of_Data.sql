/*
**************************************************************
Exploring the Data
--------------------------------------------------------------
  Script Purpose: 
    - Explore the schemas and tables in the dataset
    - Explore the measures and dimension
    - Analysing the ranging and magnitude 

  SQL Function Used: 
    - Aggregate functions: SUM(), AVG(), COUNT()
    - GROUP BY, ORDER BY
    - WINDOW FUNCTIONS 
    - MIN(), MAX(), DATEDIFF()
    - TOP N
--------------------------------------------------------------

***************************************************************
*/

-- Explore all objects in the database 

USE DatawarehouseAnalytics; 
SELECT * FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA;

-- Explore all columns in the database 

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'dim_customers';

-- Explore all countries our customers comes from 

SELECT DISTINCT country
FROM dim_customers;

-- Explore all categories 

SELECT DISTINCT category,sub_category 
FROM dim_products;

-- Explore the date boundaries 

SELECT MIN(start_date) AS earliest_date,
		MAX(start_date) AS recent_date,
		DATEDIFF(YEAR,MIN(start_date),MAX(start_date)) AS total_years
FROM dim_products;

SELECT MIN(order_date) AS first_order, -- explore first order date and last orde date 
		MAX(order_date) AS last_order,
		DATEDIFF(
			YEAR,MIN(order_date),MAX(order_date)
			) AS total_years -- How many years of sales available
FROM fact_sales;

SELECT MIN(birthdate) AS oldest_customer, -- Exploring the birthdate of youngest and oldest customers
		MAX(birthdate)	AS youngest_customer,
		DATEDIFF(
			YEAR,MIN(birthdate),GETDATE()
			) AS oldest_customer_age, -- Exploring the age of youngest and oldest customers
		DATEDIFF(
			YEAR,MAX(birthdate),GETDATE()
			) AS youngest_customer_age
FROM dim_customers;

-- Total sales 
SELECT SUM(sales) AS total_sales
FROM fact_sales;

-- Total items sold
SELECT SUM(quantity) AS total_quantity
FROM fact_sales;

-- Average selling price 
SELECT AVG(price) AS average_price
FROM fact_sales;

-- Total Number of orders

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM fact_sales;

-- Total number of products 

SELECT COUNT(DISTINCT product_key) AS total_products
FROM fact_sales; -- total number of products we had sold

SELECT COUNT(DISTINCT product_name) AS total_products
FROM dim_products; -- total number of products we have

-- Total number of customers 

SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM fact_sales; -- total number of customers who placed orders

SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM dim_customers; -- total number of customers registered 

-- Generating a report that shows all key metrics of a business

SELECT 'Total Sales' AS measure_name,SUM(sales) AS measure_value FROM fact_sales
UNION 
SELECT 'Total quantity' AS measure_name,SUM(quantity) AS measure_value FROM fact_sales
UNION 
SELECT 'Average Price' AS measure_name,AVG(price) AS measure_value FROM fact_sales
UNION 
SELECT 'Total orders' AS measure_name ,COUNT(DISTINCT order_number) AS measure_values FROM fact_sales 
UNION 
SELECT 'Total orders' AS measure_name ,COUNT(DISTINCT order_number) AS measure_values FROM fact_sales
UNION
SELECT 'Total No. products' AS measure_name,COUNT(DISTINCT product_key) AS measure_value FROM fact_sales
UNION
SELECT 'Total No. customers' AS measure_name,COUNT(DISTINCT customer_key) AS measure_value FROM fact_sales;

-- Magnitude Analysis 

-- Total number of registered customers by country, gender 

SELECT country,COUNT(DISTINCT customer_key) AS total_customers -- customers by country
FROM dim_customers 
GROUP BY country 
ORDER BY total_customers DESC;

SELECT gender, COUNT(DISTINCT customer_key) AS total_customers -- customers by gender
FROM dim_customers 
GROUP BY gender
ORDER BY total_customers DESC;

-- Total number of sold products by category 

SELECT p.category,COUNT(DISTINCT s.product_key) AS total_products_sold
FROM fact_sales s 
JOIN dim_products p 
ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_products_sold DESC ;

-- Average cost in each category 

SELECT category, CAST(AVG(cost) AS DECIMAL(10,2)) AS average_cost -- rounding up at 2 decimals
FROM dim_products 
GROUP BY category 
ORDER BY 
	CASE 
		WHEN category IS NOT NULL THEN 1 
		ELSE 2 
	END,
	average_cost DESC; -- sorted null at end 

-- Total revenue generated for each category 

SELECT p.category, SUM(s.sales) AS total_revenue
FROM fact_sales s
JOIN dim_products p 
ON s.product_key = p.product_key 
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Total revenue geneated by each country

SELECT c.country, SUM(s.sales) AS total_revenue
FROM fact_sales s
JOIN dim_customers c
ON s.customer_key = c.customer_key 
GROUP BY c.country 
ORDER BY total_revenue DESC;

-- Distribution of sold products across countries 

SELECT c.country, SUM(s.quantity) AS total_items
FROM fact_sales s
JOIN dim_customers c 
ON s.customer_key = c.customer_key 
GROUP BY c.country
ORDER BY total_items DESC;

-- Analysing top performers

-- Total revenue generated by customers Top 10

SELECT	TOP 10 c.customer_key,
		c.first_name,
		c.last_name,
		SUM(s.sales) AS total_revenue
FROM dim_customers c 
JOIN fact_sales s 
ON c.customer_key = s.customer_key 
GROUP BY c.customer_key,
		c.first_name,
		c.last_name
ORDER BY total_revenue DESC;

-- Top 10 customers with highest orders 

SELECT TOP 10 c.customer_key,
		c.first_name,
		c.last_name,
		COUNT(DISTINCT s.order_number) AS total_orders 
FROM dim_customers c 
JOIN fact_sales s 
ON c.customer_key = s.customer_key
GROUP BY c.customer_key,
		c.first_name,
		c.last_name
ORDER BY total_orders DESC;


-- bottom 10 customers who has placed least orders 

SELECT TOP 10 c.customer_key,
		c.first_name,
		c.last_name,
		COUNT(DISTINCT s.order_number) AS total_orders 
FROM dim_customers c 
JOIN fact_sales s 
ON c.customer_key = s.customer_key
GROUP BY c.customer_key,
		c.first_name,
		c.last_name
ORDER BY total_orders;

-- Top 5 products generating highest revenue 

-- using top n 
SELECT TOP 5 p.product_name, SUM(s.sales) AS total_sales 
FROM dim_products p
JOIN fact_sales s 
ON p.product_key = s.product_key 
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- using rank window function 
SELECT *
FROM (
SELECT p.product_name, SUM(s.sales) total_revenue,
		RANK()OVER(ORDER BY SUM(s.sales) DESC) rnk
FROM dim_products p 
JOIN fact_sales s 
ON p.product_key = s.product_key
GROUP BY p.product_name) t
WHERE rnk <= 5;

-- bottom 5 worst perfroming products 
-- Using top n 
SELECT TOP 5 p.product_name, SUM(s.sales) AS total_sales 
FROM dim_products p
JOIN fact_sales s 
ON p.product_key = s.product_key 
GROUP BY p.product_name
ORDER BY total_sales;

-- using rank window function 
SELECT *
FROM (
SELECT p.product_name, SUM(s.sales) total_revenue,
		RANK()OVER(ORDER BY SUM(s.sales)) rnk
FROM dim_products p 
JOIN fact_sales s 
ON p.product_key = s.product_key
GROUP BY p.product_name) t
WHERE rnk <= 5;

