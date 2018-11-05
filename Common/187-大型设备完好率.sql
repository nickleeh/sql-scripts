SELECT
  DATE_FORMAT(wo_hist.wo_creation_time, '%Y-%m') AS xkey,
  ((count(DISTINCT wo_hist.asset_ff_2) - sum(failure_hours DIV 24 + 1)) /
   count(DISTINCT wo_hist.asset_ff_2))              大型设备完好率
FROM
  (SELECT
     timestampdiff(HOUR, wo_creation_time, wo_finish_time) failure_hours,
     wo_history.asset_code,
     wo_history.wo_downtime,
     asset_list.asset_ff_2                                 asset_ff_2,
     wo_history.wo_creation_time,
     wo_history.wo_finish_time,
     wo_history.wo_id
   FROM
     wo_history
     LEFT JOIN
     asset_list ON wo_history.asset_code = asset_list.asset_code
   WHERE wo_history.wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
         AND wo_history.wo_type_code = 'CM'
         AND asset_list.asset_ff_2 = '大件工段设备'
  ) wo_hist
GROUP BY YEAR(wo_hist.wo_creation_time), MONTH(wo_hist.wo_creation_time);