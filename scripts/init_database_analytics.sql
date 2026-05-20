/*
========================================================
Purpose:
- Creates the gold2 database if it does not exist
- Loads data from CSV files

CSV Files:
- gold_dim_customers.csv
- gold_dim_products.csv
- gold_fact_sales.csv
========================================================
*/

-- =====================================================
-- Create Database
-- =====================================================
CREATE DATABASE IF NOT EXISTS gold;

USE gold;

-- =====================================================
-- Create dim_customers Table
-- =====================================================
CREATE TABLE IF NOT EXISTS dim_customers (
    customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);

-- =====================================================
-- Create dim_products Table
-- =====================================================
CREATE TABLE IF NOT EXISTS dim_products (
    product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(255),
    category_id VARCHAR(50),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    maintenance VARCHAR(50),
    cost INT,
    product_line VARCHAR(50),
    start_date DATE
);

-- =====================================================
-- Create fact_sales Table
-- =====================================================
CREATE TABLE IF NOT EXISTS fact_sales (
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity INT,
    price INT
);

-- =====================================================
-- Load dim_customers
-- =====================================================
TRUNCATE TABLE dim_customers;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/datasets_analytics/gold_dim_customers.csv'
INTO TABLE dim_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @customer_key,
    @customer_id,
    @customer_number,
    @first_name,
    @last_name,
    @country,
    @marital_status,
    @gender,
    @birthdate,
    @create_date
)
SET
    customer_key    = NULLIF(@customer_key, ''),
    customer_id     = NULLIF(@customer_id, ''),
    customer_number = NULLIF(@customer_number, ''),
    first_name      = NULLIF(@first_name, ''),
    last_name       = NULLIF(@last_name, ''),
    country         = NULLIF(@country, ''),
    marital_status  = NULLIF(@marital_status, ''),
    gender          = NULLIF(@gender, ''),
    birthdate       = STR_TO_DATE(NULLIF(@birthdate,''), '%d-%m-%Y'),
    create_date     = STR_TO_DATE(NULLIF(@create_date,''), '%d-%m-%Y');

-- =====================================================
-- Load dim_products
-- =====================================================
TRUNCATE TABLE dim_products;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/datasets_analytics/gold_dim_products.csv'
INTO TABLE dim_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @product_key,
    @product_id,
    @product_number,
    @product_name,
    @category_id,
    @category,
    @subcategory,
    @maintenance,
    @cost,
    @product_line,
    @start_date
)
SET
    product_key    = NULLIF(@product_key, ''),
    product_id     = NULLIF(@product_id, ''),
    product_number = NULLIF(@product_number, ''),
    product_name   = NULLIF(@product_name, ''),
    category_id    = NULLIF(@category_id, ''),
    category       = NULLIF(@category, ''),
    subcategory    = NULLIF(@subcategory, ''),
    maintenance    = NULLIF(@maintenance, ''),
    cost           = NULLIF(@cost, ''),
    product_line   = NULLIF(@product_line, ''),
    start_date     = STR_TO_DATE(NULLIF(@start_date,''), '%d-%m-%Y');

-- =====================================================
-- Load fact_sales
-- =====================================================
TRUNCATE TABLE fact_sales;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/datasets_analytics/gold_fact_sales.csv'
INTO TABLE fact_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @order_number,
    @product_key,
    @customer_key,
    @order_date,
    @shipping_date,
    @due_date,
    @sales_amount,
    @quantity,
    @price
)
SET
    order_number  = NULLIF(@order_number, ''),
    product_key   = NULLIF(@product_key, ''),
    customer_key  = NULLIF(@customer_key, ''),
    order_date    = STR_TO_DATE(NULLIF(@order_date,''), '%d-%m-%Y'),
    shipping_date = STR_TO_DATE(NULLIF(@shipping_date,''), '%d-%m-%Y'),
    due_date      = STR_TO_DATE(NULLIF(@due_date,''), '%d-%m-%Y'),
    sales_amount  = NULLIF(@sales_amount, ''),
    quantity      = NULLIF(@quantity, ''),
    price         = NULLIF(@price, '');