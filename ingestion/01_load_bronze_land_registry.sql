-- Phase 1: load Land Registry Price Paid Data into bronze.
--
-- Source files have NO header row - column names come from the published
-- schema at https://www.gov.uk/guidance/about-the-price-paid-data
-- All columns land as STRING. Typing happens in silver (dbt staging).

CREATE TABLE IF NOT EXISTS housing.bronze.land_registry_price_paid (
  transaction_id     STRING,
  price              STRING,
  date_of_transfer   STRING,
  postcode           STRING,
  property_type      STRING,
  old_new            STRING,
  duration           STRING,
  paon               STRING,
  saon               STRING,
  street             STRING,
  locality           STRING,
  town_city          STRING,
  district           STRING,
  county             STRING,
  ppd_category_type  STRING,
  record_status      STRING,
  _source_file       STRING,
  _loaded_at         TIMESTAMP
)
COMMENT 'Raw HM Land Registry Price Paid Data, yearly files. Loaded as-is, all STRING.';



COPY INTO housing.bronze.land_registry_price_paid
FROM (
  SELECT
    _c0  AS transaction_id,
    _c1  AS price,
    _c2  AS date_of_transfer,
    _c3  AS postcode,
    _c4  AS property_type,
    _c5  AS old_new,
    _c6  AS duration,
    _c7  AS paon,
    _c8  AS saon,
    _c9  AS street,
    _c10 AS locality,
    _c11 AS town_city,
    _c12 AS district,
    _c13 AS county,
    _c14 AS ppd_category_type,
    _c15 AS record_status,
    _metadata.file_name AS _source_file,
    current_timestamp()  AS _loaded_at
  FROM '/Volumes/housing/bronze/landing/land_registry/'
)
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'false');