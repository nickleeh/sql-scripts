SELECT scope.md1_ff_1 AS 编码
     , scope.md1_ff_2 AS 事业部
     , count(mr_id)   AS 未处理的报修
  FROM mr_list
         INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
         INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
         INNER JOIN
           (SELECT md1_ff_1
                 , md1_ff_2
                 , location_lft
                 , location_rgt
              FROM mic_module_1
                     INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
           ) AS scope ON asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
  WHERE mr_status < 6
  GROUP BY scope.md1_ff_1
  ORDER BY count(mr_id) DESC
--
SELECT mr_id           AS 报修单号
     , mr_name         AS 报修名称
     , asset_code      AS 设备编码
     , asset_name      AS 设备名称
     , mr_requester    AS 报修人
     , mr_request_time AS 报修时间
  FROM mr_list
         INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
         INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
         INNER JOIN
           (SELECT md1_ff_1
                 , md1_ff_2
                 , location_lft
                 , location_rgt
              FROM mic_module_1
                     INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
           ) AS scope ON asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
  WHERE mr_status < 6
    AND scope.md1_ff_1 = :row