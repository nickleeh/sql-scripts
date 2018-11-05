-- Kali
SELECT
  par1_reading.reading_time
  , SUM(par1_reading.reading_value)
  , count(wo_id) + 1
  , format(SUM(par1_reading.reading_value) / (count(wo_id) + 1), 2) AS value
FROM wo_history
  LEFT JOIN asset_list ON wo_history.asset_code = asset_list.asset_code
  INNER JOIN asset_parameter AS par1 ON par1.asset_id = asset_list.asset_id
  -- AND par1.parameter_template = 'AAA'
  RIGHT JOIN (
               SELECT
                 asset_parameter.parameter_id
                 , SUM(parameter_reading_value)                 AS reading_value
                 , DATE_FORMAT(parameter_reading_time, '%Y-%m') AS reading_time
               FROM asset_parameter_reading
                 INNER JOIN asset_parameter ON asset_parameter.parameter_id = asset_parameter_reading.parameter_id
               WHERE parameter_template = 'AAA'
                     AND DATE(parameter_reading_time) BETWEEN :start_date AND :end_date
               GROUP BY parameter_id, DATE_FORMAT(parameter_reading_time, '%Y-%m')
             ) par1_reading ON par1.parameter_id = par1_reading.parameter_id
                               AND par1_reading.reading_time BETWEEN :start_date AND :end_date
WHERE date(wo_creation_time) BETWEEN :start_date AND :end_date
      AND wo_type_code = 'CM'
      AND wo_status = 8
      AND location_code IN (
  SELECT location_code
  FROM asset_location
  WHERE location_lft >= (SELECT location_lft
                         FROM asset_location
                         WHERE location_id = :location_id)
        AND location_rgt <= (SELECT location_rgt
                             FROM asset_location
                             WHERE location_id = :location_id)
  --       OR :location_id = 0
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
-- , YEAR(par1_reading.reading_time),  MONTH(par1_reading.reading_time)
ORDER BY reading_time;