--
SELECT
    date(parameter_reading_time) xkey
  , sum(parameter_reading_value) '外围影响停机时间'
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_parameter_reading
  LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
  LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE parameter_name = '外围影响停机时间'
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      and parameter_reading_time BETWEEN :start_date and :end_date
GROUP BY date(parameter_reading_time);
--