-- =====================================================================
-- test_views.sql
-- Shows the views in use and checks a query plan.
-- Run after: sql/05_views_and_optimizations.sql
-- =====================================================================

-- Order summaries
SELECT * FROM vw_order_summaries;

-- Low-stock alerts (expected: 0 rows after replenishment)
SELECT * FROM vw_low_stock_alerts;

-- Customer spending and tiers
SELECT * FROM vw_customer_spending ORDER BY total_spent DESC;

-- Query plan (Seq Scan is expected on small data)
EXPLAIN ANALYZE
SELECT * FROM Orders WHERE customer_id = 1;