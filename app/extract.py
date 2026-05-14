import os
import pandas as pd

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'data')

FILES = {
    'customers':    'olist_customers_dataset.csv',
    'geolocation':  'olist_geolocation_dataset.csv',
    'order_items':  'olist_order_items_dataset.csv',
    'order_payments': 'olist_order_payments_dataset.csv',
    'order_reviews': 'olist_order_reviews_dataset.csv',
    'orders':       'olist_orders_dataset.csv',
    'products':     'olist_products_dataset.csv',
    'sellers':      'olist_sellers_dataset.csv',
    'category_translation': 'product_category_name_translation.csv',
}


def extract() -> dict[str, pd.DataFrame]:
    dataframes = {}
    for name, filename in FILES.items():
        path = os.path.join(DATA_DIR, filename)
        dataframes[name] = pd.read_csv(path, dtype=str)
        print(f"[extract] {name}: {len(dataframes[name])} rows")
    return dataframes


if __name__ == '__main__':
    extract()
