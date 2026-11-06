--  Подробная информация о заказах
SELECT
    o.order_id,
    o.order_date,
    c.full_name AS customer,
    p.name AS product,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total,
    o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_date, o.order_id;

--  Товары, которые ни разу не заказывали
SELECT
    p.product_id,
    p.name AS product,
    c.name AS category
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_id IS NULL
ORDER BY p.product_id;

-- Оплаченные заказы дороже 50 000 рублей
SELECT
    o.order_id,
    c.full_name AS customer,
    o.order_date,
    pay.amount,
    pay.payment_method
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN payments pay ON pay.order_id = o.order_id
WHERE pay.status = 'paid'
  AND pay.amount > 50000
ORDER BY pay.amount DESC;



-- Агрегация

-- Количество заказов каждого клиента
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY orders_count DESC, c.customer_id;

-- Категории со средней ценой товара выше 30 000
SELECT
    c.category_id,
    c.name AS category,
    COUNT(p.product_id) AS products_count,
    ROUND(AVG(p.price), 2) AS avg_price,
    MIN(p.price) AS min_price,
    MAX(p.price) AS max_price
FROM categories c
JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.name
HAVING AVG(p.price) > 30000
ORDER BY avg_price DESC;

-- Сравнение продаж по месяцам
SELECT
    DATE_TRUNC('month', o.order_date)::date AS month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(oi.quantity) AS items_sold,
    SUM(oi.quantity * oi.unit_price) AS turnover
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- Подзапросы

-- Товары дороже средней цены по своей категории
SELECT
    p.product_id,
    p.name,
    p.price,
    c.name AS category
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.name, p.price DESC;

-- EXISTS: клиенты, у которых есть завершённый заказ
SELECT
    c.customer_id,
    c.full_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'completed'
)
ORDER BY c.customer_id;

-- NOT EXISTS: клиенты, у которых нет ни одного заказа
SELECT
    c.customer_id,
    c.full_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- Коррелированный подзапрос:
-- индивидуальное количество заказов для каждого клиента
SELECT
    c.customer_id,
    c.full_name,
    (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.customer_id = c.customer_id
    ) AS orders_count
FROM customers c
ORDER BY orders_count DESC, c.customer_id;
