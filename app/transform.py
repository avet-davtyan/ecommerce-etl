import pandas as pd


def transform(dfs: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    out = {}

    # --- category_translation ---
    df = dfs['category_translation'].copy()
    # strip BOM that pandas picks up from the first column
    df.columns = [c.lstrip('﻿') for c in df.columns]
    df = df.dropna(subset=['product_category_name', 'product_category_name_english'])
    df = df.drop_duplicates(subset=['product_category_name'])
    out['category_translation'] = df

    # --- geolocation ---
    df = dfs['geolocation'].copy()
    df['geolocation_zip_code_prefix'] = df['geolocation_zip_code_prefix'].str.zfill(5)
    df['geolocation_lat'] = pd.to_numeric(df['geolocation_lat'], errors='coerce')
    df['geolocation_lng'] = pd.to_numeric(df['geolocation_lng'], errors='coerce')
    df = df.dropna(subset=['geolocation_lat', 'geolocation_lng'])
    df = df.drop_duplicates()
    out['geolocation'] = df

    # --- customers ---
    df = dfs['customers'].copy()
    df = df.dropna(subset=['customer_id'])
    df['customer_zip_code_prefix'] = df['customer_zip_code_prefix'].str.zfill(5)
    df = df.drop_duplicates(subset=['customer_id'])
    out['customers'] = df

    # --- sellers ---
    df = dfs['sellers'].copy()
    df = df.dropna(subset=['seller_id'])
    df['seller_zip_code_prefix'] = df['seller_zip_code_prefix'].str.zfill(5)
    df = df.drop_duplicates(subset=['seller_id'])
    out['sellers'] = df

    # --- products ---
    df = dfs['products'].copy()
    df = df.dropna(subset=['product_id'])
    df = df.rename(columns={
        'product_name_lenght':        'product_name_length',
        'product_description_lenght': 'product_description_length',
    })
    df['product_category_name'] = df['product_category_name'].fillna('unknown')
    for col in ['product_name_length', 'product_description_length', 'product_photos_qty',
                'product_weight_g', 'product_length_cm', 'product_height_cm', 'product_width_cm']:
        df[col] = pd.to_numeric(df[col], errors='coerce').astype('Int64')
    df = df.drop_duplicates(subset=['product_id'])
    out['products'] = df

    # --- orders ---
    df = dfs['orders'].copy()
    df = df.dropna(subset=['order_id', 'customer_id'])
    for col in ['order_purchase_timestamp', 'order_approved_at',
                'order_delivered_carrier_date', 'order_delivered_customer_date',
                'order_estimated_delivery_date']:
        df[col] = pd.to_datetime(df[col], errors='coerce')
    df = df.drop_duplicates(subset=['order_id'])
    df = df[df['customer_id'].isin(out['customers']['customer_id'])]
    out['orders'] = df

    # --- order_items ---
    df = dfs['order_items'].copy()
    df = df.dropna(subset=['order_id', 'order_item_id', 'product_id', 'seller_id'])
    df['order_item_id']       = pd.to_numeric(df['order_item_id'], errors='coerce').astype('Int64')
    df['price']               = pd.to_numeric(df['price'], errors='coerce')
    df['freight_value']       = pd.to_numeric(df['freight_value'], errors='coerce')
    df['shipping_limit_date'] = pd.to_datetime(df['shipping_limit_date'], errors='coerce')
    df = df.drop_duplicates(subset=['order_id', 'order_item_id'])
    df = df[df['order_id'].isin(out['orders']['order_id'])]
    df = df[df['product_id'].isin(out['products']['product_id'])]
    df = df[df['seller_id'].isin(out['sellers']['seller_id'])]
    out['order_items'] = df

    # --- order_payments ---
    df = dfs['order_payments'].copy()
    df = df.dropna(subset=['order_id', 'payment_sequential'])
    df['payment_sequential']   = pd.to_numeric(df['payment_sequential'], errors='coerce').astype('Int64')
    df['payment_installments'] = pd.to_numeric(df['payment_installments'], errors='coerce').astype('Int64')
    df['payment_value']        = pd.to_numeric(df['payment_value'], errors='coerce')
    df = df.drop_duplicates(subset=['order_id', 'payment_sequential'])
    df = df[df['order_id'].isin(out['orders']['order_id'])]
    out['order_payments'] = df

    # --- order_reviews ---
    df = dfs['order_reviews'].copy()
    df = df.dropna(subset=['review_id', 'order_id', 'review_score',
                           'review_creation_date', 'review_answer_timestamp'])
    df['review_score']            = pd.to_numeric(df['review_score'], errors='coerce').astype('Int64')
    df['review_creation_date']    = pd.to_datetime(df['review_creation_date'], errors='coerce')
    df['review_answer_timestamp'] = pd.to_datetime(df['review_answer_timestamp'], errors='coerce')
    df = df.drop_duplicates(subset=['review_id', 'order_id'])
    df = df[df['order_id'].isin(out['orders']['order_id'])]
    out['order_reviews'] = df

    for name, df in out.items():
        print(f"[transform] {name}: {len(df)} rows")

    return out


if __name__ == '__main__':
    from extract import extract
    transform(extract())
