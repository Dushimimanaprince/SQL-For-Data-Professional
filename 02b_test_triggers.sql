
INSERT INTO Orders (customer_id) 
VALUES (1);


INSERT INTO OrderDetails (order_id, product_id, quantity, price) 
VALUES (1, 2, 2, 350.00);

SELECT order_id, total_amount FROM Orders WHERE order_id = 1;


SELECT name, stock_quantity FROM Products WHERE product_id = 2;


SELECT * FROM InventoryLogs;