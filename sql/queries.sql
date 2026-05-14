-- ============================================================
-- 1. Summary statistics
-- ============================================================
SELECT
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    COUNT(DISTINCT o.customer_id)                     AS total_customers,
    ROUND(SUM(op.payment_value)::NUMERIC, 2)          AS total_revenue,
    ROUND(AVG(op.payment_value)::NUMERIC, 2)          AS avg_payment_value,
    ROUND(MIN(op.payment_value)::NUMERIC, 2)          AS min_payment_value,
    ROUND(MAX(op.payment_value)::NUMERIC, 2)          AS max_payment_value
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id;


-- ============================================================
-- 2. Orders per month — trend analysis
-- ============================================================
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(*)                                       AS total_orders
FROM orders
GROUP BY month
ORDER BY month;


-- ============================================================
-- 3. Top 10 sellers by total revenue
-- ============================================================
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id)                          AS total_orders
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 4. Top 10 products by total revenue
-- ============================================================
SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    ROUND(SUM(oi.price)::NUMERIC, 2)  AS total_revenue,
    COUNT(*)                           AS times_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY oi.product_id, category
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 5. Orders and revenue by customer state
-- ============================================================
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(op.payment_value)::NUMERIC, 2)            AS total_revenue,
    ROUND(AVG(op.payment_value)::NUMERIC, 2)            AS avg_order_value
FROM orders o
JOIN customers c  ON o.customer_id  = c.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- ============================================================
-- 6. Orders and revenue by product category
-- ============================================================
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT oi.order_id)                                          AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)                                    AS total_revenue,
    ROUND(AVG(r.review_score), 2)                                       AS avg_review_score
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
LEFT JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY category
ORDER BY total_revenue DESC;


-- ============================================================
-- 7. Average review score per product category (multi-table JOIN)
-- ============================================================
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    ROUND(AVG(r.review_score), 2)                                       AS avg_score,
    COUNT(r.review_id)                                                  AS total_reviews
FROM order_reviews r
JOIN orders      o  ON r.order_id    = o.order_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY category
HAVING COUNT(r.review_id) >= 50
ORDER BY avg_score DESC;


-- ============================================================
-- 8. Seller ranking by revenue — window function RANK()
-- ============================================================
SELECT
    seller_id,
    seller_state,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC)                        AS revenue_rank,
    RANK() OVER (PARTITION BY seller_state ORDER BY total_revenue DESC) AS rank_within_state
FROM (
    SELECT
        oi.seller_id,
        s.seller_state,
        ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue
    FROM order_items oi
    JOIN sellers s ON oi.seller_id = s.seller_id
    GROUP BY oi.seller_id, s.seller_state
) ranked
ORDER BY revenue_rank
LIMIT 20;


-- ============================================================
-- 9. Month-over-month order growth — window function LAG()
-- ============================================================
SELECT
    month,
    total_orders,
    LAG(total_orders) OVER (ORDER BY month)                              AS prev_month_orders,
    total_orders - LAG(total_orders) OVER (ORDER BY month)               AS absolute_change,
    ROUND(
        100.0 * (total_orders - LAG(total_orders) OVER (ORDER BY month))
        / NULLIF(LAG(total_orders) OVER (ORDER BY month), 0),
    2) AS pct_change
FROM (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp) AS month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY month
) monthly
ORDER BY month;
