SELECT
  asset_code                   模具编码,
  asset_name                   模具名称,
  characteristic_value         图号,
  asset_type_name              模具类型,
  asset_location.location_name 模具位置
FROM asset_list
  LEFT JOIN mic_asset_class
    ON asset_list.asset_class_id = mic_asset_class.asset_class_id
  LEFT JOIN mic_asset_type ON asset_list.asset_type_id = mic_asset_type.asset_type_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN asset_characteristic ON asset_list.asset_id = asset_characteristic.asset_id
WHERE mic_asset_class.asset_class_code = 'MJ' AND asset_characteristic.characteristic_id = '2'