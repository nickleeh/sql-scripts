SELECT
  asset_list.asset_code
  , asset_list.asset_name
  , asset_list.asset_serial_number
FROM asset_list
  INNER JOIN
  (SELECT asset_serial_number
   FROM asset_list
   GROUP BY asset_serial_number
   HAVING count(asset_serial_number) > 1) dup
    ON asset_list.asset_serial_number = dup.asset_serial_number
WHERE asset_nature = 0 AND asset_list.asset_serial_number <> ''
ORDER BY asset_serial_number;