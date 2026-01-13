-- Find the Total Sales
SELECT SUM(sales_amount) as total_sales FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) as total_quantity FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) as avg_price FROM gold.fact_sales;

-- Find the total numbers of Orders
SELECT COUNT(order_number) as total_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) as total_orders FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_key) as total_products FROM gold.dim_products; 

-- Find the total number of customers
SELECT COUNT(customer_key) as total_customers FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) as total_customers FROM gold.fact_sales;



-- Generate a report that shows all key metrics of the business

SELECT 'Total Sales' as measure_name, SUM(sales_amount) as measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity)FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_key) FROM gold.dim_products
UNION ALL 
SELECT 'Total Nr.Customers', COUNT(customer_key) FROM gold.dim_customers;
