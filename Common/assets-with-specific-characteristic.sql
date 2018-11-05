-- list assets with a specific characteristic:
SELECT
  asset_code,
  asset_name,
  characteristic_id,
  characteristic_value
FROM asset_characteristic
  JOIN asset_list ON asset_characteristic.asset_id = asset_list.asset_id
WHERE characteristic_id = 4
--


