-- 1. Order Summaries per Customer
-- Uses JOIN to link the tables and GROUP BY to count the number of items per specific order.
SELECT 
    c.name AS customer_name,
    o.order_date,
    o.total_amount,
    SUM(od.quantity) AS number_of_items
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
GROUP BY c.name, o.order_id, o.order_date, o.total_amount
ORDER BY o.order_date DESC;

-- 2. Low Stock Identification Report[cite: 2]
-- Uses the WHERE clause to filter products below their reorder level and a CASE statement to flag urgency.
SELECT 
    name AS product_name,
    stock_quantity,
    reorder_level,
    CASE 
        WHEN stock_quantity = 0 THEN 'URGENT: Out of Stock'
        ELSE 'WARNING: Reorder Needed'
    END AS stock_status
FROM Products
WHERE stock_quantity <= reorder_level
ORDER BY stock_quantity ASC;

-- 3. Customer Spending Categorization (Tiers)[cite: 2]
-- Uses a LEFT JOIN to include all customers (even those who haven't ordered), aggregates their total spending, and uses CASE to assign a tier.
SELECT 
    c.name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    CASE 
        WHEN COALESCE(SUM(o.total_amount), 0) >= 2000 THEN 'Gold Tier'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 500 THEN 'Silver Tier'
        ELSE 'Bronze Tier'
    END AS customer_tier
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;