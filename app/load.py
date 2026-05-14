import io
import os

import pandas as pd
import psycopg2
from dotenv import load_dotenv

load_dotenv()

# FK-safe insert order
LOAD_ORDER = [
    'category_translation',
    'geolocation',
    'customers',
    'sellers',
    'products',
    'orders',
    'order_items',
    'order_payments',
    'order_reviews',
]

TABLE_NAMES = {
    'category_translation': 'product_category_name_translation',
    'geolocation':          'geolocation',
    'customers':            'customers',
    'sellers':              'sellers',
    'products':             'products',
    'orders':               'orders',
    'order_items':          'order_items',
    'order_payments':       'order_payments',
    'order_reviews':        'order_reviews',
}


def _get_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
    )


def _copy_df(cursor, df: pd.DataFrame, table: str):
    buffer = io.StringIO()
    df.to_csv(buffer, index=False, header=False, na_rep='\\N')
    buffer.seek(0)
    cursor.copy_expert(
        f"COPY {table} ({', '.join(df.columns)}) FROM STDIN WITH (FORMAT CSV, NULL '\\N')",
        buffer,
    )


def load(dfs: dict[str, pd.DataFrame]):
    conn = _get_connection()
    try:
        with conn:
            with conn.cursor() as cur:
                # truncate in reverse order to respect FKs
                for key in reversed(LOAD_ORDER):
                    cur.execute(f'TRUNCATE TABLE {TABLE_NAMES[key]} CASCADE')

                for key in LOAD_ORDER:
                    table = TABLE_NAMES[key]
                    df = dfs[key]
                    _copy_df(cur, df, table)
                    print(f"[load] {table}: {len(df)} rows inserted")
    finally:
        conn.close()


if __name__ == '__main__':
    from extract import extract
    from transform import transform
    load(transform(extract()))
