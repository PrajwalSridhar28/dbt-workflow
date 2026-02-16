# NYC Taxi dbt Workflow

This repository contains a dbt project (`taxi_rides_ny`) that transforms raw NYC taxi trip data into analytics-ready models for reporting.

## Project Overview

The project models yellow and green taxi trips using a layered dbt approach:

- `staging`: standardizes raw source schemas and data types
- `intermediate`: unions and enriches trip records, generates surrogate keys, deduplicates
- `marts`: publishes dimensions and a core trips fact table
- `marts/reporting`: publishes reporting-friendly monthly aggregates

Primary output tables:

- `fct_trips`: trip-level fact table with zone enrichment and trip duration
- `dim_zones`: taxi zone dimension from seed lookup
- `dim_paymenttype`: payment type dimension from seed lookup
- `dim_vendors`: vendor dimension derived from trip data
- `fct_monthly_zone_revenue`: monthly reporting output by service type for a selected year/month

## Source Data

Defined in `models/staging/sources.yml`:

- Source name: `raw_data`
- Database: `ny-taxi-project-485723`
- Schema: `zoomcamp`
- Tables:
  - `yellow_tripdata`
  - `green_tripdata`

## Seeds

The project uses two CSV seeds:

- `seeds/taxi_zone_lookup.csv`
- `seeds/payment_type_lookup.csv`

## Macros

- `get_trip_duration_minutes`: cross-database trip duration calculation in minutes
- `get_vendor_names`: maps `vendor_id` to vendor names

## Data Quality

Tests are configured in schema YAML files and include:

- `not_null` and `unique` checks on key columns (e.g., `trip_id`, `location_id`)
- accepted value checks (e.g., `service_type`, `payment_type`)
- configured package tests from `dbt_utils`
- custom generic test `positive_values` available in `tests/generic/test_positive_values.sql`

## Project Structure

```text
.
|- models/
|  |- staging/
|  |- intermediate/
|  |- marts/
|     |- reporting/
|- macros/
|- seeds/
|- tests/
|- dbt_project.yml
|- packages.yml
```

## Setup

1. Install dbt and adapter (choose one):

```bash
pip install dbt-bigquery
# or
pip install dbt-duckdb
```

2. Configure your dbt profile (`~/.dbt/profiles.yml`) with profile name:

- `taxi_rides_ny`

3. Install project packages:

```bash
dbt deps
```

4. Load seed files:

```bash
dbt seed
```

5. Build models and run tests:

```bash
dbt build
```

## Common Commands

```bash
dbt run
dbt test
dbt docs generate
dbt docs serve
```

## Running Reporting Model for Specific Month

The reporting model accepts `year` and `month` vars:

```bash
dbt run --select fct_monthly_zone_revenue --vars '{year: 2019, month: 10}'
```

## Notes

- `fct_trips` is incremental (`merge`) with `trip_id` as `unique_key`.
- Incremental filter uses `pickup_datetime` to process only new records.
- SQL includes cross-database handling for date truncation in reporting models.
