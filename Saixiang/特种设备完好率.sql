SELECT
  DATE_FORMAT(wo_hist.wo_creation_time, '%Y-%m') AS xkey,
  (sum(hist.asset_ff_3) - sum(TIME_to_sec(wo_downtime) / 3600)) /
  sum(hist.asset_ff_3)                              特种设备完好率
FROM
  (SELECT
     wo_history.asset_code,
     wo_history.wo_downtime,
     asset_list.asset_ff_3,
     wo_history.wo_creation_time,
     wo_history.wo_id
   FROM wo_history
     LEFT JOIN asset_list ON wo_history.asset_code = asset_list.asset_code
   WHERE wo_history.wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
         AND wo_history.wo_type_code = 'CM'
         AND asset_list.asset_ff_2 = '特种设备') wo_hist
GROUP BY year(wo_hist.wo_creation_time), month(wo_hist.wo_creation_time)