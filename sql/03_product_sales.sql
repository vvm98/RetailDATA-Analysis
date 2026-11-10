-- 03_product_sales.sql
-- Product performance: revenue vs volume, and each product's share of net sales.

WITH product_totals AS (
    SELECT product_name, MH1_description,
           COUNT(*)            AS lines,
           SUM(quantity)       AS units,
           SUM(line_value)     AS net_sales
    FROM product_sales
    GROUP BY product_name, MH1_description
)
SELECT product_name, MH1_description, units,
       ROUND(net_sales, 0) AS net_sales,
       ROUND(net_sales / SUM(net_sales) OVER () * 100, 1) AS share_of_sales,
       DENSE_RANK() OVER (ORDER BY net_sales DESC) AS sales_rank,
       DENSE_RANK() OVER (ORDER BY units DESC)     AS units_rank
FROM product_totals
ORDER BY sales_rank;

-- Category mix: share of net sales vs share of units
SELECT MH1_description,
       SUM(quantity) AS units,
       ROUND(SUM(line_value), 0) AS net_sales,
       ROUND(SUM(line_value) / SUM(SUM(line_value)) OVER () * 100, 1) AS share_of_sales,
       ROUND(SUM(quantity)   / SUM(SUM(quantity))   OVER () * 100, 1) AS share_of_units
FROM product_sales
GROUP BY MH1_description
ORDER BY net_sales DESC;
