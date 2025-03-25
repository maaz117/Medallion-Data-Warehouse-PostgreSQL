-- Indexing

CREATE INDEX idx_fact_sales_customer ON public.fact_sales(customer_key);
CREATE INDEX idx_fact_sales_products ON public.fact_sales(product_key);
CREATE INDEX idx_fact_sales_date ON public.fact_sales(order_date);

CREATE INDEX idx_dim_customers_name ON public.dim_customers(first_name, last_name);
CREATE INDEX idx_dim_products_category ON public.dim_products(category, subcategory);