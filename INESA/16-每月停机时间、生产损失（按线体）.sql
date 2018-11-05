SELECT date_format(wo_creation_time, "%Y-%m")             AS 日期
     , production_line.location_code                      AS 线体
     , round(sum(time_to_sec(wo_failure_time)) / 3600, 2) AS '故障时间（小时）'
     , round(sum(time_to_sec(wo_prod_losses)) / 3600, 2)  AS '生产损失（小时）'
FROM wo_history
       JOIN asset_location ON wo_history.location_code = asset_location.location_code
       INNER JOIN (SELECT location_code
                        , location_lft
                        , location_rgt
                   FROM asset_location
                   WHERE location_level = 1) AS production_line
         ON asset_location.location_lft BETWEEN production_line.location_lft AND production_line.location_rgt
GROUP BY date_format(wo_creation_time, "%Y-%m"), production_line.location_code;