# ecommerce-etl

Data ingestion and analytics pipeline built on the [Brazilian E-Commerce (Olist) dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

**Pipeline:** raw CSVs → Python ETL → PostgreSQL → SQL analysis

---

## Dataset

~100,000 orders placed on the Olist marketplace between 2016 and 2018, spread across 9 CSV files:

| File | Rows | Description |
|------|------|-------------|
| `olist_orders_dataset.csv` | 99,441 | Core order records |
| `olist_order_items_dataset.csv` | 112,650 | Line items per order |
| `olist_customers_dataset.csv` | 99,441 | Customer info |
| `olist_sellers_dataset.csv` | 3,095 | Seller info |
| `olist_products_dataset.csv` | 32,951 | Product catalog |
| `olist_order_payments_dataset.csv` | 103,886 | Payment records |
| `olist_order_reviews_dataset.csv` | 99,224 | Customer reviews |
| `olist_geolocation_dataset.csv` | 1,000,163 | Zip-code coordinates |
| `product_category_name_translation.csv` | 71 | PT → EN category names |

Download from Kaggle and place all files in the `data/` directory.

---

## Requirements

- Docker & Docker Compose
- Python 3.10+

---

## Setup

**1. Clone and enter the repo**

```bash
git clone git@github.com:avet-davtyan/ecommerce-etl.git
cd ecommerce-etl
```

**2. Download the dataset**

1. Go to [Kaggle – Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Click **Download** (requires a free Kaggle account)
3. Unzip and place all 9 CSV files into the `data/` directory

The pipeline expects these files:
```
data/
  olist_customers_dataset.csv
  olist_geolocation_dataset.csv
  olist_order_items_dataset.csv
  olist_order_payments_dataset.csv
  olist_order_reviews_dataset.csv
  olist_orders_dataset.csv
  olist_products_dataset.csv
  olist_sellers_dataset.csv
  product_category_name_translation.csv
```

If any file is missing, `python app/main.py` will tell you exactly which ones.

**3. Configure credentials**

```bash
cp .env.example .env
```

Edit `.env` if you need a different port or password.

**4. Start PostgreSQL**

```bash
docker compose up -d
```

The container is named `olist-postgres` and listens on `localhost:5434`.

**5. Create a virtual environment and install dependencies**

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**6. Run the pipeline**

```bash
python app/main.py
```

This applies the schema, extracts all CSVs, cleans the data, and loads everything into PostgreSQL in one step.

**7. Run the analytical queries**

Open `sql/queries.sql` in any SQL client (e.g. DBeaver) connected to `localhost:5434`, or run:

```bash
docker exec -i olist-postgres psql -U postgres -d olist < sql/queries.sql
```

---

## Project Structure

```
ecommerce-etl/
  data/               # CSVs from Kaggle (gitignored, download manually)
  app/
    extract.py        # reads CSVs into DataFrames
    transform.py      # cleans and normalises data
    load.py           # inserts into PostgreSQL via psycopg2
    main.py           # applies schema + orchestrates extract → transform → load
  sql/
    schema.sql        # CREATE TABLE statements, indexes, constraints
    queries.sql       # analytical SQL queries
  docs/
    dataset.md        # dataset description
  docker-compose.yml
  requirements.txt
  .env.example
```

---

## Data Cleaning

| Table | Cleaning applied |
|-------|-----------------|
| All tables | Dropped rows with null primary keys; removed duplicates |
| `geolocation` | Removed exact duplicate rows (1,000,163 → 738,332); zero-padded zip codes to 5 chars |
| `customers` / `sellers` | Zero-padded zip codes to 5 chars |
| `products` | Fixed column name typos (`lenght` → `length`); filled null category with `'unknown'` |
| `orders` | Parsed all timestamp columns; filtered to customers that exist |
| `order_items` | Cast price/freight to float; filtered to existing orders, products, sellers |
| `order_payments` | Cast payment values and installments to correct numeric types |
| `order_reviews` | Dropped rows with missing timestamps or score; composite PK `(review_id, order_id)` used because `review_id` is not unique in the raw data |
| `category_translation` | Stripped UTF-8 BOM from first column header |

---

## Analytical Queries

`sql/queries.sql` covers:

1. **Summary statistics** — total orders, revenue, avg/min/max payment value
2. **Orders per month** — trend analysis from 2016 to 2018
3. **Top 10 sellers** — by total revenue
4. **Top 10 products** — by total revenue
5. **Orders and revenue by customer state** — geographic breakdown
6. **Orders and revenue by product category** — with average review score
7. **Average review score per category** — multi-table JOIN across 5 tables
8. **Seller ranking** — `RANK()` globally and within each state
9. **Month-over-month growth** — `LAG()` window function showing absolute and % change
