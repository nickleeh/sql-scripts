SELECT
    asset_type_code                                                                            类别编码
  , asset_type_name                                                                            类别名称
  , current_qty                                                                                当前数量
  , spare_asset_qty                                                                            实际备机数量
  , md1_ff_3                                                                                   '要求每XX台备一台'
  , @spare_assets_required := current_qty DIV md1_ff_3                                         应备数量
  , IF(spare_asset_qty < @spare_assets_required, '需要', '不需要')                                  是否需要购买备用设备
  , if(spare_asset_qty < @spare_assets_required, @spare_assets_required - spare_asset_qty, '') 还需采购
FROM
  (SELECT
     asset_type_code
     , asset_type_name
     , COUNT(asset_name)               current_qty
     , sum(IF(asset_status = 2, 1, 0)) spare_asset_qty
     , md1_ff_3

   FROM asset_list
     LEFT JOIN mic_asset_type ON asset_list.asset_type_id = mic_asset_type.asset_type_id
     LEFT JOIN mic_module_1 ON mic_asset_type.asset_type_code = mic_module_1.md1_ff_1
   WHERE asset_nature = 0
   GROUP BY asset_list.asset_type_id
  ) AS assets
ORDER BY 还需采购 DESC;

-- Part 2:
SELECT
    asset_code      设备编号
  , asset_name      设备名称
  , asset_model     型号
  , asset_type_name 类别
FROM asset_list
  LEFT JOIN mic_asset_type ON asset_list.asset_type_id = mic_asset_type.asset_type_id
WHERE
  CASE WHEN
    :row <> '' THEN :ROW = asset_type_code
  ELSE asset_type_code IS NULL END;
