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