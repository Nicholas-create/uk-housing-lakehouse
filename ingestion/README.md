# Ingestion (bronze layer)

Raw CSVs land in the Unity Catalog volume `housing.bronze.landing`, then load
as-is into bronze Delta tables with `_source_file` and `_loaded_at` audit columns.
All bronze columns are STRING — typing happens in silver (dbt staging).

Run the scripts in numeric order.

| Script | What it does |
|---|---|
| `00_create_schemas.sql` | Creates bronze/silver/gold schemas and the landing volume. Idempotent. |
| `01_load_bronze_land_registry.sql` | Land Registry Price Paid Data. `COPY INTO`, incremental. |
| `02_load_bronze_nspl.sql` | ONS postcode lookup. Full replace. |
| `03_load_bronze_epc.sql` | EPC domestic certificates. Full replace. |

## Manual acquisition steps

File acquisition is manual (see ADR 003, ADR 004). Upload via
**Catalog → housing → bronze → Volumes → landing → Upload to this volume**.

**Land Registry Price Paid Data** → `landing/land_registry/`
https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads
Yearly files, 2019 to current year. No header row — column names come from the
published schema and are supplied positionally in the load script.
Re-download the current year's file monthly; `COPY INTO` picks up new files only.

**ONS National Statistics Postcode Lookup** → `landing/ons/`
https://geoportal.statistics.gov.uk — search "National Statistics Postcode Lookup",
take the most recent UK release. Upload only `Data/NSPL_*.csv` from the zip.

**EPC domestic certificates** → `landing/epc/`
https://get-energy-performance-data.communities.gov.uk (GOV.UK One Login required).
Domestic certificates, filtered to the 10 Greater Manchester local authorities.
The service returns one combined CSV with a UUID filename — rename it to
`epc_domestic_gm_<YYYY-MM>.csv` before or after upload.

## Known data quality issue

EPC `LOCAL_AUTHORITY` codes disagree with `LOCAL_AUTHORITY_LABEL` on 25 of ~1.19M
certificates, including 4 carrying a Merseyside authority code. Both fields are
entered by the assessor at lodgement. Geography is therefore resolved via
postcode → NSPL, not from either EPC field. See the data quality section in the
main README.