-- Get asset parameter from the first asset of the line.
SELECT
  asset_code
  , asset_list.asset_ff_2
  , line_parameter.parameter_code
FROM asset_list
  INNER JOIN asset_parameter ON asset_list.asset_parameter_id = asset_parameter.parameter_id

  LEFT JOIN

  (SELECT
     asset_ff_2
     , parameter_code
   FROM asset_list
     INNER JOIN asset_parameter ON asset_list.asset_parameter_id = asset_parameter.parameter_id
   WHERE parameter_code LIKE 'PL%' AND asset_ff_2 <> '') AS line_parameter

    ON asset_list.asset_ff_2 = line_parameter.asset_ff_2

WHERE asset_list.asset_ff_2 <> '';