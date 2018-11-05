SELECT
  DATE_FORMAT(wo_hist.wo_creation_time, '%Y-%m') AS xkey,
  (count(wo_hist.asset_ff_2) - sum(if(TIME_to_sec(wo_downtime) / 3600 <= 4, 1, 2))) /
  (count(wo_hist.asset_ff_2))                    AS '其他设备完好率'
FROM
  (SELECT
     wo_history.asset_code,
     wo_history.wo_downtime,
     asset_list.asset_ff_2,
     wo_history.wo_creation_time,
     wo_history.wo_id
   FROM wo_history
     LEFT JOIN asset_list ON wo_history.asset_code = asset_list.asset_code
   WHERE wo_history.wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
         AND wo_history.wo_type_code = 'CM'
         AND asset_list.asset_ff_2 = '其他加工设备') wo_hist
GROUP BY year(wo_hist.wo_creation_time), month(wo_hist.wo_creation_time)