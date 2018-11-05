USE hh7;
--
SELECT
  employee_code                编码,
  employee_name                姓名,
  role_name_cn                 用户角色,
  employee_last_activity       最后活跃时间,
  employee_phone               电话,
  employee_device_platform     手机平台,
  employee_device_manufacturer 手机厂商,
  employee_device_model        手机型号,
  employee_device_version      手机版本
FROM admin_employee
  JOIN admin_employee_role ON admin_employee.employee_role = admin_employee_role.role_id
ORDER BY employee_last_activity DESC, employee_role