# UK Housing Lakehouse

**Do energy-efficient homes sell at a premium in Greater Manchester?**

An end-to-end analytics engineering project: UK open data ingested into a Databricks lakehouse, modelled and tested with dbt, version-controlled with a PR-based git workflow and CI, and served through a Power BI report.

> 🚧 Work in progress — this README grows with the project. See [docs/decisions.md](docs/decisions.md) for architectural decisions.

## Stack

| Layer | Tool |
|---|---|
| Data platform | Databricks Free Edition (Unity Catalog, serverless SQL) |
| Transformation | dbt Core (`dbt-databricks`) |
| Version control & CI | GitHub, GitHub Actions, SQLFluff |
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
└── .github/workflows/  # CI: lint + dbt build on PR
```

## Running locally

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
# copy profiles.yml.example → ~/.dbt/profiles.yml and fill in your Databricks details
dbt debug
```

## Author

Nicholas Sampson — BI Developer moving into analytics engineering.
test
