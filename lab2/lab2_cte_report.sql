-- Какие категории товаров приносят наибольший оборот?

WITH sales_details AS (
    SELECT
        o.order_id,
        c.category_id,
        c.name AS category_name,
        oi.quantity,
        oi.quantity * oi.unit_price AS line_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories c ON c.category_id = p.category_id
    WHERE o.status <> 'cancelled'
),
category_stats AS (
    SELECT
        category_id,
        category_name,
        COUNT(DISTINCT order_id) AS orders_count,
        SUM(quantity) AS items_sold,
        SUM(line_total) AS turnover,
        ROUND(AVG(line_total), 2) AS avg_line_total
    FROM sales_details
    GROUP BY category_id, category_name
)
SELECT
    category_name,
    orders_count,
    items_sold,
    turnover,
    avg_line_total
FROM category_stats
ORDER BY turnover DESC;
