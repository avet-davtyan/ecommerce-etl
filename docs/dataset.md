# Dataset: Brazilian E-Commerce Public Dataset by Olist

## Source
- **URL:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- **Provider:** Olist (Brazilian e-commerce marketplace)
- **License:** CC BY-NC-SA 4.0

## Overview
100,000 orders placed on the Olist marketplace between 2016 and 2018.
Data covers multiple marketplaces across Brazil.

## Files & Tables

| File | Rows (approx) | Key Columns |
|------|---------------|-------------|
| `olist_orders_dataset.csv` | 99,441 | `order_id`, `customer_id`, `order_status`, `order_purchase_timestamp` |
| `olist_order_items_dataset.csv` | 112,650 | `order_id`, `product_id`, `seller_id`, `price`, `freight_value` |
| `olist_customers_dataset.csv` | 99,441 | `customer_id`, `customer_unique_id`, `customer_city`, `customer_state` |
| `olist_sellers_dataset.csv` | 3,095 | `seller_id`, `seller_city`, `seller_state` |
| `olist_products_dataset.csv` | 32,951 | `product_id`, `product_category_name`, `product_weight_g` |
| `olist_order_payments_dataset.csv` | 103,886 | `order_id`, `payment_type`, `payment_value` |
| `olist_order_reviews_dataset.csv` | 99,224 | `review_id`, `order_id`, `review_score`, `review_creation_date` |
| `olist_geolocation_dataset.csv` | 1,000,163 | `geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_state` |
| `product_category_name_translation.csv` | 71 | `product_category_name`, `product_category_name_english` |

## Entity Relationships

```
customers ──< orders >── order_items >── products
                  │                          │
                  └──< order_payments    sellers
                  └──< order_reviews
                  
customers/sellers ── geolocation (via zip code)
products ── product_category_name_translation
```

## Why This Dataset Fits the Homework

- Natural relational structure — 9 files map directly to 9 DB tables
- Rich for SQL analysis: time series, geographic grouping, seller/product rankings
- Clear foreign key relationships
- Real-world data cleaning challenges (nulls in reviews, geolocation duplicates, category names in Portuguese)
- Manageable size for a local PostgreSQL setup
