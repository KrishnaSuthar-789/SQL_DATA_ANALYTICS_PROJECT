# SQL Exploratory Data Analysis & Business Reporting

## Project Overview

This project focuses on performing Exploratory Data Analysis (EDA) using Microsoft SQL Server and T-SQL to understand sales performance, customer behaviour, and product trends.

Using fact and dimension tables from a data warehouse, I created a separate analytics database and explored the data through SQL queries. The analysis covers business performance, revenue trends, customer segmentation, product performance, and key business metrics.

The goal was to turn raw business data into meaningful insights and reusable datasets for reporting.

## Tools & Technologies Used

- **Microsoft SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **Common Table Expressions (CTEs)**
- **Subqueries and Joins**
- **Aggregate Functions**
- **Window Functions**
- **SQL Views**

## Analysis Performed

### 1. Database Exploration & Data Profiling

- Explored database tables, columns, and data structures.
- Identified distinct values and examined date ranges.
- Used aggregate functions to understand the overall distribution of business data.

### 2. Customer & Product Analysis

- Analysed customer distribution by country and gender.
- Evaluated product sales and revenue across different categories.
- Identified top-performing and lowest-performing customers and products.
- Examined purchasing behaviour and customer contribution to overall revenue.

### 3. Sales & Revenue Trend Analysis

- Analysed yearly and monthly sales trends.
- Performed Year-over-Year (YoY) revenue comparisons.
- Calculated running totals and moving averages using window functions.
- Compared product performance against previous periods and average performance.

### 4. Customer & Product Segmentation

- Segmented customers into VIP, Regular, and New categories based on purchasing behaviour and spending.
- Classified products into cost ranges and revenue segments.
- Analysed customer and product contribution to total revenue.
- Used CASE statements to categorize business performance.

### 5. Business Reporting Views

Created reusable SQL views for customer and product reporting.

**Customer Report included:**
- Total orders and sales
- Total quantity and products purchased
- Average Order Value (AOV)
- Average monthly spending
- Customer age groups and purchasing status
- Last order date and months since last order

**Product Report included:**
- Total revenue and quantity sold
- Total orders and unique customers
- Average order revenue
- Average monthly revenue
- Product lifespan and revenue segments
- Months since last sale

## SQL Concepts Demonstrated

- SELECT, WHERE, GROUP BY, ORDER BY
- INNER JOIN and LEFT JOIN
- Aggregate Functions (SUM, AVG, COUNT)
- Common Table Expressions (CTEs)
- Subqueries
- CASE Statements
- Window Functions (RANK, LAG, SUM OVER, AVG OVER)
- Date Functions
- Running Totals and Moving Averages
- Year-over-Year Analysis
- Data Segmentation
- SQL Views

## Key Skills Demonstrated

- Exploratory Data Analysis (EDA)
- SQL Query Writing
- Business Performance Analysis
- Customer Behaviour Analysis
- Product Performance Analysis
- Revenue Trend Analysis
- Customer & Product Segmentation
- Data Reporting and KPI Development
- Advanced SQL Techniques

## Table/data used in this project is loaded from the ETL Warehouse Project.
Check it out here : https://github.com/KrishnaSuthar-789/SQL_DATA_Warehouse_Project

## License

This project is licensed under the [MIT License](LICENSE).
