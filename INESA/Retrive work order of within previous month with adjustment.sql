/* Retrieve work orders of previous month.
If failure time < previous month, and recovery time < end of previous month:
    set failure time as first day 00:00 of previous month.
If failure time < end of previous month, and recovery time > end of previous month:
    set recovery time as end of previous month.
*/
SELECT
    /* Since some work orders which spans over the month, we need to prefix year_month with work order
    to make it unique.*/
    concat(date_format(LAST_day(NOW() - INTERVAL 1 MONTH), "%Y-%m"), "-", wo_id)   AS wo_adjusted_id
    /* If failure time < previous month, and recovery time < end of previous month:
set failure time as first day 00:00 of previous month. */
     , if(wo_failure_time < (LAST_day(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY),
          (LAST_day(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY), wo_failure_time)  AS wo_adjusted_failure_time
    /*If failure time < end of previous month, and recovery time > end of previous month:
    set recovery time as end of previous month. */
     , if(wo_recovery_time > (LAST_day(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY),
          (LAST_day(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY), wo_recovery_time) AS wo_adjusted_recovery_time
FROM
  (SELECT wo_id
        , wo_failure_time
        , @wo_recovery_time := wo_failure_time + INTERVAL wo_downtime SECOND AS wo_recovery_time
   FROM wo_history
   WHERE wo_status = 8
     AND (wo_failure_time BETWEEN (LAST_day(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY) /* First day of Previous month*/
              AND (LAST_day(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY) /* First day of this month*/
            OR
          @wo_recovery_time BETWEEN (LAST_day(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY) /* First day of Previous month*/
              AND (LAST_day(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY) /* First day of this month*/)
   ORDER BY wo_failure_time) AS wo_previous_month