# Architecture decisions

Short, honest notes on why things are the way they are. Newest last.

## 001 — Ingestion on the platform, transformation in dbt
**Date:** 2026-08
**Decision:** Raw file loading (landing volume → bronze Delta tables) is done with Databricks-native tooling; everything from bronze onwards is dbt (bronze tables declared as dbt sources).
**Why:** Clean separation of concerns mirrors how production teams split EL from T. dbt is the tool being evidenced for transformation; using it to load CSVs would be the wrong tool for the job.

## 002 — Scope: 2019–present sales, Greater Manchester EPCs
**Date:** 2026-08 (amended 2026-08-19)
**Decision:** Price Paid Data limited to yearly files from 2019 onwards, including the
current year; EPC certificates limited to the 10 Greater Manchester local authorities.
**Why:** Millions of rows is credible scale for a 2X-Small serverless warehouse without
fighting free-tier limits. Greater Manchester focus gives the analytical question a real
market to answer against.
**Amendment:** originally 2019–2025. Extended to include the current year because Land
Registry republishes the current-year file monthly — it is the only file in the set that
changes between pulls, and the Phase 6 incremental model needs something that actually
changes to be a meaningful demonstration.

## 003 — EPC via bulk CSV download; developer API deferred
**Date:** 2026-08-19
**Decision:** EPC certificates acquired through the bulk CSV download from the MHCLG
Get Energy Performance of Buildings Data service. The developer API is deferred, not
rejected.
**Why:** The API was the original plan, for reproducibility and to make the Phase 6
re-pull a single command. Two things changed that: the API technical documentation sits
behind GOV.UK One Login and blocks automated reading, making the contract slow to
establish; and the original plan set a one-evening timebox on the API with bulk download
as the documented fallback. That timebox was the deciding factor.
**Trade-off accepted:** acquisition is now a manual step. Mitigated by documenting it in
`ingestion/README.md`. The API remains the better answer for the Phase 6 re-pull and can
be added without disturbing anything downstream — bronze is loaded from the volume
regardless of how files arrive in it.

## 004 — Ingestion executed through the Databricks UI, not the CLI
**Date:** 2026-08-19
**Decision:** Files are uploaded to the landing volume through the Databricks web UI;
file-management operations (rename, move) use `dbutils.fs` in a notebook. No Databricks
CLI in the loop.
**Why:** The volume UI upload limit is 5 GB per file; the largest source file is 964 MB,
so nothing here needs the CLI. Every transformation step remains committed, re-runnable
SQL — only the file upload is manual, and it is documented. The reproducibility that
matters is in the load scripts, not in how bytes reached the volume.
**Note:** Unity Catalog volumes offer no rename operation in the UI or in SQL, because
the underlying object storage has no rename primitive. `dbutils.fs.mv` performs a copy
and delete.

## 005 — Bronze is append-only; Land Registry re-publications are date-stamped and deduplicated in silver
**Date:** 2026-08-21
**Context:** ADR 002 extended the sales window to the current year *because* Land Registry
republishes that year's file monthly, giving Phase 6 something that genuinely changes between
pulls. But `COPY INTO` tracks loaded files by name and skips a file it has already loaded
**even if its contents have changed**. Re-uploading `pp-2026.csv` over itself would therefore
do nothing, and bronze would silently drift from source — the opposite of what ADR 002 set
out to demonstrate.
**Decision:** Bronze stays strictly append-only. Each re-download of the current-year file is
uploaded under a date-stamped name (`pp-2026_2026-09.csv`, `pp-2026_2026-10.csv`, …), so
`COPY INTO` sees a new file and loads it. Bronze will then hold the same transaction more than
once; silver deduplicates on `transaction_id`, keeping the row with the latest `_loaded_at`.
**Why this over delete-and-reload:** an immutable bronze is simpler to reason about, trivially
auditable (`_source_file` tells you exactly which publication each row came from), and never
needs a destructive statement run against raw data. It also gives silver a legitimate, realistic
reason to carry a dedupe — the same pattern production pipelines need for late-arriving or
restated records. Price Paid Data's own `record_status` column (A = add, C = change, D = delete)
reinforces that the source is a log of publications, not a clean snapshot.
**Trade-off accepted:** bronze row counts for the current year will exceed the source's; this is
by design and will be documented on the bronze source in dbt. Storage cost is negligible at this
scale (the current-year file is tens of MB).
**Alternatives rejected:** `COPY_OPTIONS ('force' = 'true')` — reloads every matched file, not
just the changed one; `DELETE … WHERE _source_file = …` then reload — works, but makes bronze
mutable and puts a destructive step in the ingestion path.
