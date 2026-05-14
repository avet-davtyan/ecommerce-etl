import os
import psycopg2
from dotenv import load_dotenv

from extract import extract
from transform import transform
from load import load

load_dotenv()

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), '..', 'sql', 'schema.sql')


def apply_schema():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
    )
    with open(SCHEMA_PATH, 'r') as f:
        sql = f.read()
    with conn:
        with conn.cursor() as cur:
            cur.execute(sql)
    conn.close()
    print("[schema] schema applied")


if __name__ == '__main__':
    apply_schema()
    load(transform(extract()))
