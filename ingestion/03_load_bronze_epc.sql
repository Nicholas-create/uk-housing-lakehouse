-- Phase 1: load EPC domestic certificates into bronze.
--
-- Bulk CSV download from the MHCLG Get Energy Performance of Buildings Data
-- service, filtered to the 10 Greater Manchester local authorities (ADR 003).
-- The file HAS a header row, so column names come from the file.
-- Full-replace rather than append: each bulk pull is a complete snapshot of
-- every certificate on the register, so it supersedes the last one wholesale.
--
-- inferColumnTypes => false keeps every column as STRING, consistent with the
-- bronze contract. Typing happens in silver.
--
-- Known issue: LOCAL_AUTHORITY and LOCAL_AUTHORITY_LABEL disagree on a handful
-- of rows (DQ-01 in the main README). Landed as-is; resolved in silver via NSPL.

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