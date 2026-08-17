# Architecture decisions

Short, honest notes on why things are the way they are. Newest last.

## 001 — Ingestion on the platform, transformation in dbt
**Date:** 2026-08
**Decision:** Raw file loading (landing volume → bronze Delta tables) is done with Databricks-native tooling; everything from bronze onwards is dbt (bronze tables declared as dbt sources).
**Why:** Clean separation of concerns mirrors how production teams split EL from T. dbt is the tool being evidenced for transformation; using it to load CSVs would be the wrong tool for the job.

## 002 — Scope: 2019–2025 sales, Greater Manchester EPCs
**Date:** 2026-08
**Decision:** Price Paid Data limited to yearly files 2019–2025 (England & Wales); EPC certificates limited to the 10 Greater Manchester local authorities.
**Why:** Millions of rows is credible scale for a 2X-Small serverless warehouse without fighting free-tier limits. Greater Manchester focus gives the analytical question a real market to answer against.

## 003 — (next decision goes here)
