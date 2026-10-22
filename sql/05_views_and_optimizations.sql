-- 1. View summarizing order information
CREATE OR REPLACE VIEW vw_order_summaries AS
SELECT 
    c.name AS customer_name,
    o.order_date,
    o.total_amount,
    SUM(od.quantity) AS number_of_items_per_order
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
GROUP BY c.name, o.order_id, o.order_date, o.total_amount;

-- 2. View displaying products that are low on stock
CREATE OR REPLACE VIEW vw_low_stock_alerts AS
SELECT 
    product_id,
    name AS product_name,
    stock_quantity,
    reorder_level
FROM Products
WHERE stock_quantity < reorder_level;

-- 3. View showing customer spending and tier
CREATE OR REPLACE VIEW vw_customer_spending AS
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(o.order_id) AS number_of_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    c.tier AS customer_tier
FROM Customers c
LEFT JOIN Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, c.tier;

-- 5. Using the views
SELECT * FROM vw_order_summaries;
SELECT * FROM vw_low_stock_alerts;
SELECT * FROM vw_customer_spending;

-- 6. Checking the query plan
EXPLAIN ANALYZE
SELECT * FROM Orders WHERE customer_id = 1;