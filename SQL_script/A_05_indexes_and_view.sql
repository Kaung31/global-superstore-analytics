-- A_05_indexes_and_view.sql
-- Purpose: Add helpful indexes and create a one-stop enriched view for BI/exports.

/* 1) Indexes (safe to re-run) */
CREATE INDEX IF NOT EXISTS idx_fact_dates
  ON fact_orders(order_date_key, ship_date_key);
CREATE INDEX IF NOT EXISTS idx_fact_customer
  ON fact_orders(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_product
  ON fact_orders(product_key);
CREATE INDEX IF NOT EXISTS idx_fact_geo
  ON fact_orders(geography_key);
CREATE INDEX IF NOT EXISTS idx_fact_ship
  ON fact_orders(ship_mode_key);
CREATE INDEX IF NOT EXISTS idx_fact_priority
  ON fact_orders(order_priority_key);

CREATE INDEX IF NOT EXISTS idx_dim_customer_nat
  ON dim_customer(customer_id);
CREATE INDEX IF NOT EXISTS idx_dim_product_nat
  ON dim_product(product_id);
CREATE INDEX IF NOT EXISTS idx_dim_geo_nat
  ON dim_geography(country, region, market, state, city, postal_code);

/* 2) Enriched view (drop/recreate) */
DROP VIEW IF EXISTS v_orders_enriched;

CREATE VIEW v_orders_enriched AS
SELECT
  f.fact_id,
  f.order_id,
  od.full_date AS order_date,
  sd.full_date AS ship_date,
  -- Measures
  f.sales,
  f.profit,
  f.quantity,
  f.discount,
  f.shipping_cost,
  -- Customer
  dc.customer_id,
  dc.customer_name,
  dc.segment,
  -- Product
  dp.product_id,
  dp.product_name,
  dp.category,
  dp.sub_category,
  -- Geography
  dg.country,
  dg.region,
  dg.market,
  dg.state,
  dg.city,
  dg.postal_code,
  -- Ship & Priority
  sm.ship_mode,
  op.order_priority
FROM fact_orders f
JOIN dim_date           od  ON od.date_key = f.order_date_key
JOIN dim_date           sd  ON sd.date_key = f.ship_date_key
JOIN dim_customer       dc  ON dc.customer_key = f.customer_key
JOIN dim_product        dp  ON dp.product_key = f.product_key
JOIN dim_geography      dg  ON dg.geography_key = f.geography_key
JOIN dim_ship_mode      sm  ON sm.ship_mode_key = f.ship_mode_key
JOIN dim_order_priority op  ON op.order_priority_key = f.order_priority_key;

/* 3) Quick checks */
-- Rowcount from the view should match fact_orders
SELECT (SELECT COUNT(*) FROM fact_orders) AS fact_rows,
       (SELECT COUNT(*) FROM v_orders_enriched) AS view_rows;

-- Sample a few records to confirm joins
SELECT order_id, order_date, ship_date, customer_name, product_name, country, region, sales, profit
FROM v_orders_enriched
LIMIT 10;
