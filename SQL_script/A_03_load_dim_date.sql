-- A_03_load_dim_date.sql
-- Purpose: Create and populate dim_date using Order Date + Ship Date from stg_orders_alltext.
-- Notes:
--   - Your CSV dates are dd-mm-YYYY; we convert them to ISO (YYYY-MM-DD).
--   - Safe if re-run (INSERT OR IGNORE).

/* 1) Create the date dimension if needed */
CREATE TABLE IF NOT EXISTS dim_date (
  date_key     INTEGER PRIMARY KEY,  -- e.g., 20140131
  full_date    TEXT NOT NULL,        -- 'YYYY-MM-DD'
  year         INTEGER,
  quarter      INTEGER,
  month        INTEGER,
  day          INTEGER,
  weekday      INTEGER,              -- 0=Sunday..6=Saturday
  weekday_name TEXT
);

/* 2) Normalize raw date strings -> ISO */
WITH norm AS (
  SELECT
    "Order Date" AS order_date_raw,
    "Ship Date"  AS ship_date_raw
  FROM stg_orders_alltext
),
dates_fixed AS (
  SELECT
    -- Convert dd-mm-YYYY -> YYYY-MM-DD if it matches that pattern
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
all_dates AS (
  SELECT DISTINCT order_date_iso AS d FROM dates_fixed WHERE d IS NOT NULL
  UNION
  SELECT DISTINCT ship_date_iso  AS d FROM dates_fixed WHERE d IS NOT NULL
)
INSERT OR IGNORE INTO dim_date (date_key, full_date, year, quarter, month, day, weekday, weekday_name)
SELECT
  CAST(strftime('%Y%m%d', d) AS INTEGER)                          AS date_key,
  d                                                                AS full_date,
  CAST(strftime('%Y', d) AS INTEGER)                               AS year,
  CAST(((CAST(strftime('%m', d) AS INTEGER) - 1) / 3) + 1 AS INT)  AS quarter,
  CAST(strftime('%m', d) AS INTEGER)                               AS month,
  CAST(strftime('%d', d) AS INTEGER)                               AS day,
  CAST(strftime('%w', d) AS INTEGER)                               AS weekday,
  CASE strftime('%w', d)
    WHEN '0' THEN 'Sunday' WHEN '1' THEN 'Monday' WHEN '2' THEN 'Tuesday'
    WHEN '3' THEN 'Wednesday' WHEN '4' THEN 'Thursday' WHEN '5' THEN 'Friday'
    ELSE 'Saturday' END                                            AS weekday_name
FROM all_dates
WHERE d GLOB '????-??-??';  -- ensure ISO-like format

/* 3) Quick checks */
-- Rowcount
SELECT COUNT(*) AS dim_date_rows FROM dim_date;

-- Min/Max dates to confirm range
SELECT MIN(full_date) AS min_date, MAX(full_date) AS max_date FROM dim_date;

-- Sample a few rows
SELECT * FROM dim_date ORDER BY full_date LIMIT 10;
