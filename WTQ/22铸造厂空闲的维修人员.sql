SELECT
  employee_code                                               工号,
  employee_name                                               姓名,
  role_name_cn                                                职务,
  employee_email                                              手机,
  if(employee_last_activity <> 0, employee_last_activity, '') 最后一次活跃时间
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_code = 'WTQ-ZZ') AS T,
  (SELECT empall.employee_id
   FROM admin_employee empall LEFT JOIN
     (SELECT DISTINCT employee_id
      FROM wo_list wlst
        JOIN wo_list_employee wle ON wlst.wo_responsible_id = wle.wo_employee_id
      WHERE wo_status < 6 AND wo_responsible_id <> 0

      UNION

      SELECT DISTINCT employee_id
      FROM wo_list_employee
      WHERE wo_id
            IN (SELECT wo_id
                FROM wo_list
                WHERE wo_status < 6)) empwo
       ON empall.employee_id = empwo.employee_id
   WHERE empwo.employee_id IS NULL) empfree
  JOIN admin_employee emp ON empfree.employee_id = emp.employee_id
  JOIN admin_employee_role aer ON emp.employee_role = aer.role_id
WHERE employee_role IN (2, 4) AND employee_location_id IN (SELECT location_id
                                                           FROM asset_location
                                                           WHERE location_lft BETWEEN T.location_lft AND T.location_rgt)
ORDER BY employee_last_activity
LIMIT 10;