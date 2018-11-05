SELECT
  -- 大型设备完好率 （按设备组）。请把'GRP743' 替换为大型设备的设备组编码。
  /*
    计算方法：
    按月统计，当月发生故障没有修好的算故障设备。
    大型设备完好率=（大型设备台数-故障设备台数）/ 大型设备台数 * 100%
*/
    calendar_date.year_and_month                                                                 月份
  , round((number_of_all_asset - ifnull(number_of_bad_asset, 0)) / number_of_all_asset * 100, 2) 完好率
FROM
  (SELECT COUNT(DISTINCT asset_list_element.asset_code) number_of_all_asset
   FROM asset_group
     INNER JOIN asset_list asset_list_main ON asset_group.main_asset_id = asset_list_main.asset_id
     INNER JOIN asset_list asset_list_element ON asset_group.element_asset_id = asset_list_element.asset_id
   WHERE asset_list_main.asset_code = 'GRP743') AS number_of_all_asset,

  (SELECT DISTINCT date_format(calendar_date, "%Y-%m") year_and_month
   FROM admin_calendar
   WHERE calendar_date BETWEEN '2018-05-01' AND now()) AS calendar_date

  LEFT JOIN

  (SELECT
       date_format(wo_failure_time, "%Y-%m") AS year_and_month
     , count(DISTINCT asset_code)            AS number_of_bad_asset
   FROM wo_history
   WHERE asset_code IN
         (SELECT asset_list_element.asset_code AS element_asset_code
          FROM asset_group
            INNER JOIN asset_list asset_list_main ON asset_group.main_asset_id = asset_list_main.asset_id
            INNER JOIN asset_list asset_list_element
              ON asset_group.element_asset_id = asset_list_element.asset_id
          WHERE asset_list_main.asset_code = 'GRP743')
         AND wo_finish_time > last_day(wo_failure_time)
   GROUP BY date_format(wo_failure_time, "%Y-%m")
  ) AS good_asset
    ON calendar_date.year_and_month = good_asset.year_and_month;