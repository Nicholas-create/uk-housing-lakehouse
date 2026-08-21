-- Phase 1: catalog structure for the medallion architecture.
-- Run once against the housing catalog. Idempotent - safe to re-run.

CREATE SCHEMA IF NOT EXISTS housing.bronze
  COMMENT 'Raw data loaded as-is from the landing volume. No transformation, no typing.';

CREATE SCHEMA IF NOT EXISTS housing.silver
  COMMENT 'dbt staging models - typed, renamed, deduped. 1:1 with sources.';

CREATE SCHEMA IF NOT EXISTS housing.gold
  COMMENT 'dbt marts - facts, dimensions, analysis models. Consumed by Power BI.';

CREATE VOLUME IF NOT EXISTS housing.bronze.landing
  COMMENT 'Landing zone for raw source files prior to bronze load.';