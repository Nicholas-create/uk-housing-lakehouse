# UK Housing Lakehouse

**Do energy-efficient homes sell at a premium in Greater Manchester?**

An end-to-end analytics engineering project: UK open data ingested into a Databricks lakehouse, modelled and tested with dbt, version-controlled with a PR-based git workflow and CI, and served through a Power BI report.

> 🚧 Work in progress — this README grows with the project. See [docs/decisions.md](docs/decisions.md) for architectural decisions.

## Stack

| Layer | Tool |
|---|---|
| Data platform | Databricks Free Edition (Unity Catalog, serverless SQL) |
| Transformation | dbt Core (`dbt-databricks`) |
| Version control & CI | GitHub (PR workflow, protected `main`); GitHub Actions + SQLFluff 🚧 planned |
| BI | Power BI |

## Architecture

```
Landing (UC Volume) → BRONZE (raw Delta) → SILVER (dbt staging) → GOLD (dbt marts) → Power BI
└────── Databricks ingestion ──────┘└──────────────── dbt ────────────────┘
```

Ingestion is handled on the platform side (Databricks); everything from bronze onwards is dbt. This boundary is deliberate — see decision 001.

## Data sources

| Source | Coverage | Licence |
|---|---|---|
| [HM Land Registry Price Paid Data](https://www.gov.uk/guidance/about-the-price-paid-data) | Property sales, England & Wales, 2019–2025 | OGL v3.0 |
| [Energy Performance Certificates](https://get-energy-performance-data.communities.gov.uk/) | Domestic EPCs, 10 Greater Manchester local authorities | OGL v3.0 |
| [ONS National Statistics Postcode Lookup](https://geoportal.statistics.gov.uk/) | Postcode → geography spine | OGL v3.0 |

Contains HM Land Registry data © Crown copyright and database right 2026. This data is licensed under the Open Government Licence v3.0.

## Project structure

```
├── ingestion/          # Databricks-side: volume load scripts / notebooks (bronze)
├── models/             # dbt: staging (silver), intermediate, marts (gold)
├── docs/               # Architecture decisions, notes
└── .github/workflows/  # 🚧 CI: lint + dbt build on PR (not yet added)
```

## Running locally

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
# copy profiles.yml.example → ~/.dbt/profiles.yml and fill in your Databricks details
dbt debug
```

## Data quality findings

Things the data told us that the documentation didn't. Each one shapes a modelling decision downstream.

| # | Source | Finding | Consequence |
|---|---|---|---|
| DQ-01 | EPC | `LOCAL_AUTHORITY` code contradicts `LOCAL_AUTHORITY_LABEL` on 25 of ~1.19M certificates; 4 of those carry a Merseyside authority code despite the extract being filtered to Greater Manchester. Both fields are assessor-entered at lodgement. | Geography for every property is resolved via postcode → ONS NSPL, never from EPC's own authority fields. A dbt test in silver will assert all certificates resolve to the 10 GM authorities. |
| DQ-02 | Land Registry | The current-year Price Paid file is republished monthly under the same filename, and `COPY INTO` skips filenames it has already loaded — even if the contents changed. | Re-downloads are date-stamped on upload; bronze stays append-only and silver dedupes on `transaction_id`. See [ADR 005](docs/decisions.md). |

## Author

Nicholas Sampson — BI Developer moving into analytics engineering.
