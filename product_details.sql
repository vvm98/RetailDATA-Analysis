SELECT product_name, MH1_description,
       COUNT(*) AS line,
       SUM(quantity) AS units,
       ROUND(SUM(line_value), 0) AS net_sales
FROM product_sales
GROUP BY product_name, MH1_description
ORDER BY net_sales DESC;

