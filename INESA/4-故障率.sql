SELECT DATA.yearmonth                                                 AS 月份
     , asset_code                                                     AS 机台
     , cm_time_hour                                                   AS '维修时间（小时）'
     , pm_time_hour                                                   AS '保养时间（小时）'
     , monthly_hour                                                   AS '月度总时间（小时）'
     , round((cm_time_hour / (monthly_hour - pm_time_hour) * 100), 2) AS '故障率%'
     , round(cm_each_asset / cm_total * 100, 2)                       AS '故障占比%'
FROM
  (SELECT date_format(wo_finish_time, "%Y-%m")                  AS yearmonth
        , asset_code
        , sum(IF(wo_type_type = 'CORR', wo_downtime, 0)) / 3600 AS cm_time_hour
        , sum(IF(wo_type_type = 'PREV',
                 time_to_sec(timediff(IF(wo_finish_time = '', wo_archive_time, wo_finish_time), wo_creation_time)),
                 0)) / 3600                                     AS pm_time_hour
        , sum(IF(wo_type_type = 'CORR', 1, 0))                  AS cm_each_asset
        , DAY(last_day(wo_finish_time)) * 24                    AS monthly_hour
   FROM wo_history
   WHERE wo_status = 8
   GROUP BY date_format(wo_finish_time, "%Y-%m"), asset_code) AS DATA
    INNER JOIN (SELECT date_format(wo_finish_time, "%Y-%m") AS yearmonth
                     , sum(IF(wo_type_type = 'CORR', 1, 0)) AS cm_total
                FROM wo_history
                WHERE wo_status = 8
                GROUP BY date_format(wo_finish_time, "%Y-%m")) AS cm_all ON data.yearmonth = cm_all.yearmonth