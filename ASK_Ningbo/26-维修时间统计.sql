SELECT
    wo_id                                                                                                工单号
  , wo_name                                                                                              工单名称
  , wo_start_time                                                                                        开始时间
  , wo_finish_time                                                                                       结束时间
  , if(timediff(wo_finish_time, wo_start_time) < 0, '00:01:00', timediff(wo_finish_time, wo_start_time)) 维修时间
FROM (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS scope,
  wo_history
  LEFT JOIN asset_location ON wo_history.location_code = asset_location.location_code
WHERE wo_failure_time BETWEEN :start_date AND :end_date
      AND asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
      AND wo_history.wo_type_type = 'CORR'

UNION ALL

SELECT
  '汇总'
  , 'N/A'
  , 'N/A'
  , 'N/A'
  , SEC_TO_TIME(sum(time_to_sec(
                        IF(timediff(wo_finish_time, wo_start_time) < 0, '00:01:00',
                           timediff(wo_finish_time, wo_start_time)))))
FROM (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = IF(:location_id = 0, 1, :location_id)) AS scope,
  wo_history
  LEFT JOIN asset_location ON wo_history.location_code = asset_location.location_code
WHERE wo_failure_time BETWEEN :start_date AND :end_date
      AND asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
      AND wo_history.wo_type_type = 'CORR';