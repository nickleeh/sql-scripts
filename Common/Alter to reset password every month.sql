UPDATE mic00001.admin_employee
  INNER JOIN mic_admin.mic_user ON mic_user.user_id = admin_employee.user_id
  INNER JOIN mic_admin.mic_site ON mic_admin.mic_user.site_id = mic_admin.mic_site.site_id
SET employee_need_change_password = 1
WHERE user_password_last_change_time < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      AND employee_need_change_password = 0