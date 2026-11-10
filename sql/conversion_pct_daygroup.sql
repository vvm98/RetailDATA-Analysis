SELECT CASE
WHEN day_type= 'weekday' THEN 'weekday' ELSE 'weekend' END AS day_group,
SUM(bills) AS bills,
SUM(footfall) AS footfall,
ROUND(SUM(bills)/SUM(footfall)*100,2) AS conversion_pct
FROM daily_footfall
GROUP BY day_group;

