-- 1. Function to deduct stock and log inventory changes
CREATE OR REPLACE FUNCTION process_order_update_stock()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INT;
BEGIN

    SELECT stock_quantity INTO current_stock 
    FROM Products 
    WHERE product_id = NEW.product_id;


    IF current_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Transaction Failed: Insufficient stock. You requested %, but only % are available.', NEW.quantity, current_stock;
    END IF;


    UPDATE Products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;


    INSERT INTO InventoryLogs (product_id, change_amount, change_reason, log_date)
    VALUES (NEW.product_id, -NEW.quantity, 'Automated: Order Placed', CURRENT_TIMESTAMP);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Trigger to fire the stock update function after an order detail is added
CREATE TRIGGER trg_after_order_detail_insert
AFTER INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION process_order_update_stock();

-- 3. Function to automate total amount calculation for each order[cite: 2]
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Add the cost of the new items to the order's total amount
    UPDATE Orders
    SET total_amount = total_amount + (NEW.quantity * NEW.price)
    WHERE order_id = NEW.order_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Trigger to fire the total amount function after an order detail is added
CREATE TRIGGER trg_update_order_total
AFTER INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION update_order_total();