-- =====================================================================
-- test_replenishment.sql
-- Demonstrates identifying low-stock products and replenishing them.
-- Run after: sql/04_replenishment_system.sql
-- =====================================================================

-- Step 1: identify low-stock products
SELECT product_id, name, stock_quantity, reorder_level
FROM Products
WHERE stock_quantity < reorder_level;

-- Step 2: replenish them (see the Messages tab for the notices)
CALL replenish_low_stock();

-- Step 3: confirm stock is restored
SELECT product_id, name, stock_quantity, reorder_level
FROM Products
ORDER BY product_id;

-- Step 4: full inventory audit trail (orders and replenishments)
SELECT * FROM InventoryLogs ORDER BY log_id;