-- A_02_create_and_load_dimensions.sql
-- Purpose: Build core dimension tables from the clean TEXT staging table (stg_orders_alltext).

/* -----------------------------
   1) Create dimension tables
------------------------------*/

CREATE TABLE IF NOT EXISTS dim_customer (
  customer_key   INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id    TEXT UNIQUE,
  customer_name  TEXT,
  segment        TEXT
);

CREATE TABLE IF NOT EXISTS dim_product (
  product_key   INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id    TEXT UNIQUE,
  product_name  TEXT,
  category      TEXT,
  sub_category  TEXT
);

CREATE TABLE IF NOT EXISTS dim_geography (
  geography_key INTEGER PRIMARY KEY AUTOINCREMENT,
  country       TEXT,
  region        TEXT,
  market        TEXT,
  state         TEXT,
  city          TEXT,
  postal_code   TEXT,
  UNIQUE(country, region, market, state, city, postal_code)
);

CREATE TABLE IF NOT EXISTS dim_ship_mode (
  ship_mode_key INTEGER PRIMARY KEY AUTOINCREMENT,
  ship_mode     TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_order_priority (
  order_priority_key INTEGER PRIMARY KEY AUTOINCREMENT,
  order_priority     TEXT UNIQUE
);

/* -----------------------------
   2) Load data into dimensions
------------------------------*/

-- Customer
INSERT OR IGNORE INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT
  TRIM("Customer ID"),
  TRIM("Customer Name"),
  TRIM("Segment")
FROM stg_orders_alltext
WHERE "Customer ID" IS NOT NULL AND TRIM("Customer ID") <> '';

-- Product
INSERT OR IGNORE INTO dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT
  TRIM("Product ID"),
  TRIM("Product Name"),
  TRIM("Category"),
  TRIM("Sub-Category")
FROM stg_orders_alltext
WHERE "Product ID" IS NOT NULL AND TRIM("Product ID") <> '';

-- Geography (includes Market)
INSERT OR IGNORE INTO dim_geography (country, region, market, state, city, postal_code)
SELECT DISTINCT
  TRIM("Country"),
  UPPER(TRIM("Region")),
  UPPER(TRIM("Market")),
  TRIM("State"),
  TRIM("City"),
  TRIM(CAST("Postal Code" AS TEXT))
FROM stg_orders_alltext;

-- Ship Mode
INSERT OR IGNORE INTO dim_ship_mode (ship_mode)
SELECT DISTINCT TRIM("Ship Mode")
FROM stg_orders_alltext
WHERE "Ship Mode" IS NOT NULL AND TRIM("Ship Mode") <> '';

-- Order Priority
INSERT OR IGNORE INTO dim_order_priority (order_priority)
SELECT DISTINCT TRIM("Order Priority")
FROM stg_orders_alltext
WHERE "Order Priority" IS NOT NULL AND TRIM("Order Priority") <> '';

/* -----------------------------
   3) Quick checks (counts)
------------------------------*/

SELECT 'dim_customer'      AS table_name, COUNT(*) AS rows FROM dim_customer
UNION ALL
SELECT 'dim_product',                COUNT(*)      FROM dim_product
UNION ALL
SELECT 'dim_geography',              COUNT(*)      FROM dim_geography
UNION ALL
SELECT 'dim_ship_mode',              COUNT(*)      FROM dim_ship_mode
UNION ALL
SELECT 'dim_order_priority',         COUNT(*)      FROM dim_order_priority;

-- Peek a few values from each (optional)
SELECT * FROM dim_customer      LIMIT 5;
SELECT * FROM dim_product       LIMIT 5;
SELECT * FROM dim_geography     LIMIT 5;
SELECT * FROM dim_ship_mode     LIMIT 5;
SELECT * FROM dim_order_priority LIMIT 5;
