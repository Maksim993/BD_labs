-- ЛР №2. Часть 1.2. Операции изменения данных

-- 1. Добавление новой сущности и связанной записи
BEGIN;

INSERT INTO customers (email, full_name, phone)
VALUES ('new.customer@example.com', 'Новый Клиент', '+79990000100');

INSERT INTO orders (customer_id, order_date, status)
SELECT customer_id, CURRENT_TIMESTAMP, 'new'
FROM customers
WHERE email = 'new.customer@example.com';

COMMIT;

-- 2. Изменение состояния существующей операции
UPDATE orders
SET status = 'shipped'
WHERE order_id = 4
  AND status = 'new';

-- 3. Массовое изменение нескольких записей
UPDATE products
SET stock_quantity = stock_quantity + 5
WHERE category_id = 4;

-- 4. DELETE с учётом ограничений целостности:
-- удаляем клиента, у которого нет заказов.
DELETE FROM customers c
WHERE c.email = 'irina.popova@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM orders o
      WHERE o.customer_id = c.customer_id
  );

-- 5. Демонстрация ROLLBACK
BEGIN;

UPDATE products
SET price = price * 0.90
WHERE category_id = 4;

SELECT product_id, name, price
FROM products
WHERE category_id = 4
ORDER BY product_id;

ROLLBACK;
