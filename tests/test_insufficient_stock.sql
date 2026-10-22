-- =====================================================================
-- test_insufficient_stock.sql
-- Test: an order larger than the available stock is rejected and
-- nothing is saved.
-- Run after: tests/test_order_triggers.sql (Pixel has 7 in stock)
--
-- How to run in pgAdmin:
--   1. Run the BEGIN ... COMMIT block → expect the "Insufficient stock" error
--   2. Run ROLLBACK;
--   3. Run the two checks at the bottom
-- =====================================================================

-- Step 1: try to order 50 Pixels when only 7 are in stock
BEGIN;
INSERT INTO Orders (customer_id) VALUES (4);
INSERT INTO OrderDetails (order_id, product_id, quantity)
VALUES (currval('orders_order_id_seq'), 2, 50);
COMMIT;

-- Step 2: close the failed transaction
ROLLBACK;

-- Step 3: confirm nothing changed
SELECT name, stock_quantity FROM Products WHERE product_id = 2;  -- still 7
SELECT * FROM Orders WHERE customer_id = 4;                      -- 0 rows