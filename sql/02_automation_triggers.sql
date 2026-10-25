--0.  Add the price and discount trigger
CREATE OR REPLACE FUNCTION set_price_and_discount()
RETURNS TRIGGER AS $$
DECLARE
    base_price DECIMAL(10, 2);
BEGIN
    SELECT price INTO base_price FROM Products WHERE product_id = NEW.product_id;

    NEW.discount_pct := CASE
        WHEN NEW.quantity >= 50 THEN 15
        WHEN NEW.quantity >= 20 THEN 10
        WHEN NEW.quantity >= 10 THEN 5
        ELSE 0
    END;

    NEW.price := ROUND(base_price * (1 - NEW.discount_pct / 100), 2);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_before_order_detail_insert ON OrderDetails;
CREATE TRIGGER trg_before_order_detail_insert
BEFORE INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION set_price_and_discount();


-- 1. Function to deduct stock and log inventory changes
CREATE OR REPLACE FUNCTION process_order_update_stock()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INT;
BEGIN

    SELECT stock_quantity INTO current_stock
    FROM Products
    WHERE product_id = NEW.product_id
    FOR UPDATE;

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
DROP TRIGGER IF EXISTS trg_after_order_detail_insert ON OrderDetails;
CREATE TRIGGER trg_after_order_detail_insert
AFTER INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION process_order_update_stock();

-- 3. Function to automate total amount calculation for each order
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
DROP TRIGGER IF EXISTS trg_update_order_total ON OrderDetails;
CREATE TRIGGER trg_update_order_total
AFTER INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

---5. Add the tier trigger ----------
CREATE OR REPLACE FUNCTION update_customer_tier()
RETURNS TRIGGER AS $$
DECLARE
    total_spent DECIMAL(12, 2);
BEGIN
    SELECT COALESCE(SUM(total_amount), 0) INTO total_spent
    FROM Orders WHERE customer_id = NEW.customer_id;

    UPDATE Customers
    SET tier = CASE
        WHEN total_spent >= 2000 THEN 'Gold'
        WHEN total_spent >= 500  THEN 'Silver'
        ELSE 'Bronze'
    END
    WHERE customer_id = NEW.customer_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_customer_tier ON Orders;
CREATE TRIGGER trg_update_customer_tier
AFTER UPDATE OF total_amount ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_customer_tier();


