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

-- 2. View displaying products that are low on stock[cite: 2]
CREATE OR REPLACE VIEW vw_low_stock_alerts AS
SELECT 
    product_id,
    name AS product_name,
    stock_quantity,
    reorder_level
FROM Products
WHERE stock_quantity <= reorder_level;