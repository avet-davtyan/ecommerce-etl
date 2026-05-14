-- Drop tables in reverse FK dependency order
DROP TABLE IF EXISTS order_reviews CASCADE;
DROP TABLE IF EXISTS order_payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS geolocation CASCADE;
DROP TABLE IF EXISTS product_category_name_translation CASCADE;

-- No FK dependencies
CREATE TABLE product_category_name_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100) NOT NULL
);

-- No FK dependencies; multiple lat/lng rows per zip code so surrogate PK
CREATE TABLE geolocation (
    id                          SERIAL         PRIMARY KEY,
    geolocation_zip_code_prefix CHAR(5)        NOT NULL,
    geolocation_lat             FLOAT          NOT NULL,
    geolocation_lng             FLOAT          NOT NULL,
    geolocation_city            VARCHAR(100)   NOT NULL,
    geolocation_state           CHAR(2)        NOT NULL
);

CREATE TABLE customers (
    customer_id              VARCHAR(32)  PRIMARY KEY,
    customer_unique_id       VARCHAR(32)  NOT NULL,
    customer_zip_code_prefix CHAR(5)      NOT NULL,
    customer_city            VARCHAR(100) NOT NULL,
    customer_state           CHAR(2)      NOT NULL
);

CREATE TABLE sellers (
    seller_id              VARCHAR(32)  PRIMARY KEY,
    seller_zip_code_prefix CHAR(5)      NOT NULL,
    seller_city            VARCHAR(100) NOT NULL,
    seller_state           CHAR(2)      NOT NULL
);

-- product_category_name left nullable; not FK-linked to translation
-- (not all categories have a translation row)
CREATE TABLE products (
    product_id                 VARCHAR(32)  PRIMARY KEY,
    product_category_name      VARCHAR(100),
    product_name_length        INTEGER,
    product_description_length INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

CREATE TABLE orders (
    order_id                      VARCHAR(32) PRIMARY KEY,
    customer_id                   VARCHAR(32) NOT NULL REFERENCES customers(customer_id),
    order_status                  VARCHAR(20) NOT NULL
        CHECK (order_status IN (
            'delivered', 'shipped', 'canceled', 'unavailable',
            'invoiced', 'processing', 'created', 'approved'
        )),
    order_purchase_timestamp      TIMESTAMP   NOT NULL,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id            VARCHAR(32)    NOT NULL REFERENCES orders(order_id),
    order_item_id       INTEGER        NOT NULL,
    product_id          VARCHAR(32)    NOT NULL REFERENCES products(product_id),
    seller_id           VARCHAR(32)    NOT NULL REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP      NOT NULL,
    price               NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    freight_value       NUMERIC(10, 2) NOT NULL CHECK (freight_value >= 0),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id             VARCHAR(32)    NOT NULL REFERENCES orders(order_id),
    payment_sequential   INTEGER        NOT NULL,
    payment_type         VARCHAR(20)    NOT NULL
        CHECK (payment_type IN ('credit_card', 'boleto', 'voucher', 'debit_card', 'not_defined')),
    payment_installments INTEGER        NOT NULL CHECK (payment_installments >= 0),
    payment_value        NUMERIC(10, 2) NOT NULL CHECK (payment_value >= 0),
    PRIMARY KEY (order_id, payment_sequential)
);

-- review_id is not unique in the raw data, so PK is (review_id, order_id)
CREATE TABLE order_reviews (
    review_id               VARCHAR(32) NOT NULL,
    order_id                VARCHAR(32) NOT NULL REFERENCES orders(order_id),
    review_score            SMALLINT    NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP   NOT NULL,
    review_answer_timestamp TIMESTAMP   NOT NULL,
    PRIMARY KEY (review_id, order_id)
);

-- Indexes
CREATE INDEX idx_orders_customer_id          ON orders(customer_id);
CREATE INDEX idx_orders_purchase_timestamp   ON orders(order_purchase_timestamp);
CREATE INDEX idx_orders_status               ON orders(order_status);
CREATE INDEX idx_order_items_product_id      ON order_items(product_id);
CREATE INDEX idx_order_items_seller_id       ON order_items(seller_id);
CREATE INDEX idx_order_reviews_order_id      ON order_reviews(order_id);
CREATE INDEX idx_geolocation_zip_code        ON geolocation(geolocation_zip_code_prefix);
CREATE INDEX idx_customers_zip_code          ON customers(customer_zip_code_prefix);
CREATE INDEX idx_products_category_name      ON products(product_category_name);
