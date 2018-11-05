SELECT
    calendar_date               日期
  , max(`D1-02-meter_value`) AS 'D1-02當日表量'
  , max(`D1-02-daily_used`)  AS 'D1-02當日用量'
  , max(`D1-01-meter_value`) AS 'D1-01當日表量'
  , max(`D1-01-daily_used`)  AS 'D1-01當日用量'
FROM

  (SELECT calendar_date
   FROM admin_calendar) AS calendar

  LEFT JOIN

  (SELECT
       date(parameter_reading_time)                                                  parameter_reading_date
     , if(asset_code = 'D1-02', parameter_reading_cumul, 0)                       AS 'D1-02-meter_value'
     , if(asset_code = 'D1-02', parameter_reading_value * md1_ff_2 * md1_ff_3, 0) AS 'D1-02-daily_used'
     , if(asset_code = 'D1-01', parameter_reading_cumul, 0)                       AS 'D1-01-meter_value'
     , if(asset_code = 'D1-01', parameter_reading_value * md1_ff_2 * md1_ff_3, 0) AS 'D1-01-daily_used'
   FROM asset_parameter_reading
     INNER JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     INNER JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     INNER JOIN mic_module_1 ON asset_list.asset_code = mic_module_1.md1_ff_1) AS reading_data
    ON calendar.calendar_date = reading_data.parameter_reading_date
WHERE calendar_date BETWEEN :start_date AND :end_date
GROUP BY calendar.calendar_date