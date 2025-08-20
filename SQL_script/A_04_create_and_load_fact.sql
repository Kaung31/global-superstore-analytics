-- A_04_create_and_load_fact.sql
-- Purpose: Build fact_orders by normalizing dates/numbers and joining to all dimensions.
-- Safe to re-run (deletes & reloads).

/* 1) Create fact table (if not exists) */
CREATE TABLE IF NOT EXISTS fact_orders (
  fact_id            INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id           TEXT,
  order_date_key     INTEGER,
  ship_date_key      INTEGER,
  customer_key       INTEGER,
  product_key        INTEGER,
  geography_key      INTEGER,
  ship_mode_key      INTEGER,
  order_priority_key INTEGER,
  sales              REAL,
  quantity           INTEGER,
  discount           REAL,
  profit             REAL,
  shipping_cost      REAL,
  FOREIGN KEY(order_date_key)     REFERENCES dim_date(date_key),
  FOREIGN KEY(ship_date_key)      REFERENCES dim_date(date_key),
  FOREIGN KEY(customer_key)       REFERENCES dim_customer(customer_key),
  FOREIGN KEY(product_key)        REFERENCES dim_product(product_key),
  FOREIGN KEY(geography_key)      REFERENCES dim_geography(geography_key),
  FOREIGN KEY(ship_mode_key)      REFERENCES dim_ship_mode(ship_mode_key),
  FOREIGN KEY(order_priority_key) REFERENCES dim_order_priority(order_priority_key)
);

/* 2) Clear prior load (so you can re-run this script) */
DELETE FROM fact_orders;

/* 3) Insert data */
WITH norm AS (
  SELECT
    "Order ID"        AS order_id,
    "Order Date"      AS order_date_raw,
    "Ship Date"       AS ship_date_raw,
    "Customer ID"     AS customer_id,
    "Product ID"      AS product_id,
    "Country"         AS country,
    "Region"          AS region,
    "Market"          AS market,
    "State"           AS state,
    "City"            AS city,
    "Postal Code"     AS postal_code,
    "Ship Mode"       AS ship_mode,
    "Order Priority"  AS order_priority,
    "Sales"           AS sales_txt,
    "Quantity"        AS quantity_txt,
    "Discount"        AS discount_txt,
    "Profit"          AS profit_txt,
    "Shipping Cost"   AS shipping_cost_txt
  FROM stg_orders_alltext
),
-- Convert dd-mm-YYYY -> YYYY-MM-DD (ISO) for both dates
dates_fixed AS (
  SELECT
    *,
    CASE
      WHEN order_date_raw GLOB '??-??-????'
        THEN substr(order_date_raw,7,4)||'-'||substr(order_date_raw,4,2)||'-'||substr(order_date_raw,1,2)
      ELSE order_date_raw
    END AS order_date_iso,
    CASE
      WHEN ship_date_raw GLOB '??-??-????'
        THEN substr(ship_date_raw,7,4)||'-'||substr(ship_date_raw,4,2)||'-'||substr(ship_date_raw,1,2)
      ELSE ship_date_raw
    END AS ship_date_iso
  FROM norm
),
-- Strip currency symbols/commas; normalize discount whether it's '0.2' or '20%'
clean_numbers AS (
  SELECT
    *,
    -- Remove commas and $ signs before casting
    REPLACE(REPLACE(TRIM(sales_txt), ',', ''), '$', '')                  AS sales_clean,
    TRIM(quantity_txt)                                                   AS quantity_clean,
    REPLACE(TRIM(discount_txt), '%', '')                                 AS discount_clean_raw,
    REPLACE(REPLACE(TRIM(profit_txt), ',', ''), '$', '')                 AS profit_clean,
    REPLACE(REPLACE(TRIM(shipping_cost_txt), ',', ''), '$', '')          AS shipping_cost_clean
  FROM dates_fixed
),
-- Final numeric fields
finalized AS (
  SELECT
    order_id,
    order_date_iso,
    ship_date_iso,
    customer_id,
    product_id,
    country,
    region,
    market,
    state,
    city,
    postal_code,
    ship_mode,
    order_priority,
    CAST(sales_clean AS REAL)                         AS sales_val,
    CAST(quantity_clean AS INTEGER)                   AS quantity_val,
    -- If discount looks like >1, assume it was percent (e.g., 20) and divide by 100
    CASE
      WHEN discount_clean_raw = '' OR discount_clean_raw IS NULL THEN NULL
      WHEN CAST(discount_clean_raw AS REAL) > 1.0 THEN CAST(discount_clean_raw AS REAL) / 100.0
      ELSE CAST(discount_clean_raw AS REAL)
    END                                               AS discount_val,
    CAST(profit_clean AS REAL)                        AS profit_val,
    CAST(shipping_cost_clean AS REAL)                 AS shipping_cost_val
  FROM clean_numbers
)
INSERT INTO fact_orders (
  order_id, order_date_key, ship_date_key,
  customer_key, product_key, geography_key, ship_mode_key, order_priority_key,
  sales, quantity, discount, profit, shipping_cost
)
SELECT
  f.order_id,
  CAST(strftime('%Y%m%d', f.order_date_iso) AS INTEGER)  AS order_date_key,
  CAST(strftime('%Y%m%d', f.ship_date_iso)  AS INTEGER)  AS ship_date_key,
  dc.customer_key,
  dp.product_key,
  dg.geography_key,
  dsm.ship_mode_key,
  dop.order_priority_key,
  f.sales_val,
  f.quantity_val,
  f.discount_val,
  f.profit_val,
  f.shipping_cost_val
FROM finalized f
JOIN dim_customer       dc  ON dc.customer_id  = TRIM(f.customer_id)
JOIN dim_product        dp  ON dp.product_id   = TRIM(f.product_id)
JOIN dim_geography      dg  ON dg.country      = TRIM(f.country)
                           AND dg.region       = UPPER(TRIM(f.region))
                           AND dg.market       = UPPER(TRIM(f.market))
                           AND IFNULL(dg.state,'') = IFNULL(TRIM(f.state),'')
                           AND dg.city         = TRIM(f.city)
                           AND IFNULL(dg.postal_code,'') = IFNULL(TRIM(CAST(f.postal_code AS TEXT)),'')
JOIN dim_ship_mode      dsm ON dsm.ship_mode   = TRIM(f.ship_mode)
JOIN dim_order_priority dop ON dop.order_priority = TRIM(f.order_priority);

/* 4) Quick sanity checks */
-- a) Counts
SELECT (SELECT COUNT(*) FROM stg_orders_alltext) AS staging_rows,
       (SELECT COUNT(*) FROM fact_orders)       AS fact_rows;

-- b) Missing date foreign keys (should be 0)
SELECT COUNT(*) AS bad_date_fks
FROM fact_orders fo
LEFT JOIN dim_date d1 ON d1.date_key = fo.order_date_key
LEFT JOIN dim_date d2 ON d2.date_key = fo.ship_date_key
WHERE d1.date_key IS NULL OR d2.date_key IS NULL;

-- c) KPI smoke test
SELECT
  ROUND(SUM(sales), 2)  AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(SUM(profit)/NULLIF(SUM(sales),0), 4) AS profit_margin
FROM fact_orders;

-- d) Sample joined view
SELECT fo.order_id, od.full_date AS order_date, sd.full_date AS ship_date,
       dc.customer_name, dp.product_name, dg.country, dg.region,
       fo.sales, fo.profit, fo.discount, fo.shipping_cost
FROM fact_orders fo
JOIN dim_date od ON od.date_key = fo.order_date_key
JOIN dim_date sd ON sd.date_key = fo.ship_date_key
JOIN dim_customer dc ON dc.customer_key = fo.customer_key
JOIN dim_product  dp ON dp.product_key = fo.product_key
JOIN dim_geography dg ON dg.geography_key = fo.geography_key
LIMIT 10;
