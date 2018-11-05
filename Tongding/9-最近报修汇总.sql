SELECT concat(md1_ff_1, " ", md1_ff_2)AS 事业部
     , sum(if(mr_status < 6, 1, 0))AS    未处理
     , sum(if(mr_status = 6, 1, 0))AS    已处理
     , sum(if(mr_status = 9, 1, 0))AS    已取消
     , count(mr_id)AS                    总报修数
  FROM
    (SELECT md1_ff_1
          , md1_ff_2
          , location_lft
          , location_rgt
       FROM mic_module_1
              INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
    ) AS department,
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
    ) AS mr_all
  WHERE mr_all.location_lft BETWEEN department.location_lft AND department.location_rgt
    AND date(mr_request_time) BETWEEN :start_date AND :end_date
  GROUP BY md1_ff_1
  ORDER BY count(mr_id) DESC