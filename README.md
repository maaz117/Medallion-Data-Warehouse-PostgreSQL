# **Medallion Data Warehouse: Scalable Analytics with PostgreSQL**

## **Overview**
This project implements the **Medallion Architecture** in **PostgreSQL**, organizing data into **Bronze, Silver, and Gold** layers. It enables efficient data transformation, indexing, and analytical insights, supporting **BI and analytics tools**.

## **Project Structure**
- **Bronze Layer**: Raw data ingestion from multiple sources.
- **Silver Layer**: Data cleansing, transformation, and referential integrity enforcement.
- **Gold Layer**: Optimized tables (**fact_sales, dim_customers, dim_products**) for analytical queries.
- **Single Big Table (SBT)**: Consolidated dataset for direct BI tool integration.

## **Key Features**
- **ETL Process**: Data ingestion and transformation using SQL.
- **Data Modeling**: **Star schema** with fact and dimension tables.
- **Indexing & Optimization**: Query performance tuning with indexes.
- **Business KPIs**:
  - Total sales by country
  - Top 5 customers by revenue
  - Best-selling products
  - Customer retention rate
  - Category-wise sales performance

## **Files & Scripts**
- 📄 **BronzeLayer.sql** – Initial data ingestion script.
- 📄 **SilverLayer.sql** – Data transformation and integrity enforcement.
- 📄 **GoldLayer.sql** – Fact/dimension table creation for analytics.
- 📄 **SingleBigTable.sql** – Single big table schema for BI tools.
- 📄 **BusinessKPIs.sql** – SQL queries for business performance insights.
- 📄 **Indexing.sql** – Indexing strategies for optimized performance.
- 📄 **ERD.png** – Entity Relationship Diagram (ERD) of the schema.
- 📄 **data_dump.ipynb** – Jupyter notebook for data validation and exploration.
- 📄 **Medallion Architecture Report.pdf** – Summary report of the architecture.

## **How to Use**
1. **Setup PostgreSQL** and import the provided `.sql` scripts in order:
   - Bronze → Silver → Gold → Indexing → Business KPIs → SBT
2. **Run Analytical Queries** from `BusinessKPIs.sql` to extract insights.
3. **Connect BI Tools** like Power BI/Tableau to the Single Big Table (SBT) for visualization.


