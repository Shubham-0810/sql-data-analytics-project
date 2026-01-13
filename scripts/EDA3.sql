-- Changes over time (month-wise)
SELECT CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATETIME) AS order_date, 
		SUM(sales_amount) AS total_sales ,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATETIME)
ORDER BY CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATETIME);



-- Calculate total sales per year and running total of sales over time
SELECT order_date,
	total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    ROUND(AVG(avg_price) OVER (ORDER BY order_date),2) AS moving_average_price
FROM(
SELECT CAST(DATE_FORMAT(order_date, '%Y-01-01') AS DATETIME) AS order_date,
	SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date is NOT NULL
GROUP BY CAST(DATE_FORMAT(order_date, '%Y-01-01') AS DATETIME)
) t;



/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
	SELECT 
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	WHERE f.order_date is NOT NULL
	GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
	order_year,
	product_name,
	current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 ELSE 'Avg'
	END AS avg_change,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 ELSE 'No Change'
	END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
    
    
    
-- Which category contribute the most to overall sales?
WITH category_sales AS(
	SELECT 
		category,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY category
)

SELECT 
	category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND((total_sales / (SUM(total_sales) OVER ()))*100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
    
    

/* Segment product into cost ranges and
count how many products fall into each segment */
WITH product_segments AS(
	SELECT 
		product_key,
		product_name,
		cost,
		CASE WHEN cost < 100 THEN 'Below 100'
			 WHEN cost BETWEEN 100 and 500 THEN '100-500'
			 WHEN cost BETWEEN 500 and 1000 THEN '500-1000'
			 ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
)

SELECT 
	cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC; 



/* Group customers into 3 segments based on their spending behavior:
	- VIP: Customers with atleast 12 months of history and spending more than 5,000.
    - Regular: Customers with atleast 12 months of history and spending 5,000 or less.
    - New: Customers with a lifespan less than 12 months.
And find the total number of customers by eah group
*/
WITH customer_spending AS(
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		TIMESTAMPDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)

SELECT
	customer_segment,
    COUNT(customer_key) AS total_customers
FROM
	(SELECT 
		customer_key,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC;