SELECT *
FROM `audit_trail_varchar`
WHERE change_table_id = 14
      AND change_field = 'sp_unit_price'
ORDER BY `change_datetime` DESC