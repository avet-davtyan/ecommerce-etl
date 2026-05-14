# Project Progress

## What Is Required

### Tasks
| # | Task | Status |
|---|------|--------|
| 1 | Data Understanding — explore dataset, identify entities & relationships | ✅ Done |
| 2 | Data Modeling — design schema (≥3 tables, PKs/FKs, constraints, indexes, normalized) | ⬜ Todo |
| 3 | Data Cleaning & Transformation — nulls, duplicates, format standardization | ⬜ Todo |
| 4 | Python ETL Pipeline — `extract.py`, `transform.py`, `load.py`, `main.py` | ⬜ Todo |
| 5 | Database Implementation — `schema.sql` (tables, constraints, indexes) | ⬜ Todo |
| 6 | SQL Analysis — `queries.sql` with JOINs, GROUP BY, ORDER BY, window functions | ⬜ Todo |

### Deliverables Checklist
- [ ] `app/extract.py`
- [ ] `app/transform.py`
- [ ] `app/load.py`
- [ ] `app/main.py`
- [ ] `sql/schema.sql`
- [ ] `sql/queries.sql`
- [ ] `README.md`
- [ ] `requirements.txt`
- [ ] Dataset description (see `docs/dataset.md`)
- [ ] Data cleaning explanation (document in README or separate doc)

### SQL Analysis Must Include
- [ ] Summary statistics
- [ ] Trend analysis (orders over time)
- [ ] Top / bottom entities (top sellers, top products)
- [ ] Grouped analysis (by category, by state)
- [ ] Multi-table JOINs
- [ ] At least one window function (e.g., RANK, ROW_NUMBER, LAG)
- [ ] At least one real analytical question

---

## What We Have Done

| Step | Detail |
|------|--------|
| Dataset selected | Brazilian E-Commerce (Olist) from Kaggle |
| Repo initialized | `git init` in `homework-2/` |
| Folder structure created | `data/`, `app/`, `sql/`, `docs/` |
| CLAUDE.md created | Claude Code guidance file |
| requirements.txt created | pandas, sqlalchemy, psycopg2-binary, python-dotenv |
| .gitignore created | ignores CSVs, .env, pycache |
| Documentation started | This file + `docs/dataset.md` |

---

## What Is Next

1. Download Olist CSVs from Kaggle → place in `data/`
2. Design and write `sql/schema.sql`
3. Implement `app/extract.py`, `transform.py`, `load.py`, `main.py`
4. Write `sql/queries.sql`
5. Write `README.md`
