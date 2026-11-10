-- 02_weekday_weekend.sql
-- Problem 2: How much of sales comes from weekends, and what drives the gap?
-- Holiday days (Republic Day) are grouped with Weekend.

-- A) Share of days vs share of sales (whole chain)
WITH day_totals AS (
    SELECT CASE WHEN day_type = 'Weekday' THEN 'Weekday' ELSE 'Weekend' END AS day_group,
           COUNT(DISTINCT date) AS days,
           SUM(net_sales)       AS net_sales
    FROM daily_footfall
    GROUP BY day_group
)
SELECT day_group, days,
       ROUND(days      / SUM(days)      OVER () * 100, 1) AS share_of_days,
       ROUND(net_sales / SUM(net_sales) OVER () * 100, 1) AS share_of_sales
FROM day_totals;

-- B) Footfall, conversion, ATV and sales per day, by store and day group
WITH day_totals AS (
    SELECT s.store_id, s.store_name,
           CASE WHEN f.day_type = 'Weekday' THEN 'Weekday' ELSE 'Weekend' END AS day_group,
           COUNT(DISTINCT f.date) AS days,
           SUM(f.footfall)  AS footfall,
           SUM(f.bills)     AS bills,
           SUM(f.net_sales) AS net_sales
    FROM daily_footfall f
    JOIN stores s ON f.store_id = s.store_id
    GROUP BY s.store_id, s.store_name, day_group
)
SELECT store_name, day_group, days,
       ROUND(footfall / days)                AS avg_footfall_per_day,
       ROUND(bills / footfall * 100, 2)      AS conversion_pct,
       ROUND(net_sales / bills, 2)           AS atv,
       ROUND(net_sales / days, 0)            AS sales_per_day,
       ROUND(net_sales / SUM(net_sales) OVER (PARTITION BY store_id) * 100, 1) AS share_of_store_sales
FROM day_totals
ORDER BY store_id, day_group;

-- C) Average footfall per store-day, weekday vs weekend
SELECT CASE WHEN day_type = 'Weekday' THEN 'Weekday' ELSE 'Weekend' END AS day_group,
       COUNT(*) AS store_days,
       ROUND(AVG(footfall), 1) AS avg_footfall
FROM daily_footfall
GROUP BY day_group;

-- D) Conversion, weekday vs weekend (total bills / total footfall)
SELECT CASE WHEN day_type = 'Weekday' THEN 'Weekday' ELSE 'Weekend' END AS day_group,
       SUM(bills) AS bills, SUM(footfall) AS footfall,
       ROUND(SUM(bills) / SUM(footfall) * 100, 2) AS conversion_pct
FROM daily_footfall
GROUP BY day_group;
