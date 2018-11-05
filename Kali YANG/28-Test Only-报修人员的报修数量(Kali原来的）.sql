SELECT requester AS 报修人, count(mr_id) AS 数量
FROM
  (/* Get all maintenance request. */
    SELECT mr_name, mr_id, mr_requester, mr_request_time
    FROM mr_list
    UNION ALL
    SELECT mr_name, mr_id, mr_requester, mr_request_time
    FROM mr_cancelled
  ) AS mr_all /* end of maintenance request. */
    RIGHT JOIN
      (/*Calendar date: this is to make sure each day is counted in.*/
        SELECT calendar_date
        FROM admin_calendar
        WHERE calendar_date BETWEEN :start_date AND :end_date
      ) AS admin_calendar
      ON date(mr_all.mr_request_time) = admin_calendar.calendar_date
    RIGHT JOIN
      (/*Get all of the requesters from selected location*/
        SELECT concat(employee_code, " ", employee_name) AS requester
        FROM
          (SELECT location_lft, location_rgt
           FROM asset_location
           WHERE location_id = IF(:location_id = 0, 1, :location_id)
          ) AS scope,
          admin_employee
            INNER JOIN asset_location
              ON admin_employee.employee_location_id = asset_location.location_id
        WHERE employee_role = 0
          AND asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
      ) AS admin_requester /* end of requester part. */
      ON admin_requester.requester = mr_all.mr_requester
GROUP BY requester
;
