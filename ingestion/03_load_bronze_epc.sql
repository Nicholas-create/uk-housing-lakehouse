CREATE OR REPLACE TABLE housing.bronze.epc_domestic_certificates
COMMENT 'Domestic EPC certificates, Greater Manchester local authorities. Bulk CSV download. All STRING.'
AS
SELECT
  *,
  _metadata.file_name AS _source_file,
  current_timestamp() AS _loaded_at
FROM read_files(
  '/Volumes/housing/bronze/landing/epc/',
  format              => 'csv',
  header              => true,
  inferColumnTypes    => false,
  schemaEvolutionMode => 'none'
);