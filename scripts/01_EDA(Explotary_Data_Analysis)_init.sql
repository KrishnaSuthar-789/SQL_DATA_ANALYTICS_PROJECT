/*
*****************************************************************************************
CREATING DATABASE AND TABLES
--------------------------------------------------------------
  Script Purpose: 
    - This script will drop the data base DatawarehouseAnalytics if
      already exist then create a new database named DatawarehouseAnalytics.
    - It will utilize the views created in ETL project and create end user 
      table from them ready for analysis and creating reports.

Warning: 
	This script will drop the entire data base, backup all files before running the script.
--------------------------------------------------------------

*****************************************************************************************
*/

-- Creating the database DatawarehouseAnalytics

USE master;

-- Droping the table if already exists,

DROP DATABASE IF EXISTS DatawarehouseAnalytics;
CREATE DATABASE DatawarehouseAnalytics;
GO
  
-- creating table and inserting the data from Datawarehouse view into the table 

USE DatawarehouseAnalytics;

-- creating fact_sales table

IF OBJECT_ID('fact_sales','U') IS NOT NULL
DROP TABLE fact_sales
CREATE TABLE fact_sales (
	order_number VARCHAR(50),
	product_key INT,
	customer_key INT,
	order_date DATE,
	shipping_date DATE,
	due_date DATE,
	sales DECIMAL(10,2),
	quantity INT,
	price DECIMAL(10,2)
);
GO
INSERT INTO fact_sales
SELECT *
FROM Datawarehouse.gold.fact_sales;

-- creating dim_customers table

IF OBJECT_ID('dim_customers','U') IS NOT NULL
DROP TABLE dim_customers
CREATE TABLE dim_customers (
	customer_key INT,
	customer_id INT,
	customer_num VARCHAR(50),
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	birthdate DATE,
	country VARCHAR(50),
	maritial_status VARCHAR(20),
	gender VARCHAR(20),
	create_date DATE
);
GO
INSERT INTO dim_customers
SELECT *
FROM Datawarehouse.gold.dim_customers;

-- creating dim_products table

IF OBJECT_ID('dim_products','U') IS NOT NULL
DROP TABLE dim_products
CREATE TABLE dim_products (
	product_key INT,
	product_id INT,
	product_number VARCHAR(20),
	category_id VARCHAR(10),
	product_name VARCHAR(50),
	sub_category VARCHAR(50),
	category VARCHAR(50),
	maintenance VARCHAR(20),
	cost DECIMAL(10,2),
	product_line VARCHAR(20),
	start_date DATE
);
GO
INSERT INTO dim_products
SELECT *
FROM Datawarehouse.gold.dim_products;
