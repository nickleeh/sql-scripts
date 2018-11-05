SELECT date(mr_request_time)                    AS 日期
     , concat(location_code, " ", location_name)AS 事业部
     , sum(if(mr_status < 6, 1, 0))AS              未处理
     , sum(if(mr_status = 6, 1, 0))AS              已处理
     , sum(if(mr_status = 9, 1, 0))AS              已取消
     , count(mr_id)AS                              总报修数
FROM
  (SELECT location_code, location_name, location_lft, location_rgt
   FROM asset_location
   WHERE (:location_id > 1 AND location_id = :location_id)
      OR (:location_id = 1 AND location_level = 0
            AND location_code <> 'TDHL')
  ) AS scope,
  (SELECT mr_id, location_lft, mr_request_time, mr_name, mr_status
   FROM mr_list
          INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
          INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
   UNION

   SELECT mr_id, location_lft, mr_request_time, mr_name, mr_status
   FROM mr_cancelled
          INNER JOIN asset_list ON mr_cancelled.asset_id = asset_list.asset_id
          INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
  ) AS mr_all
WHERE mr_all.location_lft BETWEEN scope.location_lft AND scope.location_rgt
  AND mr_request_time BETWEEN :start_date AND :end_date
GROUP BY date(mr_request_time), location_code