SELECT scope.location_name                                                    AS '事业部'
     , sum(if(wo_finish_time <> 0 AND wo_finish_time > wo_target_time, 1, 0)) AS 延迟的工单
     , sum(
         if(responsible_id = '' OR wo_target_time = 0, 1, 0))                 AS 积压的工单
     , count(wo_id)                                                           AS 当前工单总数
FROM
  (SELECT location_code, location_name, location_lft, location_rgt
   FROM asset_location
   WHERE (:location_id > 1 AND location_id = :location_id)
      OR (:location_id = 1 AND
          location_level = 0
            AND
          location_code <> 'TDHL')
  ) AS
      scope,
  wo_list
    INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
GROUP BY scope.location_code