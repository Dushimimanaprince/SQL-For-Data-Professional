-- =====================================================================
-- test_order_triggers.sql
-- Tests: multi-product order, bulk discount, automatic totals,
-- automatic customer tiers and inventory logging.
-- Run after: sql/01 → data/mock_data.sql → sql/02
--
-- PART A inserts data: run it ONCE.
-- PART B only reads data: highlight each query and press F5.
-- =====================================================================

-- =====================================================================
-- PART A: place test orders (RUN ONCE)
-- =====================================================================

-- Test 1: multi-product order (MacBook x1 + Keyboard x2)
BEGIN;
INSERT INTO Orders (customer_id) VALUES (1);
INSERT INTO OrderDetails (order_id, product_id, quantity)
VALUES (currval('orders_order_id_seq'), 1, 1),
       (currval('orders_order_id_seq'), 3, 2);
COMMIT;

-- Test 2: bulk order (Keyboard x10 gets 5% off)
BEGIN;
INSERT INTO Orders (customer_id) VALUES (2);
INSERT INTO OrderDetails (order_id, product_id, quantity)
VALUES (currval('orders_order_id_seq'), 3, 10);
COMMIT;

-- Test 3: small order (Pixel x1)
BEGIN;
INSERT INTO Orders (customer_id) VALUES (3);
INSERT INTO OrderDetails (order_id, product_id, quantity)
VALUES (currval('orders_order_id_seq'), 2, 1);
COMMIT;

-- =====================================================================
-- PART B: check the results (run each query on its own)
-- =====================================================================

-- Check 1: prices and discounts set by the trigger
SELECT order_id, product_id, quantity, price, discount_pct
FROM OrderDetails
ORDER BY order_id;

-- Check 2: order totals calculated automatically
SELECT order_id, customer_id, total_amount
FROM Orders
ORDER BY order_id;

-- Check 3: tiers updated automatically
SELECT customer_id, name, tier
FROM Customers
ORDER BY customer_id;

-- Check 4: stock after orders
SELECT product_id, name, stock_quantity
FROM Products
ORDER BY product_id;

-- Check 5: inventory log
SELECT * FROM InventoryLogs ORDER BY log_id;