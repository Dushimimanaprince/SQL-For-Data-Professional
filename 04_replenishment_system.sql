-- 1. Create the Replenishment Procedure
CREATE OR REPLACE PROCEDURE replenish_low_stock()
LANGUAGE plpgsql
AS $$
DECLARE

    product_record RECORD;

    low_stock_cursor CURSOR FOR 
        SELECT product_id, name, stock_quantity, reorder_level 
        FROM Products 
        WHERE stock_quantity < reorder_level;
        
    restock_amount INT; 
BEGIN

    FOR product_record IN low_stock_cursor LOOP
        
        restock_amount := product_record.reorder_level * 2 - product_record.stock_quantity;
        UPDATE Products
        SET stock_quantity = stock_quantity + restock_amount
        WHERE product_id = product_record.product_id;

        INSERT INTO InventoryLogs (product_id, change_amount, change_reason, log_date)
        VALUES (product_record.product_id, restock_amount, 'Automated: Stock Replenished', CURRENT_TIMESTAMP);
        

        RAISE NOTICE 'Replenished % by % units.', product_record.name, restock_amount;
        
    END LOOP;
END;
$$;

-- 2. Demonstration

-- Step 1: identify low-stock products
SELECT product_id, name, stock_quantity, reorder_level
FROM Products
WHERE stock_quantity < reorder_level;

-- Step 2: replenish them
CALL replenish_low_stock();

-- Step 3: confirm stock is restored
SELECT product_id, name, stock_quantity, reorder_level FROM Products ORDER BY product_id;

-- Step 4: check the replenishment in the audit log
SELECT * FROM InventoryLogs WHERE change_amount > 0 ORDER BY log_id;