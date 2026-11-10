SELECT c.customer_name, c.bill_id,sl.date_of_billing, sl.store_name, sl.no_of_items, sl.total_value
FROM customers_details c
JOIN sales_report sl ON c.bill_id = sl.bill_id
ORDER BY sl.total_value DESC;
