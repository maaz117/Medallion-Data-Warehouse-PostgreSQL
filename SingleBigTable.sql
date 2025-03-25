-- Single Big Table (SBT)

CREATE TABLE public.single_big_table AS
SELECT 
    f.order_num,
    f.order_date,
    f.ship_date,
    f.due_date,
    f.total_sales,
    f.quantity,
    f.price,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.birth_date,
    c.gender,
    c.marital_status,
    c.country,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.maintenance,
    p.cost
FROM public.fact_sales f
JOIN public.dim_customers c ON f.customer_key = c.customer_key
JOIN public.dim_products p ON f.product_key = p.product_key;

SELECT * FROM public.single_big_table;

-- Adding indexes

CREATE INDEX idx_sbt_order_date ON public.single_big_table(order_date);
CREATE INDEX idx_sbt_customer_key ON public.single_big_table(customer_key);
CREATE INDEX idx_sbt_product_key ON public.single_big_table(product_key);