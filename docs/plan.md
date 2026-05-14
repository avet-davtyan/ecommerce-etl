# Project Plan

## Final Deliverable

A git repo where the grader can:
1. `docker compose up -d` → PostgreSQL running
2. `psql -f sql/schema.sql` → tables created
3. `python app/main.py` → all 9 CSVs read, cleaned, inserted into DB
4. `psql -f sql/queries.sql` → analytical queries run and produce results

No web app, no API, no dashboard — just a pipeline: **CSV → Python → PostgreSQL**, then SQL analysis on top.

---

## Stack Decisions

- **PostgreSQL** via Docker Compose (Alpine image)
- **No ORM** — plain `psycopg2` with raw SQL INSERT / COPY FROM STDIN
- Credentials via `.env` file (gitignored)

---

## Step-by-Step Plan

### Step 1 — Infrastructure
- `docker-compose.yml`: postgres service, named volume, env vars
- `.env`: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`

### Step 2 — Schema (`sql/schema.sql`)
- `CREATE TABLE` for all 9 tables
- Primary keys, foreign keys, NOT NULL constraints
- Indexes on frequently queried columns (`order_id`, `customer_id`, `seller_id`, etc.)

### Step 3 — Extract (`app/extract.py`)
- Read each CSV from `data/` into a pandas DataFrame
- Return a dict: `{ "orders": df, "customers": df, ... }`
- No logic here, just reading

### Step 4 — Transform (`app/transform.py`)
- Receives the dict, returns a cleaned dict
- Handle nulls (drop or fill depending on column)
- Remove duplicates (especially in `geolocation`)
- Fix data types (timestamps → datetime, prices → float)
- Translate product category names (join the translation CSV)

### Step 5 — Load (`app/load.py`)
- Connect via `psycopg2` (plain, no ORM)
- Use `COPY FROM STDIN` for speed (100k rows)
- Respect FK insert order: `customers`, `sellers`, `products` before `orders`, `order_items`, etc.

### Step 6 — Orchestrate (`app/main.py`)
- `load(transform(extract()))`
- Print progress per stage

### Step 7 — Analytical Queries (`sql/queries.sql`)
Must cover:
- Summary statistics (total orders, avg order value)
- Trend over time (orders per month)
- Top sellers / top products by revenue
- Grouped analysis (by state, by category)
- Multi-table JOIN (at least 3 tables)
- At least one window function (`RANK`, `LAG`, or `ROW_NUMBER`)

### Step 8 — README.md
- How to run (docker, install deps, run ETL, run queries)
- Dataset description
- What cleaning was done and why

---

## Suggested Order of Work

1. Docker Compose + verify Postgres connects
2. Schema SQL (everything depends on this)
3. Extract (trivial)
4. Transform (most complex Python)
5. Load (connect Python to Postgres)
6. Verify data loaded correctly with manual queries
7. Write analytical queries
8. README
