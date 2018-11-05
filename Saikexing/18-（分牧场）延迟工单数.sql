SELECT scope.location_code 编码, scope.location_name 名称, count(wo_id) 延迟工单数
FROM wo_list
       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
       INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       INNER JOIN (SELECT location_code, location_name, location_lft, location_rgt
                   FROM asset_location
                   WHERE location_code IN
                         ('10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '21', '22', '23', '32', '34', '3403')) AS scope
         ON asset_location.location_lft > scope.location_lft AND asset_location.location_rgt < scope.location_rgt
WHERE DATE(wo_target_time) < CURDATE() AND wo_target_time <> 0 AND wo_finish_time = 0 AND wo_status < 6
GROUP BY scope.location_code
ORDER BY count(wo_id) DESC;

-- Second part.
SELECT wo_id 工单号, wo_name 工单名称, wo_creation_time 创建日期, wo_target_time 目标日期, employee_name 负责人
FROM wo_list
       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
       INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       INNER JOIN (SELECT location_code, location_name, location_lft, location_rgt
                   FROM asset_location
                   WHERE location_code = :row) AS scope
         ON asset_location.location_lft > scope.location_lft AND asset_location.location_rgt < scope.location_rgt
       INNER JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id
WHERE DATE(wo_target_time) < CURDATE() AND wo_target_time <> 0 AND wo_finish_time = 0 AND wo_status < 6
