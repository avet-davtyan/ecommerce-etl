# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a university homework project: a Data Ingestion and Analytics Pipeline built around the [Brazilian E-Commerce (Olist) dataset from Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The pipeline: raw CSVs → Python ETL (extract / transform / load) → PostgreSQL → SQL analysis queries.

## Repository Structure

```
homework-2/
  data/            # raw CSVs from Kaggle (gitignored, must be downloaded manually)
  app/             # Python ETL pipeline
    extract.py     # reads CSVs from data/
    transform.py   # cleans and normalises data
    load.py        # inserts into PostgreSQL via SQLAlchemy
    main.py        # orchestrates extract → transform → load
  sql/
    schema.sql     # CREATE TABLE statements, indexes, constraints
    queries.sql    # analytical SQL queries
  docs/            # project documentation and progress tracking
  requirements.txt
  README.md
```

## Common Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run the full ETL pipeline
python app/main.py

# Run only a single stage
python app/extract.py
python app/transform.py
python app/load.py

# Apply schema to PostgreSQL
psql -U <user> -d <dbname> -f sql/schema.sql

# Run analysis queries
psql -U <user> -d <dbname> -f sql/queries.sql
```

## Environment Variables

The pipeline reads DB credentials from a `.env` file (gitignored):

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=olist
DB_USER=postgres
DB_PASSWORD=yourpassword
```

## Dataset

- **Source:** [Kaggle – Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Size:** ~100k orders, 2016–2018
- **Files (place in `data/`):**
  - `olist_orders_dataset.csv`
  - `olist_order_items_dataset.csv`
  - `olist_customers_dataset.csv`
  - `olist_sellers_dataset.csv`
  - `olist_products_dataset.csv`
  - `olist_order_payments_dataset.csv`
  - `olist_order_reviews_dataset.csv`
  - `olist_geolocation_dataset.csv`
  - `product_category_name_translation.csv`

## Architecture Notes

- `extract.py` returns a dict of DataFrames keyed by table name.
- `transform.py` receives that dict, returns a cleaned dict of DataFrames.
- `load.py` receives the cleaned dict and upserts into PostgreSQL using SQLAlchemy `to_sql`.
- `main.py` wires them together: `load(transform(extract()))`.
- All DB interaction goes through SQLAlchemy; raw psycopg2 is only used by the schema script.

## Database

- Target: **PostgreSQL**
- Schema follows the Olist relational model (star-schema-like): `orders` is the central fact table joined to `customers`, `order_items`, `products`, `sellers`, `order_payments`, `order_reviews`, and `geolocation`.

## Git Conventions

- Do **not** include `Co-Authored-By: Claude` (or any Claude co-author line) in commit messages.
