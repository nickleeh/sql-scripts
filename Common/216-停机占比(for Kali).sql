SELECT
    calendar.calendar_month                         AS xkey
  , wo_his.down_time / 3600                         AS 总停机时间
  , @calc_base := 20 * calendar.sumday              AS 基数
  , format(wo_his.down_time / 3600 / @calc_base, 2) AS 可利用率

FROM

  (
    SELECT
      /* 调取历史工单中的停机时间 */
      asset_id
      , date_format(wo_creation_time, '%Y-%m') AS creation_time
      , sum(wo_downtime)                       AS down_time
    FROM wo_history
    WHERE wo_creation_time BETWEEN :start_date AND :end_date
    GROUP BY date_format(wo_creation_time, '%Y-%m')
  ) wo_his

  /* 先和 calendar join */
  LEFT JOIN (
              SELECT DISTINCT
                  DATE_FORMAT(calendar_date, '%Y-%m') AS calendar_month
                , DAY(last_day(calendar_date))        AS sumday
              FROM admin_calendar
              WHERE DATE(calendar_date) BETWEEN :start_date AND :end_date
              ORDER BY calendar_date DESC
            ) AS calendar
    ON calendar.calendar_month = wo_his.creation_time
  LEFT JOIN asset_list
    ON wo_his.asset_id = asset_list.asset_id

  /* 增加一些限定条件 */
  LEFT JOIN asset_location ON asset_location.location_id = asset_list.location_id
  LEFT JOIN mic_function ON asset_list.function_id = asset_list.function_id
  LEFT JOIN mic_criticality ON mic_criticality.criticality_id = asset_list.criticality_id

GROUP BY calendar.calendar_month;