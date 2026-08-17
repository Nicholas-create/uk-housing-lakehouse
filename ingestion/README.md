# Ingestion (bronze layer)

Databricks-side loading: raw CSVs land in a Unity Catalog Volume, then are loaded
as-is into bronze Delta tables with a `_loaded_at` audit column.

Populated in Phase 1. Will contain:
- `load_bronze.sql` — COPY INTO / CTAS scripts per source
- notes on the manual download steps for each dataset
