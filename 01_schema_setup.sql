
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20)
);


CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    reorder_level INT NOT NULL
);


CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) DEFAULT 0.00
);


CREATE TABLE OrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES Products(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL 
);


CREATE TABLE InventoryLogs (
    log_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Products(product_id) ON DELETE CASCADE,
    change_amount INT NOT NULL, 
    change_reason VARCHAR(255),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);