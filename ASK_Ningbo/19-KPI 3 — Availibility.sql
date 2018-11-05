SELECT
    repair_data.yearmonth                                                             AS 'Year-Month'
  /* MTBF = ( Scheduled Time – Repair Time)/ (Number of intervention + 1) */
  , plant                                                                             AS 'Plant'
  , @MTBF :=
    round((schedule_data.scheduled_time_hour - repair_data.repair_time_hour) / (repair_data.number_intervention + 1),
          2)                                                                          AS MTBF
  , @MTTR := round(repair_data.repair_time_hour / repair_data.number_intervention, 2) AS MTTR
  , concat(round(@MTBF / (@MTBF + @MTTR) * 100,
                 2), "%")                                                             AS Availibility

FROM
  (SELECT
       scope.location_code                    AS plant
     , date_format(wo_creation_time, "%Y-%m") AS yearmonth
     , COUNT(wo_id)                           AS number_intervention
     , sum(wo_downtime) / 3600                AS repair_time_hour
   FROM
     wo_history
     INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
     INNER JOIN
     (SELECT
        location_code
        , location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code IN ('FAN', 'FCA')) AS scope
       ON asset_location.location_lft > scope.location_lft AND asset_location.location_rgt < scope.location_rgt
   WHERE wo_type_type = 'CORR'
   GROUP BY scope.location_code, date_format(wo_creation_time, "%Y-%m")) AS repair_data

  INNER JOIN

  (SELECT
       date_format(md2_ff_1, "%Y-%m") AS yearmonth
     , sum(md2_ff_4)                     scheduled_time_hour
   FROM mic_module_2
   GROUP BY date_format(md2_ff_1, "%Y-%m")) AS schedule_data
    ON repair_data.yearmonth = schedule_data.yearmonth
ORDER BY `Year-Month`, plant