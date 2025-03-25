-- Business KPIs

-- Total Sales by Country

CREATE VIEW public.vw_total_sales_by_country AS
SELECT
	country,
	SUM(total_sales) AS total_sales
FROM public.single_big_table
GROUP BY country
ORDER BY total_sales DESC;

SELECT * FROM public.vw_total_sales_by_country;


-- Top 5 Customers by Revenue

CREATE VIEW public.vw_top_customers AS
SELECT 
	customer_key,
	first_name,
	last_name,
	SUM(total_sales) AS Revenue
FROM public.single_big_table
GROUP BY customer_key, first_name, last_name
ORDER BY Revenue DESC LIMIT 5;

SELECT * FROM public.vw_top_customers;


-- Best-Selling Products

CREATE VIEW public.vw_best_selling_products AS
SELECT 
	product_key,
	product_name,
	SUM(quantity) AS total_quantity_sold
FROM public.single_big_table
GROUP BY product_key, product_name
ORDER BY total_quantity_sold DESC LIMIT 10;

SELECT * FROM public.vw_best_selling_products;


-- Customer Retention Rate

CREATE VIEW public.vw_customer_retention_rate AS
WITH customer_orders AS (
    SELECT 
        customer_key, 
        COUNT(DISTINCT order_date) AS order_count
    FROM public.single_big_table
    GROUP BY customer_key
)
SELECT 
    COUNT(CASE WHEN order_count > 1 THEN customer_key END) * 100.0 / COUNT(customer_key) AS retention_rate
FROM customer_orders;

SELECT * FROM public.vw_customer_retention_rate;


-- Category-wise Sales Performance

CREATE VIEW public.vw_category_sales_performance AS
SELECT
	category,
	SUM(total_sales) AS total_sales
FROM public.single_big_table
GROUP BY category
ORDER BY total_sales DESC;

SELECT * FROM public.vw_category_sales_performance;