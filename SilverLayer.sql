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