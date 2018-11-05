SELECT
    /*报修处理情况（按车间）*/
    concat(scope.location_code, " ", scope.location_name)AS 车间
     , sum(if(mr_status < 6, 1, 0))AS                       未处理
     , sum(if(mr_status = 6, 1, 0))AS                       已处理
     , sum(if(mr_status = 9, 1, 0))AS                       已取消
     , count(mr_id)AS                                       总报修数
  FROM
    (SELECT location_code
          , location_name
          , location_lft
          , location_rgt
       FROM asset_location
       WHERE location_level = 2
    ) AS scope,
    (SELECT mr_id
          , location_lft
          , mr_request_time
          , mr_name
          , mr_status
       FROM mr_list
              INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
     UNION

     SELECT mr_id
          , location_lft
          , mr_request_time
          , mr_name
          , mr_status
       FROM mr_cancelled
              INNER JOIN asset_list ON mr_cancelled.asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
    ) AS mr_all,
    (SELECT location_lft
          , location_rgt
       FROM asset_location
       WHERE location_id = :location_id
    ) AS scope2
  WHERE mr_all.location_lft BETWEEN scope.location_lft AND scope.location_rgt
    AND mr_all.location_lft BETWEEN scope2.location_lft AND scope2.location_rgt
  GROUP BY scope.location_code