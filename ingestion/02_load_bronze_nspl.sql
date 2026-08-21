-- Phase 1: load ONS National Statistics Postcode Lookup into bronze.
--
-- NSPL HAS a header row, so column names come from the file (unlike PPD).
-- Full-replace rather than append: NSPL is a point-in-time reference
-- snapshot, not transaction history. Each quarterly release supersedes
-- the last.
--
-- inferColumnTypes => false keeps every column as STRING, consistent
-- with the bronze contract. Typing happens in silver.

CREATE OR REPLACE TABLE housing.bronze.ons_nspl
COMMENT 'ONS National Statistics Postcode Lookup, full UK. Reference snapshot - replaced wholesale each release. All STRING.'
AS
SELECT
  *,
  _metadata.file_name AS _source_file,
  current_timestamp() AS _loaded_at
FROM read_files(
  '/Volumes/housing/bronze/landing/ons/',
  format             => 'csv',
  header             => true,
  inferColumnTypes   => false,
  schemaEvolutionMode => 'none'
);