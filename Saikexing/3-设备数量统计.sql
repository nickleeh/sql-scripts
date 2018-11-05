SELECT
    sum(if(asset_status = 1, 1, 0))  AS 在用
  , sum(if(asset_status = 9, 1, 0))  AS 报废
  , sum(if(asset_status = 10, 1, 0)) AS 借调
  , sum(if(asset_status = 2, 1, 0))  AS 临时移除
  , sum(if(asset_status = 0, 1, 0))  AS 试车
  , sum(if(asset_status = 3, 1, 0))  AS 待修
  , sum(if(asset_status = 4, 1, 0))  AS 闲置
  , sum(if(asset_status = 5, 1, 0))  AS 需报废
  , count(asset_code)                AS 总数
FROM asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  , (SELECT
       location_lft
       , location_rgt
     FROM asset_location
     WHERE location_id = :location_id) AS T
WHERE asset_nature = 0
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;

-- Second part
SELECT
    asset_code          设备编码
  , asset_name          设备名称
  , asset_model         型号
  , asset_serial_number 序列号
  , asset_ff_1          责任人
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  LEFT JOIN mic_asset_status ON asset_list.asset_status = mic_asset_status.asset_status_code
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE ((:col = '在用' AND asset_status_name = :col)
       OR (:col = '报废' AND asset_status_name = :col)
       OR (:col = '借调' AND asset_status_name = :col)
       OR (:col = '试车' AND asset_status_name = :col)
       OR (:col = '总数' AND asset_status_name LIKE '%%'))
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;