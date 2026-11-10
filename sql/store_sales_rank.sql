SELECT * FROM retail.daily_footfall ;
WITH store_totals AS (
    SELECT s.store_name, s.store_id, s.location_type, s.city,
           SUM(f.footfall) AS footfall,
           SUM(f.bills) AS bills,
           ROUND(SUM(f.bills) / SUM(f.footfall) * 100, 2) AS conversion_pct,
           ROUND(SUM(f.net_sales) / SUM(f.bills), 2) AS atv,
           ROUND(SUM(f.net_sales), 0) AS net_sales
    FROM daily_footfall f
    JOIN stores s ON f.store_id = s.store_id
    GROUP BY s.store_id, s.store_name, s.location_type, s.city
)
SELECT *, DENSE_RANK() OVER (ORDER BY net_sales DESC) AS rnk
FROM store_totals
ORDER BY rnk;



