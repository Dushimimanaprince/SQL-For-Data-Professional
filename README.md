# 🛒 E-Commerce Inventory & Order Management System

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=for-the-badge)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

## 📌 Project Overview
This project is a robust, automated PostgreSQL relational database designed to handle backend e-commerce operations, including inventory tracking, order processing, and business intelligence reporting. 

It was developed as a practical lab for the **"SQL for Professional"** module within the **AmaliTech Data Engineering Apprenticeship Programme**. The objective of this project is to demonstrate advanced database design, data integrity enforcement, and procedural SQL automation.

## 🗄️ Database Schema
The relational schema is normalized and enforces referential integrity using `CASCADE` and `RESTRICT` deletion rules.
* `Customers`: Stores client details and contact information.
* `Products`: Tracks inventory levels, pricing, and reorder thresholds.
* `Orders`: Records high-level transaction data and automatically calculated total spending.
* `OrderDetails`: The bridging table mapping multiple products to a single order.
* `InventoryLogs`: An automated audit trail tracking every manual or trigger-based change to stock levels.

## 🚀 Project Execution & Phase Breakdown

### Phase 1: Schema Design and Initialization (`01_schema_setup.sql`)
**Goal:** Establish the foundational relational database structure.
* **Implementation:** Created five interconnected tables using strong primary and foreign key relationships. 
* **Key Concepts:** Utilized constraints like `UNIQUE`, `NOT NULL`, and `DEFAULT 0.00` to ensure data cleanliness right at the entry point. Applied `ON DELETE CASCADE` to maintain referential integrity when parent records are removed.

### Phase 2: Procedural Automation and Validation (`02_automation_triggers.sql`)
**Goal:** Automate mathematical updates and enforce business rules without relying on frontend application logic.
* **Implementation:** Built PL/pgSQL functions paired with `AFTER INSERT` triggers on the `OrderDetails` table. 
* **Key Concepts:** 
    * **Dynamic Subtotals:** Automatically calculates `quantity * price` and updates the main `Orders` table total.
    * **Inventory Deduction & Logging:** Automatically subtracts purchased items from the `Products` table and logs the event in `InventoryLogs`.
    * **Negative Stock Prevention (Exception Handling):** Engineered `IF` logic within the trigger to check current stock levels *before* deduction, throwing a custom `RAISE EXCEPTION` to block the transaction if stock is insufficient.

### Phase 3: Business Intelligence and Reporting (`03_business_insights.sql`)
**Goal:** Extract meaningful insights from raw transaction data.
* **Implementation:** Developed complex analytical queries to monitor business health.
* **Key Concepts:** 
    * Used `JOIN` and `GROUP BY` to generate comprehensive order summaries (calculating total items per order).
    * Applied `COALESCE` with `LEFT JOIN` to accurately include dormant customers in reports without breaking mathematical functions.
    * Utilized conditional `CASE` statements to dynamically categorize customers into "Gold", "Silver", or "Bronze" tiers based on their lifetime spending metrics.

### Phase 4: Batch Processing Replenishment System (`04_replenishment_system.sql`)
**Goal:** Automate the restocking workflow for depleted inventory.
* **Implementation:** Created an on-demand Stored Procedure to handle batch updates.
* **Key Concepts:** 
    * Declared and utilized a **Cursor** to fetch and hold in memory only the products where `stock_quantity <= reorder_level`.
    * Built a `FOR ... LOOP` to iterate through the cursor row-by-row, systematically applying a standard restock amount (+20) and inserting individual audit records into the `InventoryLogs` for each updated product.

### Phase 5: Data Abstraction with Views (`05_views_and_optimizations.sql`)
**Goal:** Simplify data access for end-users, BI analysts, and reporting dashboards.
* **Implementation:** Wrapped the complex `JOIN` and aggregation queries from Phase 3 into virtual SQL Views (`vw_order_summaries` and `vw_low_stock_alerts`).
* **Key Concepts:** This abstraction ensures that users can execute a simple `SELECT * FROM vw_order_summaries` without needing to understand the underlying relational schema or write complex SQL themselves.

## 👨‍💻 About the Author
**Prince Dushimimana**  
*Data Engineering Apprentice @ AmaliTech 

