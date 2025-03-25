-- CUST_AZ12 Table
SELECT * FROM public."CUST_AZ12";

-- LOC_A101 Table
SELECT * FROM public."LOC_A101";

-- PX_CAT_G1V2 Table
SELECT * FROM public."PX_CAT_G1V2";

-- cust_info Table
SELECT * FROM public.cust_info;

-- prd_info Table
SELECT * FROM public.prd_info;

-- sales_details Table
SELECT * FROM public.sales_details;

-- Bronze Layer

-- Missing Values

-- Checking null values in CUST_AZ12 TAble
-- NULL values in GEN(1472) column
SELECT COUNT(*) AS null_count FROM public."CUST_AZ12"
WHERE "CID" IS NULL OR "BDATE" IS NULL OR "GEN" IS NULL;

SELECT COUNT(*) AS null_count FROM public."CUST_AZ12"
WHERE "GEN" IS NULL;

-- Checking null values in LOC_A101 TAble
-- NULL values in CNTRY(332) column
SELECT COUNT(*) AS null_count FROM public."LOC_A101"
WHERE "CID" IS NULL OR "CNTRY" IS NULL;

SELECT COUNT(*) AS null_count FROM public."LOC_A101"
WHERE "CNTRY" IS NULL;

-- Checking null values in PX_CAT_G1V2 Table
-- NO NULL values
SELECT COUNT(*) AS null_count FROM public."PX_CAT_G1V2"
WHERE "ID" IS NULL OR "CAT" IS NULL OR "SUBCAT" IS NULL OR "MAINTENANCE" IS NULL;

-- Checking null values in cust_info Table
-- NULL values are in cst_id(4), cst_firstname(8), cst_lastname(7), cst_marital_status(7), cst_gndr(4578), cst_create_date(4) 
SELECT COUNT(*) AS null_count FROM public.cust_info
WHERE cst_id IS NULL OR cst_key IS NULL OR cst_firstname IS NULL OR cst_lastname IS NULL OR cst_marital_status IS NULL OR cst_gndr IS NULL OR cst_create_date IS NULL;

SELECT * FROM public.cust_info WHERE cst_id IS NULL;

SELECT * FROM public.cust_info WHERE cst_key = 'AW00029466';

-- Checking null values in prd_info Table
-- NULL values are in prd_cost(2), prd_line(17), prd_end_dt(197)
SELECT COUNT(*) AS null_count FROM public.prd_info
WHERE prd_id IS NULL OR prd_key IS NULL OR prd_nm IS NULL OR prd_cost IS NULL OR prd_line IS NULL OR prd_start_dt IS NULL OR prd_end_dt IS NULL;

-- Checking null values in sales_details Table
-- NULL values are in sls_sales(8), sls_price(7) columns.
SELECT COUNT(*) AS null_count FROM public.sales_details
WHERE sls_ord_num IS NULL OR sls_prd_key IS NULL OR sls_cust_id IS NULL OR sls_order_dt IS NULL OR sls_ship_dt
IS NULL OR sls_due_dt IS NULL OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL;

-- Duplicate Values

-- Checking duplicate values in CUST_AZ12 Table
SELECT "CID" FROM public."CUST_AZ12" GROUP BY "CID" HAVING COUNT(*) > 1;

-- Checking duplicate values in LOC_A101 Table
SELECT "CID" FROM public."LOC_A101" GROUP BY "CID" HAVING COUNT(*) > 1;

-- Checking duplicate values in PX_CAT_G1V2 Table
SELECT "ID" FROM public."PX_CAT_G1V2" GROUP BY "ID" HAVING COUNT(*) > 1;

-- Checking duplicate values in cust_info Table
SELECT cst_id FROM public.cust_info GROUP BY cst_id HAVING COUNT(*) > 1;

SELECT * FROM public.cust_info WHERE cst_id IS NULL;

SELECT * FROM public.cust_info WHERE cst_id = 29449;

SELECT * FROM public.cust_info WHERE cst_id = 29466;

SELECT * FROM public.cust_info WHERE cst_id = 29483;

SELECT * FROM public.cust_info WHERE cst_id = 29433;

SELECT * FROM public.cust_info WHERE cst_id = 29473;

-- Checking duplicate values in prd_info Table
SELECT prd_id FROM prd_info GROUP BY prd_id HAVING COUNT(*) > 1;

SELECT prd_key FROM prd_info GROUP BY prd_key HAVING COUNT(*) > 1;



-- Checking duplicate values in sales_details Table
SELECT sls_ord_num FROM sales_details GROUP BY sls_ord_num HAVING COUNT(*) > 1;

SELECT * FROM sales_details WHERE sls_ord_num = 'SO67487';

SELECT * FROM sales_details WHERE sls_ord_num = 'SO60666';


-- Silver Layer

-- Customer Information Table

CREATE TABLE public.silver_customers(
	cst_id double precision PRIMARY KEY,
	cst_key VARCHAR(50) UNIQUE NOT NULL,
	cst_firstname VARCHAR(100),
	cst_lastname VARCHAR (100),
	cst_marital_status VARCHAR (100),
	cst_gndr VARCHAR(10),
	cst_create_date DATE
);

INSERT INTO public.silver_customers (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
SELECT DISTINCT cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status,
	COALESCE(cst_gndr, 'Unkown'),
	CAST(cst_create_date AS DATE)
FROM public.cust_info
WHERE cst_id IS NOT NULL
ON CONFLICT (cst_key) DO NOTHING;

SELECT * FROM public.silver_customers;

-- Products Table

CREATE TABLE public.silver_products(
	prd_id bigint PRIMARY KEY,
	prd_key VARCHAR(60) UNIQUE NOT NULL,
	prd_nm VARCHAR(255),
	prd_cost DECIMAL(10, 2),
	prd_line VARCHAR(10),
	prd_start_dt DATE,
	prd_end_dt DATE
);

INSERT INTO public.silver_products(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
SELECT DISTINCT prd_id, prd_key, prd_nm,
	COALESCE(prd_cost, 0),
	COALESCE(prd_line, 'Unkown'),
	CAST(prd_start_dt AS DATE),
	CAST(prd_end_dt AS DATE)
FROM public.prd_info
WHERE prd_id IS NOT NULL
ON CONFLICT (prd_key) DO NOTHING;

UPDATE public.silver_products
SET prd_end_dt = NULL
WHERE prd_end_dt IS NULL;

SELECT * FROM public.silver_products;

-- Sales Table

CREATE TABLE public.silver_sales(
	sls_ord_num VARCHAR(20) PRIMARY KEY,
	sls_prd_key VARCHAR(50) NOT NULL, 
	sls_cust_id bigint NOT NULL REFERENCES public.silver_customers(cst_id),
	sls_order_dt DATE NOT NULL,
	sls_ship_dt DATE NOT NULL,
	sls_due_dt DATE NOT NULL,
	sls_sales DECIMAL(10,2) DEFAULT 0,
	sls_quantity INT CHECK (sls_quantity >= 0),
	sls_price DECIMAL(10,2) DEFAULT 0
);

INSERT INTO public.silver_sales (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
SELECT sls_ord_num, sls_prd_key, sls_cust_id, 
       TO_DATE(TO_CHAR(TO_TIMESTAMP(sls_order_dt), 'YYYY-MM-DD'), 'YYYY-MM-DD'),
       TO_DATE(TO_CHAR(TO_TIMESTAMP(sls_ship_dt), 'YYYY-MM-DD'), 'YYYY-MM-DD'),
       TO_DATE(TO_CHAR(TO_TIMESTAMP(sls_due_dt), 'YYYY-MM-DD'), 'YYYY-MM-DD'),
       COALESCE(sls_sales, 0), 
       COALESCE(sls_quantity, 0), 
       COALESCE(sls_price, 0)
FROM public.sales_details
WHERE sls_ord_num IS NOT NULL
ON CONFLICT (sls_ord_num) DO NOTHING;

SELECT * FROM public.silver_sales;

-- ERP Customers table

CREATE TABLE public.silver_erp_customers(
	cid VARCHAR(50) PRIMARY KEY,
	bdate DATE,
	gen VARCHAR(10) DEFAULT 'Unkown'
);

INSERT INTO public.silver_erp_customers(cid, bdate, gen)
SELECT DISTINCT "CID", CAST("BDATE" AS DATE), COALESCE("GEN", 'Unknown')
FROM public."CUST_AZ12"
WHERE "CID" IS NOT NULL;

SELECT * FROM public.silver_erp_customers;

-- Location Table

CREATE TABLE public.silver_locations(
	cid VARCHAR(50) PRIMARY KEY,
	cntry VARCHAR(100) DEFAULT 'Unkown'
);

INSERT INTO public.silver_locations(cid, cntry)
SELECT DISTINCT "CID", COALESCE("CNTRY", 'Unkown') 
FROM public."LOC_A101"
WHERE "CID" IS NOT NULL;

SELECT * FROM public.silver_locations;

-- Product Categories Table

CREATE TABLE public.silver_product_categories(
	id VARCHAR(20) PRIMARY KEY,
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(15)
);

INSERT INTO public.silver_product_categories (id, cat, subcat, maintenance)
SELECT DISTINCT "ID", "CAT", "SUBCAT", "MAINTENANCE"
FROM public."PX_CAT_G1V2";

SELECT * FROM public.silver_product_categories;

-- ID Column Correction

-- ERP customers Table
UPDATE public.silver_erp_customers
set cid = RIGHT(cid, 5);

ALTER TABLE public.silver_erp_customers 
ALTER COLUMN cid 
SET DATA TYPE DOUBLE PRECISION 
USING cid::DOUBLE PRECISION;

SELECT * FROM public.silver_erp_customers;

-- Location Table
UPDATE public.silver_locations
set cid = RIGHT(cid, 5);

ALTER TABLE public.silver_locations 
ALTER COLUMN cid 
SET DATA TYPE DOUBLE PRECISION 
USING cid::DOUBLE PRECISION;

SELECT * FROM public.silver_locations;

-- Correction for References

ALTER TABLE public.silver_products
ALTER COLUMN prd_id TYPE VARCHAR(10)
USING prd_id::VARCHAR(10);

ALTER TABLE public.silver_products 
DROP CONSTRAINT IF EXISTS silver_products_pkey;

UPDATE public.silver_products
SET prd_id = REPLACE(
    SPLIT_PART(prd_key, '-', 1) || '_' || SPLIT_PART(prd_key, '-', 2), 
    '-', '_'
);

UPDATE public.silver_products
SET prd_key = SPLIT_PART(prd_key, '-', 3) || '-' || SPLIT_PART(prd_key, '-', 4) || '-' || SPLIT_PART(prd_key, '-', 5);

ALTER TABLE public.silver_products 
ADD CONSTRAINT silver_products_pkey PRIMARY KEY (prd_key);

SELECT * FROM public.silver_products;

UPDATE public.silver_customers
SET cst_key = RIGHT(cst_key, 5);

ALTER TABLE public.silver_customers
ALTER COLUMN cst_key TYPE double precision
USING cst_key::double precision;

SELECT * FROM public.silver_customers;

-- References

ALTER TABLE public.silver_customers
ADD CONSTRAINT fk_customer_location FOREIGN KEY (cst_id) REFERENCES public.silver_locations(cid);

ALTER TABLE public.silver_sales
ADD CONSTRAINT fk_sales_customer FOREIGN KEY (sls_cust_id) REFERENCES public.silver_customers(cst_id);

-- Deleting incorrect sales records
DELETE FROM silver_sales
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver_products);

ALTER TABLE public.silver_sales
ADD CONSTRAINT fk_sales_product FOREIGN KEY (sls_prd_key) REFERENCES public.silver_products(prd_key);

-- Deleting incorrect products
DELETE FROM silver_products
WHERE prd_id NOT IN (SELECT id FROM silver_product_categories);

ALTER TABLE public.silver_products
ADD CONSTRAINT fk_product_category FOREIGN KEY (prd_id) REFERENCES public.silver_product_categories(id);


ALTER TABLE public.silver_customers
ADD CONSTRAINT fk_customers_category FOREIGN KEY (cst_id) REFERENCES public. silver_erp_customers(cid);



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


-- Indexing

CREATE INDEX idx_fact_sales_customer ON public.fact_sales(customer_key);
CREATE INDEX idx_fact_sales_products ON public.fact_sales(product_key);
CREATE INDEX idx_fact_sales_date ON public.fact_sales(order_date);

CREATE INDEX idx_dim_customers_name ON public.dim_customers(first_name, last_name);
CREATE INDEX idx_dim_products_category ON public.dim_products(category, subcategory);


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