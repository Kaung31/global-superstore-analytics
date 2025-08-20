-- A_01_rebuild_staging_as_text.sql
-- Purpose: Rebuild staging table with all TEXT columns for safety.

-- 1) Drop old all-text table if it exists
DROP TABLE IF EXISTS stg_orders_alltext;

-- 2) Create new staging table with every column as TEXT
CREATE TABLE stg_orders_alltext (
  "Row ID"         TEXT,
  "Order ID"       TEXT,
  "Order Date"     TEXT,
  "Ship Date"      TEXT,
  "Ship Mode"      TEXT,
  "Customer ID"    TEXT,
  "Customer Name"  TEXT,
  "Segment"        TEXT,
  "City"           TEXT,
  "State"          TEXT,
  "Country"        TEXT,
  "Postal Code"    TEXT,
  "Market"         TEXT,
  "Region"         TEXT,
  "Product ID"     TEXT,
  "Category"       TEXT,
  "Sub-Category"   TEXT,
  "Product Name"   TEXT,
  "Sales"          TEXT,
  "Quantity"       TEXT,
  "Discount"       TEXT,
  "Profit"         TEXT,
  "Shipping Cost"  TEXT,
  "Order Priority" TEXT
);

-- 3) Copy from your current stg_orders into stg_orders_alltext (force everything to TEXT)
INSERT INTO stg_orders_alltext (
  "Row ID","Order ID","Order Date","Ship Date","Ship Mode",
  "Customer ID","Customer Name","Segment","City","State","Country","Postal Code",
  "Market","Region","Product ID","Category","Sub-Category","Product Name",
  "Sales","Quantity","Discount","Profit","Shipping Cost","Order Priority"
)
SELECT
  CAST("Row ID"        AS TEXT),
  CAST("Order ID"      AS TEXT),
  CAST("Order Date"    AS TEXT),
  CAST("Ship Date"     AS TEXT),
  CAST("Ship Mode"     AS TEXT),
  CAST("Customer ID"   AS TEXT),
  CAST("Customer Name" AS TEXT),
  CAST("Segment"       AS TEXT),
  CAST("City"          AS TEXT),
  CAST("State"         AS TEXT),
  CAST("Country"       AS TEXT),
  CAST("Postal Code"   AS TEXT),
  CAST("Market"        AS TEXT),
  CAST("Region"        AS TEXT),
  CAST("Product ID"    AS TEXT),
  CAST("Category"      AS TEXT),
  CAST("Sub-Category"  AS TEXT),
  CAST("Product Name"  AS TEXT),
  CAST("Sales"         AS TEXT),
  CAST("Quantity"      AS TEXT),
  CAST("Discount"      AS TEXT),
  CAST("Profit"        AS TEXT),
  CAST("Shipping Cost" AS TEXT),
  CAST("Order Priority" AS TEXT)
FROM stg_orders;

-- 4) Quick check: how many rows did we copy?
SELECT COUNT(*) AS total_rows FROM stg_orders_alltext;

-- 5) Peek first 10 rows
SELECT * FROM stg_orders_alltext LIMIT 10;
