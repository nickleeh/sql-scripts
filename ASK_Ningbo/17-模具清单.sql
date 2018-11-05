SELECT
    sp_code                                   模具编码
  , sp_name                                   名称
  , sp_specification                          '规格（图号）'
  , concat(sp_class_code, sp_class_name)      分类
  , concat(location_code, " ", location_name) 仓库
  , sp_storage_bin                            货架
  , sp_current_quantity                       数量
  , sp_unit_price                             单价
  , sp_ff_1                                   重要性
  , sp_ff_2                                   工位描述
  , sp_ff_3                                   产品卡号
FROM sp_list
  LEFT JOIN mic_sp_category ON sp_list.sp_category_id = mic_sp_category.sp_category_id
  LEFT JOIN mic_sp_class ON sp_list.sp_class_id = mic_sp_class.sp_class_id
  LEFT JOIN asset_location ON sp_list.sp_location_id = asset_location.location_id
WHERE sp_category_code = 'MJ'
      AND CASE :location_id
          WHEN 0 THEN TRUE
          WHEN 1 THEN TRUE
          ELSE :location_id = sp_location_id END