-- Gold Layer

-- fact_sales Table

CREATE TABLE public.fact_sales(
	order_num VARCHAR(20) NOT NULL,
	customer_key DOUBLE PRECISION NOT NULL,
    product_key VARCHAR(60) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_sales DECIMAL(10,2) DEFAULT 0,
    quantity INT CHECK (quantity >= 0),
    price DECIMAL(10,2) DEFAULT 0,
	FOREIGN KEY (customer_key) REFERENCES public.dim_customers(customer_key),
	FOREIGN KEY (product_key) REFERENCES public.dim_products(product_key)
);

INSERT INTO public.fact_sales (order_num, customer_key, product_key, order_date, ship_date, due_date, total_sales, quantity, price)
SELECT sls_ord_num, sls_cust_id, sls_prd_key, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM public.silver_sales;

SELECT * FROM public.fact_sales;

-- dim_customers Table

CREATE TABLE public.dim_customers (
    customer_id DOUBLE PRECISION,
	customer_key DOUBLE PRECISION PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10),
    marital_status VARCHAR(10),
    country VARCHAR(100),
    create_date DATE
);

INSERT INTO public.dim_customers (customer_id, customer_key, first_name, last_name, birth_date, gender, marital_status, country, create_date)
SELECT 
	c.cst_id AS customer_id,
	c.cst_key AS customer_key,
	c.cst_firstname AS first_name,
	c.cst_lastname AS lastname,
	e.bdate AS birth_date,
	COALESCE(e.gen, c.cst_gndr, 'Unkown') AS gender,
	c.cst_marital_status AS marital_status,
    l.cntry AS country,
    c.cst_create_date AS create_date
FROM public.silver_customers c
LEFT JOIN public.silver_erp_customers e ON c.cst_id = e.cid
LEFT JOIN public.silver_locations l ON c.cst_id = l.cid;

SELECT * FROM public.dim_customers;

-- dim_products Table

CREATE TABLE public.dim_products (
    product_id VARCHAR(10),
	product_key VARCHAR(60) PRIMARY KEY,
    product_name VARCHAR(255),
    cost DECIMAL(10,2),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(15),
    start_date DATE,
    end_date DATE
);

INSERT INTO public.dim_products (product_id, product_key, product_name, cost, category, subcategory, maintenance, start_date, end_date)
SELECT 
    p.prd_id AS product_id,
	p.prd_key AS product_key,
    p.prd_nm AS product_name,
    p.prd_cost AS cost,
    c.cat AS category,
    c.subcat AS subcategory,
    c.maintenance AS maintenance,
    p.prd_start_dt AS start_date,
    p.prd_end_dt AS end_date
FROM public.silver_products p
LEFT JOIN public.silver_product_categories c ON p.prd_id = c.id;

SELECT * FROM public.dim_products;