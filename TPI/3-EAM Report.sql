SELECT
    @cnt := @cnt + 1                          序号
  , asset_code                                设备编码
  , asset_name                                设备名称
  , asset_alternative_code                    设备可替换编码
  , asset_ff_3                                唯一码
  , asset_ff_5                                TID
  , asset_ff_2                                入账日期
  , asset_acquisition_price                   设备价格
  , asset_status_name                         状态
  , concat(location_code, " ", location_name) 位置
  , supplier_name                             供应商
FROM
  (SELECT @cnt := 0) C,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN mic_asset_status ON asset_list.asset_status = mic_asset_status.asset_status_code
  LEFT JOIN pur_supplier ON asset_list.supplier_id = pur_supplier.supplier_id
WHERE asset_nature = 0