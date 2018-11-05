SELECT
    year(parameter_reading_time)    年
  , quarter(parameter_reading_time) 季度
  , location_code                   位置编码
  , location_name                   位置名称
  , asset_code                      设备编码
  , asset_name                      设备名称
  , asset_model                     型号
  , sum(parameter_reading_value)    季度运行时间
FROM (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_parameter_reading
  LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
  LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      AND parameter_reading_time BETWEEN :start_date AND :end_date
GROUP BY asset_parameter.asset_id, year(parameter_reading_time), quarter(parameter_reading_time)
HAVING sum(parameter_reading_value) < 30 * 20;