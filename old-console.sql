SHOW DATABASES;

USE mysql;

SHOW TABLES;

SHOW STATUS;

-- requester
GRANT INSERT (sp_name, qty, requested_date), UPDATE (sp_name, qty, requested_date)
ON pur_requisition_details
TO 'requester', 'manager', 'supervisor', 'technician', 'engineer', 'planner', '...';

-- purchaser
GRANT INSERT (sp_name, qty, requested_date, status, supplier, purchase_date),
UPDATE (sp_name, qty, requested_date, status, supplier, purchase_date)
ON pur_requisition_details TO 'purchaser';

-- stock keeper
GRANT INSERT (sp_name, qty, requested_date, status, delivery_note, delivery_date),
UPDATE (sp_name, qty, requested_date, status, delivery_note, delivery_date)
ON pur_requisition_details TO 'stock_keeper';


SHOW VARIABLES LIKE "%version%";

-- --------------

SHOW DATABASES;

CREATE DATABASE hhdb;
USE hhdb;

DROP TABLE fac_sap;

CREATE TABLE fac_sap (
  fac_sap_id         INTEGER,
  factory_nbr        VARCHAR(10),
  sap_nbr            VARCHAR(10),
  item_review_status INTEGER,
  sap_review_status  INTEGER
);

SHOW TABLES;
SELECT *
FROM fac_sap;

INSERT INTO fac_sap (fac_sap_id, factory_nbr, sap_nbr) VALUES (1, 1201, "bn01");
INSERT INTO fac_sap (fac_sap_id, factory_nbr, sap_nbr) VALUES (2, 1201, "bn02");
INSERT INTO fac_sap (fac_sap_id, factory_nbr, sap_nbr) VALUES (3, 1202, "bn03");
INSERT INTO fac_sap (fac_sap_id, factory_nbr, sap_nbr) VALUES (4, 1203, "bn03");
INSERT INTO fac_sap (fac_sap_id, factory_nbr, sap_nbr) VALUES (5, 1201, "bn05");


ALTER TABLE fac_sap
  CHANGE COLUMN factory_nbr tmp VARCHAR(10);
ALTER TABLE fac_sap
  CHANGE COLUMN sap_nbr factory_code VARCHAR(10);
ALTER TABLE fac_sap
  CHANGE COLUMN tmp sap_code VARCHAR(10);

UPDATE fac_sap
SET item_review_status = 1
WHERE factory_code = "bn02";
UPDATE fac_sap
SET item_review_status = 1;

UPDATE fac_sap
SET factory_code = "bn03"
WHERE fac_sap_id = 3;

SELECT *
FROM fac_sap
GROUP BY sap_code
HAVING sum(item_review_status) = count(item_review_status);

UPDATE fac_sap
SET sap_review_status = 1
WHERE sum(item_review_status) = count(item_review_status) GROUP BY


SELECT
  asset_id,
  asset_code,
  asset_structure_lft,
  asset_structure_rgt
FROM asset_list
WHERE location_id = 377

UPDATE asset_list
SET asset_structure_lft = 2, asset_structure_rgt = 3
WHERE asset_id = 2313


SELECT
  asset_code,
  asset_alternative_code,
  location_name,
  asset_name
FROM asset_list a
  JOIN asset_location b ON a.location_id = b.location_id
ORDER BY b.location_id

-- Export for label printing.
SELECT
  asset_code,
  asset_alternative_code,
  asset_name
FROM asset_list
WHERE asset_nature = 0
ORDER BY location_id;

-- ------------
USE hhdb;
-- set names utf8;
SET NAMES gbk;

SHOW TABLES;
DROP TABLE ems_sp;

CREATE TABLE ems_sp (
  sp_code          VARCHAR(10),
  sp_name          VARCHAR(20),
  sp_specification VARCHAR(50)

);

SELECT *
FROM ems_sp;

DELETE FROM ems_sp;

LOAD DATA LOCAL INFILE '/Users/nicklee/Desktop/export_test_0404/ems_sp_export_0404_from_excel.csv' INTO TABLE ems_sp
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(sp_code, sp_name, sp_specification);


CREATE TABLE sap_data (
  sp_name          VARCHAR(20),
  sp_specification VARCHAR(50),
  sp_qty           NUMERIC,
  price            NUMERIC
);

SELECT *
FROM sap_data;

LOAD DATA LOCAL INFILE '/Users/nicklee/Desktop/sap_sp.csv' INTO TABLE sap_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(sp_name, sp_specification, sp_qty, price);


SELECT
  count(DISTINCT asset_code)             AS "EMS编码",
  count(DISTINCT asset_alternative_code) AS "固定资产编码",
  count(DISTINCT asset_ff_7)             AS "SAP编码"
FROM asset_list


-- ---------------------------
CREATE DATABASE import_test;

USE import_test;

CREATE TABLE ems_sp (
  sp_code          VARCHAR(10),
  sp_name          VARCHAR(20),
  sp_specification VARCHAR(50)

);

SELECT *
FROM import_test.ems_sp;

LOAD DATA LOCAL INFILE '/Users/nicklee/Desktop/export_test_0404/ems_sp_export_0404_from_excel.csv' INTO TABLE import_test.ems_sp
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(sp_code, sp_name, sp_specification);

CREATE TABLE sap_sp (
  sp_name          VARCHAR(20),
  sp_specification VARCHAR(50),
  sp_qty           NUMERIC,
  price            NUMERIC
);

SELECT *
FROM sap_sp;

ALTER TABLE sap_sp
  ADD sp_code VARCHAR(10);

SELECT count(*)
FROM sap_sp;

CREATE TABLE sap_sp_with_code AS SELECT
                                   ems_sp.sp_code,
                                   sap_sp.sp_name,
                                   sap_sp.sp_specification
                                 FROM (sap_sp
                                   LEFT JOIN ems_sp
                                     ON ems_sp.sp_name = sap_sp.sp_name AND
                                        ems_sp.sp_specification = sap_sp.sp_specification);

SELECT *
FROM sap_sp_with_code;

SELECT count(ems_sp.sp_code)
FROM ems_sp;

SHOW TABLES;
SELECT count(sp_name)
FROM sap_sp_with_code;

-- -----------------

SELECT
  "PC-DELL-017",
  substring_index(substring_index("PC-DELL-017", "-", -2), "-", 1) AS 'brand',
  concat(brand, "台式机");

-- Extract computer classification from asset_code and asset_class:
-- NB-ACER-001	LPT ACER笔记本
-- PC-DELL-082	DELL台式机
SELECT
  asset_code     '設備編碼',
  classification '設備名稱'
FROM
  (SELECT
     a.asset_code                                                              asset_code,
     @brand := substring_index(substring_index(a.asset_code, "-", -2), "-", 1) 'brand',
     @computer := CASE b.asset_class_code
                  WHEN "LPT"
                    THEN "笔记本"
                  WHEN "DKT"
                    THEN "台式机"
                  ELSE NULL END                                                'type',
     concat(@brand, @computer)                                                 'classification'
   FROM asset_list a
     JOIN mic_asset_class b ON b.asset_class_id = a.asset_class_id
   WHERE a.location_id > 203) AS T;

-- --------------------------
SELECT 'hello' ' world';

SELECT curdate();
SELECT now();

SHOW VARIABLES LIKE '%log_file%';
SHOW STATUS;

SELECT CURRENT_USER();
SELECT USER();

SELECT *
FROM ems_sp;

-- -----------------------------
SELECT
  c.type                                               AS '工单类型',
  format(c.type_wo, 0)                                 AS '完成工单数',
  format(e.total_wo, 0)                                AS '类型工单总数',
  concat(format(c.type_wo / e.total_wo * 100, 2), '%') AS '完成比例'
FROM
  (SELECT
     b.type_name  AS 'type',
     count(wo_id) AS 'type_wo'
   FROM wo_list a
     INNER JOIN MIC_TYPE b ON b.type_id = a.wo_type_id
     LEFT JOIN asset_list f ON f.asset_id = a.wo_asset_id
   WHERE date(a.wo_creation_time) = curdate() AND a.wo_status >= '6'

   GROUP BY b.type_code) AS c,
  (SELECT
     h.type_name  AS 'typee',
     count(wo_id) AS total_wo
   FROM wo_list d
     INNER JOIN MIC_TYPE h ON h.type_id = d.wo_type_id
     LEFT JOIN asset_list g ON g.asset_id = d.wo_asset_id
   WHERE date(d.wo_creation_time) = curdate()
   GROUP BY h.type_code) AS e

WHERE c.type = e.typee

-- ------------------------------
SELECT
  b.asset_code                               AS '设备编码 ',
  b.asset_name                               AS '设备名称 ',
  a.wo_id                                    AS '工单号',
  a.wo_name                                  AS '工单名称',
  a.wo_creator                               AS '创建人',
  s.mr_requester                             AS '叫修者',
  a.wo_feedback                              AS '工单反馈',
  k.change_employee_name                     AS '完单人员',
  t.employee_name                            AS '负责人',
  q.type_code                                AS '工作类型',
  concat(c.location_code, c.location_name)   AS '位置',
  a.wo_creation_time                         AS '创建时间',
  Concat(f.status_id, '.', f.status_name_cn) AS '状态',
  group_concat(g.employee_name)              AS '维修人员'
FROM wo_list a
  LEFT JOIN mic_status f ON a.wo_status = f.status_id
  INNER JOIN (asset_list b LEFT JOIN asset_location c ON c.location_id = b.location_id) ON a.wo_asset_id = b.asset_id
  LEFT JOIN admin_employee t ON t.EMPLOYEE_ID = a.wo_responsible_id
  LEFT JOIN mic_type q ON q.type_id = a.wo_type_id
  LEFT JOIN (admin_employee g RIGHT JOIN wo_list_employee d ON
                                                              g.employee_id = d.employee_id OR d.employee_id IS NULL)
    ON a.wo_id = d.wo_id
  LEFT JOIN mr_list s ON s.mr_id = a.mr_id
  LEFT JOIN audit_trail_wo_status k ON k.wo_id = a.wo_id
WHERE date(a.wo_creation_time) = CURDATE() AND q.type_name = left(:row, 1)
GROUP BY a.wo_id
ORDER BY q.type_code DESC；

-- -------------------------
CREATE DATABASE hisense_hitachi;
SHOW DATABASES;
USE hisense_hitachi;
SHOW TABLES;

-- ------------------------------
SELECT
  c.type                                               AS '工单类型',
  format(c.type_wo, 0)                                 AS '完成工单数',
  format(e.total_wo, 0)                                AS '类型工单总数',
  concat(format(c.type_wo / e.total_wo * 100, 2), '%') AS '完成比例'
FROM
  (SELECT
     b.type_name  AS 'type',
     count(wo_id) AS 'type_wo'
   FROM wo_list a
     INNER JOIN MIC_TYPE b ON b.type_id = a.wo_type_id
     LEFT JOIN asset_list f ON f.asset_id = a.wo_asset_id
   WHERE date(a.wo_creation_time) = curdate() AND a.wo_status >= '6'

   GROUP BY b.type_code) AS c,
  (SELECT
     h.type_name  AS 'typee',
     count(wo_id) AS total_wo
   FROM wo_list d
     INNER JOIN MIC_TYPE h ON h.type_id = d.wo_type_id
     LEFT JOIN asset_list g ON g.asset_id = d.wo_asset_id
   WHERE date(d.wo_creation_time) = curdate()
   GROUP BY h.type_code) AS e

WHERE c.type = e.typee;


SELECT
  b.asset_code                               AS '设备编码 ',
  b.asset_name                               AS '设备名称 ',
  a.wo_id                                    AS '工单号',
  a.wo_name                                  AS '工单名称',
  a.wo_creator                               AS '创建人',
  s.mr_requester                             AS '叫修者',
  a.wo_feedback                              AS '工单反馈',
  k.change_employee_name                     AS '完单人员',
  t.employee_name                            AS '负责人',
  q.type_code                                AS '工作类型',
  concat(c.location_code, c.location_name)   AS '位置',
  a.wo_creation_time                         AS '创建时间',
  Concat(f.status_id, '.', f.status_name_cn) AS '状态',
  group_concat(g.employee_name)              AS '维修人员'
FROM wo_list a
  LEFT JOIN mic_status f ON a.wo_status = f.status_id
  INNER JOIN (asset_list b LEFT JOIN asset_location c ON c.location_id = b.location_id) ON a.wo_asset_id = b.asset_id
  LEFT JOIN admin_employee t ON t.EMPLOYEE_ID = a.wo_responsible_id
  LEFT JOIN mic_type q ON q.type_id = a.wo_type_id
  LEFT JOIN (admin_employee g RIGHT JOIN wo_list_employee d ON
                                                              g.employee_id = d.employee_id OR d.employee_id IS NULL)
    ON a.wo_id = d.wo_id
  LEFT JOIN mr_list s ON s.mr_id = a.mr_id
  LEFT JOIN audit_trail_wo_status k ON k.wo_id = a.wo_id
WHERE date(a.wo_creation_time) = CURDATE() AND q.type_name = left(:row, 1)

GROUP BY a.wo_id
ORDER BY q.type_code DESC;

SELECT *
FROM mic_type;

SHOW DATABASES;
USE hisense_hitachi;
SHOW TABLES;
SELECT *
FROM hisense_hitachi


-- Mirley's report part 1
SELECT
  c.type                                               AS '工单类型',
  format(c.type_wo, 0)                                 AS '完成工单数',
  format(e.total_wo, 0)                                AS '类型工单总数',
  concat(format(c.type_wo / e.total_wo * 100, 2), '%') AS '完成比例'
FROM
  (SELECT
     b.type_name  AS 'type',
     count(wo_id) AS 'type_wo'
   FROM wo_list a
     INNER JOIN MIC_TYPE b ON b.type_id = a.wo_type_id
     LEFT JOIN asset_list f ON f.asset_id = a.wo_asset_id
   WHERE date(a.wo_creation_time) = curdate() AND a.wo_status >= '6'

   GROUP BY b.type_code) AS c,
  (SELECT
     h.type_name  AS 'typee',
     count(wo_id) AS total_wo
   FROM wo_list d
     INNER JOIN MIC_TYPE h ON h.type_id = d.wo_type_id
     LEFT JOIN asset_list g ON g.asset_id = d.wo_asset_id
   WHERE date(d.wo_creation_time) = curdate()
   GROUP BY h.type_code) AS e

WHERE c.type = e.typee;

-- Modify Mirley's report part 2
SELECT
  b.asset_code                               AS '设备编码 ',
  b.asset_name                               AS '设备名称 ',
  a.wo_id                                    AS '工单号',
  a.wo_name                                  AS '工单名称',
  a.wo_creator                               AS '创建人',
  s.mr_requester                             AS '叫修者',
  a.wo_feedback                              AS '工单反馈',
  k.change_employee_name                     AS '完单人员',
  t.employee_name                            AS '负责人',
  q.type_code                                AS '工作类型',
  concat(c.location_code, c.location_name)   AS '位置',
  a.wo_creation_time                         AS '创建时间',
  Concat(f.status_id, '.', f.status_name_cn) AS '状态',
  group_concat(g.employee_name)              AS '维修人员'
FROM wo_list a
  LEFT JOIN mic_status f ON a.wo_status = f.status_id
  INNER JOIN (asset_list b LEFT JOIN asset_location c ON c.location_id = b.location_id) ON a.wo_asset_id = b.asset_id
  LEFT JOIN admin_employee t ON t.EMPLOYEE_ID = a.wo_responsible_id
  LEFT JOIN mic_type q ON q.type_id = a.wo_type_id
  LEFT JOIN (admin_employee g RIGHT JOIN wo_list_employee d ON
                                                              g.employee_id = d.employee_id OR d.employee_id IS NULL)
    ON a.wo_id = d.wo_id
  LEFT JOIN mr_list s ON s.mr_id = a.mr_id
  LEFT JOIN audit_trail_wo_status k ON k.wo_id = a.wo_id
WHERE date(a.wo_creation_time) = CURDATE() AND q.type_name = left(:row, 2)

GROUP BY a.wo_id
ORDER BY q.type_code DESC;

-- ------------------------

SHOW VARIABLES LIKE '%my%';
SHOW OPEN TABLES FROM hisense_hitachi;

SHOW TABLES;
SELECT FOUND_ROWS();

SELECT count(*)
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'hisense_hitachi';

SELECT *
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'hisense_hitachi'
GROUP BY substring_index(TABLE_NAME, '_', 1);

SELECT *
FROM eng_task_group
ORDER BY task_group_id DESC;

-- -----------------------
SELECT *
FROM asset_location_responsible;
-- WHERE employee_code = 58133268

-- 其他负责人
SELECT
  asset_code,
  asset_name,
  employee_code,
  employee_name
FROM asset_list
  JOIN asset_location_responsible ON asset_list.location_id = asset_location_responsible.location_id
  JOIN admin_employee ON asset_location_responsible.employee_id = admin_employee.employee_id；


SELECT *
FROM asset_list;

-- 位置负责人：张宜川
SELECT
  asset_code,
  asset_name,
  employee_code,
  employee_name
FROM asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
  JOIN admin_employee ON asset_location.responsible_id = admin_employee.employee_id
WHERE employee_name = '张宜川';
-- ;


USE test;
CREATE TABLE sap_sp (
  sp_name          VARCHAR(20),
  sp_specification VARCHAR(30),
  sp_quantity      NUMERIC,
  sp_unit_price    FLOAT,
  sp_code          VARCHAR(10)
);

SHOW TABLES;
SELECT *
FROM sap_sp;

-- Extract 'sp_code' from EMS database (sp_list) by sp_name AND sp_specification.
UPDATE test.sap_sp, hisense_hitachi.sp_list
SET test.sap_sp.sp_code = hisense_hitachi.sp_list.sp_code
WHERE
  test.sap_sp.sp_name = hisense_hitachi.sp_list.sp_name AND
  test.sap_sp.sp_specification = hisense_hitachi.sp_list.sp_specification;
-- ;

SELECT *
FROM hisense_hitachi.sp_list;

SELECT *
FROM hisense_hitachi.sp_list
WHERE hisense_hitachi.sp_list.sp_code = 'SP00533';

--
SELECT CCSA.character_set_name
FROM information_schema.`TABLES` T,
  information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` CCSA
WHERE CCSA.collation_name = T.table_collation
      AND T.table_schema = "hisense_hitachi."
      AND T.table_name = "eng_maintenance_plan";


SELECT default_character_set_name
FROM information_schema.SCHEMATA
WHERE schema_name = "hisense_hitachi.";

SHOW VARIABLES LIKE '%character%';

SELECT *
FROM hisense_hitachi.eng_maintenance_plan;

-- Find which table a column name belongs to.
SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%man_scan%';
-- ;

USE hisense_hitachi;
SELECT
  mp_code,
  asset_code,
  mp_name,
  mp_status
FROM eng_maintenance_plan mp
  JOIN asset_list ON mp.mp_asset_id = asset_list.asset_id
WHERE mp.mp_status LIKE '1%' AND asset_list.asset_code LIKE '%-sj%' AND asset_list.asset_code NOT LIKE '%-SJ01' AND
      mp_name LIKE '%点检%';

-- 一级保养，专业错误的：(6是部门点检）
SELECT
  (@cnt := @cnt + 1) AS row_id,
  mp_code,
  mp_name,
  mp_speciality_id
FROM eng_maintenance_plan, (SELECT @cnt := 0) AS cnt
WHERE mp_name LIKE '%一级保养%' AND mp_speciality_id = 6;
-- ；

SELECT count(asset_nature) AS '资产数量'
FROM asset_list
WHERE asset_nature = 0;
-- 资产 4209

SELECT count(*) AS '备件数量'
FROM sp_list;
-- 备件 24208

SELECT count(*)
FROM eng_maintenance_plan;
-- 维护计划 1141

SELECT count(*)
FROM eng_maintenance_plan
WHERE mp_name NOT LIKE '%一级保养%';
-- 点检 1071

SELECT day(last_day('2003-02-05'));

-- 点检没有员工
SELECT
  (@cnt := @cnt + 1) AS row_id,
  mp_code,
  asset_code,
  mp_name,
  employee_id
FROM (SELECT @cnt := 0) AS cnt,
  eng_maintenance_plan mp LEFT OUTER JOIN eng_maintenance_plan_employee me ON mp.mp_id = me.mp_id
  JOIN asset_list ON mp.mp_asset_id = asset_list.asset_id
WHERE employee_id IS NULL;
-- ;

-- 没有任务的维护计划
SELECT
  (SELECT @cnt := @cnt + 1) AS row_id,
  mp_code,
  asset_code,
  mp_name,
  task_id
FROM (SELECT @cnt := 0) AS cnt, eng_maintenance_plan mp
  LEFT JOIN eng_maintenance_plan_task mt ON mp.mp_id = mt.mp_id
  JOIN asset_list al ON mp.mp_asset_id = al.asset_id
WHERE task_id IS NULL AND asset_code IS NOT NULL;
-- ；

USE mic00001;
-- 工单中员工是空的
SELECT
  wl.wo_id,
  mp_id,
  wo_name
FROM wo_list wl LEFT JOIN wo_list_employee we ON wl.wo_id = we.wo_id
WHERE mp_id <> 0 AND employee_id IS NULL AND wl.wo_start_time BETWEEN '2017-04-01 00:00:00' AND '2017-04-10 00:00:00'

UNION

-- 工单中任务是空的
SELECT
  wl.wo_id,
  mp_id,
  wo_name
FROM wo_list wl LEFT JOIN wo_list_task wt ON wl.wo_id = wt.wo_id
WHERE
  mp_id <> 0 AND task_id IS NULL AND
  wl.wo_creation_time BETWEEN '2017-04-01 00:00:00' AND '2017-04-10 00:00:00';

--
DROP TABLE hh20170410.`hh20170410-2051`;
SHOW DATABASES;
USE mic00001;

DROP DATABASE hh20170410;
SHOW DATABASES;

SELECT *
FROM mic_admin.mic_asset_class;


SELECT date_sub('2017-04-11 08:30:00', INTERVAL '01:30' HOUR_MINUTE);

SELECT date_sub('2017-04-11 08:30:00', INTERVAL '1' MONTH);

SELECT curdate();
SELECT date('2017-04-01');

SELECT employee_last_activity
FROM admin_employee;

SELECT '2017-04-10' > curdate();
SELECT DATE('2013-09-31') AS valid;

-- 设备资产统计
SELECT *
FROM
  (SELECT count(*) '设备总数'
   FROM asset_list
   WHERE asset_nature = 0) AS assets,

  (SELECT count(*) '固定资产总数'
   FROM asset_list
   WHERE asset_alternative_code IS NOT NULL AND asset_alternative_code <> '') AS factory,

  (SELECT count(DISTINCT asset_alternative_code) '不重复的固定资产'
   FROM asset_list
   WHERE asset_alternative_code IS NOT NULL AND asset_alternative_code <> '') AS distinct_factory,

  (SELECT count(DISTINCT sp_code) '备件总数'
   FROM sp_list) AS sp,

  (SELECT count(supplier_code) '供应商'
   FROM pur_supplier) AS supplier,

  (SELECT count(*) - 2 '员工数'
   FROM admin_employee) AS employee;
-- ；


SELECT
  fu                                                                         AS '位置',
  type_name                                                                  AS '工单类型',
  SUM(IF(wo_status >= 6, 1, 0))                                              AS '完成数',
  count(wo_id)                                                               AS '当日工单数',
  concat(format(SUM(IF(wo_status >= 6, 1, 0)) / count(wo_id) * 100, 2), '%') AS '完成比例'

FROM (SELECT
        a.wo_id,
        a.wo_status,
        a.wo_asset_id,
        c.location_code,
        c.location_name,
        d.type_code,
        d.type_name,
        a.wo_creation_time,
        fu

      FROM wo_list a

        INNER JOIN mic_type d ON d.type_id = a.wo_type_id
        INNER JOIN asset_list b ON a.wo_asset_id = b.asset_id
        LEFT JOIN asset_location c ON b.location_id = c.location_id
        LEFT JOIN wo_list_task wt ON a.wo_id = wt.wo_id
        LEFT JOIN (SELECT
                     location_id,
                     (SELECT CONCAT(location_code, ' ', location_name)
                      FROM asset_location t2
                      WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
                      ORDER BY t2.location_rgt - t1.location_rgt ASC
                      LIMIT 0, 1) AS fu
                   FROM asset_location t1
                   ORDER BY location_rgt - location_lft DESC) AS parent ON b.location_id = parent.location_id

      WHERE (a.wo_creation_time BETWEEN concat(:start_date, ' 01:00') AND concat(:end_date, ' 20:00')) AND
            wt.task_id IS NOT NULL AND d.type_code <> 'CM'

      UNION ALL

      SELECT
        aa.wo_id,
        aa.wo_status,
        aa.asset_id,
        aa.location_code,
        aa.location_name,
        aa.wo_type_code,
        aa.wo_type_name,
        aa.wo_creation_time,
        pl2

      FROM wo_history aa

        INNER JOIN asset_list bb ON aa.asset_id = bb.asset_id
        LEFT JOIN wo_history_task wtt ON aa.wo_id = wtt.wo_id
        LEFT JOIN (SELECT
                     location_id,
                     (SELECT CONCAT(location_code, ' ', location_name)
                      FROM asset_location t2
                      WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
                      ORDER BY t2.location_rgt - t1.location_rgt ASC
                      LIMIT 0, 1) AS pl2
                   FROM asset_location t1

                   ORDER BY location_rgt - location_lft DESC)
          AS parent ON bb.location_id = parent.location_id

      WHERE (aa.wo_creation_time BETWEEN concat(:start_date, ' 01:00') AND concat(:end_date, ' 20:00')) AND
            wtt.task_id IS NOT NULL AND aa.wo_type_code <> 'CM'

     ) AS H1

GROUP BY fu, type_code
ORDER BY fu, type_code;


SELECT
  asset_code       AS '设备编码',
  asset_name       AS '设备名称',
  wo_id            AS '工单号',
  wo_name          AS '工单名称',
  wo_creator       AS '创建者',
  mr_requester     AS '报修人',
  wo_feedback      AS '工单反馈',
  employee_name    AS '负责人',
  type_name        AS '工单类型',
  location         AS '位置',
  wo_creation_time AS '创建时间',
  1status1         AS '状态',
  T                AS '执行人',
  FT               AS '完成时间'
FROM (
       SELECT
         b.asset_code,
         b.asset_name,
         a.wo_id,
         a.wo_name,
         a.wo_creator,
         s.mr_requester,
         a.wo_feedback,
         t.employee_name,
         q.type_name,
         concat(c.location_code, c.location_name)   AS 'location',
         a.wo_creation_time,
         Concat(f.status_id, '.', f.status_name_cn) AS '1status1',
         group_concat(g.employee_name)              AS 'T',
         a.wo_finish_time                           AS 'FT',
         fu

       FROM wo_list a

         LEFT JOIN mic_status f ON a.wo_status = f.status_id
         LEFT JOIN (asset_list b LEFT JOIN asset_location c ON c.location_id = b.location_id)
           ON a.wo_asset_id = b.asset_id
         LEFT JOIN admin_employee t ON t.EMPLOYEE_ID = a.wo_responsible_id
         LEFT JOIN mic_type q ON q.type_id = a.wo_type_id
         LEFT JOIN wo_list_task wt ON a.wo_id = wt.wo_id

         LEFT JOIN (admin_employee g RIGHT JOIN wo_list_employee d ON
                                                                     g.employee_id = d.employee_id OR
                                                                     d.employee_id IS NULL) ON a.wo_id = d.wo_id
         LEFT JOIN mr_list s ON s.mr_id = a.mr_id
         LEFT JOIN (SELECT
                      location_id,
                      (SELECT CONCAT(location_code, ' ', location_name)
                       FROM asset_location t2
                       WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
                       ORDER BY t2.location_rgt - t1.location_rgt ASC
                       LIMIT 0, 1) AS fu
                    FROM asset_location t1
                    ORDER BY location_rgt - location_lft DESC) AS parent ON b.location_id = parent.location_id


       WHERE (a.wo_creation_time BETWEEN concat(:start_date, ' 01:00') AND concat(:end_date, ' 20:00')) AND
             wt.task_id IS NOT NULL AND q.type_code <> 'CM'
       GROUP BY a.wo_id

       UNION ALL

       SELECT
         aa.asset_code,
         aa.asset_name,
         aa.wo_id,
         aa.wo_name,
         aa.wo_creator,
         aa.mr_requester,
         aa.wo_feedback,
         aa.wo_responsible_name,
         aa.wo_type_name,
         concat(aa.location_code, aa.location_name),
         aa.wo_creation_time,
         Concat(ff.status_id, '.', ff.status_name_cn) AS '状态',
         group_concat(dd.employee_name)               AS 'T',

         aa.wo_finish_time,
         f1
       FROM wo_history aa

         LEFT JOIN mic_status ff ON aa.wo_status = ff.status_id
         LEFT JOIN wo_history_employee dd ON dd.wo_id = aa.wo_id
         INNER JOIN asset_list bb ON aa.asset_id = bb.asset_id
         LEFT JOIN wo_history_task wtt ON aa.wo_id = wtt.wo_id

         LEFT JOIN (SELECT
                      location_id,
                      (SELECT CONCAT(location_code, ' ', location_name)
                       FROM asset_location t2
                       WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
                       ORDER BY t2.location_rgt - t1.location_rgt ASC
                       LIMIT 0, 1) AS f1
                    FROM asset_location t1
                    ORDER BY location_rgt - location_lft DESC) AS parent ON bb.location_id = parent.location_id

       WHERE (aa.wo_creation_time BETWEEN concat(:start_date, ' 01:00') AND concat(:end_date, ' 20:00')) AND
             wtt.task_id IS NOT NULL AND aa.wo_type_code <> 'CM'

       GROUP BY aa.wo_id) AS H1

WHERE (:row = fu AND :col = '完成数' AND 1status1 >= 6) OR (:row = fu AND :col = '当日工单数');


SELECT
  count(*),
  date(a.wo_creation_time)

FROM wo_list a

  INNER JOIN mic_type d ON d.type_id = a.wo_type_id
  INNER JOIN asset_list b ON a.wo_asset_id = b.asset_id
  LEFT JOIN asset_location c ON b.location_id = c.location_id
  LEFT JOIN wo_list_task wt ON a.wo_id = wt.wo_id
  LEFT JOIN wo_list_employee we ON a.wo_id = we.wo_id
  LEFT JOIN (SELECT
               location_id,
               (SELECT CONCAT(location_code, ' ', location_name)
                FROM asset_location t2
                WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
                ORDER BY t2.location_rgt - t1.location_rgt ASC
                LIMIT 0, 1) AS fu
             FROM asset_location t1
             ORDER BY location_rgt - location_lft DESC) AS parent ON b.location_id = parent.location_id

WHERE a.wo_creation_time BETWEEN concat('2017-04-01', ' 01:00:00') AND concat('2017-04-11', ' 20:00:00')
      AND wt.task_id IS NOT NULL AND d.type_code <> 'CM' AND we.employee_id IS NOT NULL


GROUP BY a.wo_creation_time;

SELECT date_add('2017-04-01', INTERVAL 20 HOUR);

SELECT wo_creation_time
FROM wo_list;

SELECT cast('2017-04-01' AS DATETIME);
SELECT concat(:dffkdjdkfj, ' 01:00:00');
SELECT :dfddf;

SELECT TIMESTAMP(:ss, '01:00:00');
--
USE mic00001;
UPDATE wo_list wl
  JOIN
  (SELECT
     -- 工单中员工是空的
     wl.wo_id,
     mp_id,
     wo_name
   FROM wo_list wl LEFT JOIN wo_list_employee we ON wl.wo_id = we.wo_id
   WHERE mp_id <> 0 AND employee_id IS NULL

   UNION

   SELECT
     -- 工单中任务是空的
     wl.wo_id,
     mp_id,
     wo_name
   FROM wo_list wl LEFT JOIN wo_list_task wt ON wl.wo_id = wt.wo_id
   WHERE
     mp_id <> 0 AND task_id IS NULL) AS T ON wl.wo_id = T.wo_id
SET wl.wo_status = 9;

SELECT *
FROM mic00001.wo_list
WHERE mic00001.employee;
SELECT *
FROM audit_trail_wo_status;

SELECT *
FROM information_schema.columns
WHERE COLUMNS.COLUMN_NAME LIKE '%change_employee%';
SELECT *
FROM mic00001.audit_trail_wo_status;

USE hisense_hitachi;
SELECT
  -- -工单中员工是空的
  wl.wo_id,
  mp_id,
  wo_name
FROM wo_list wl LEFT JOIN wo_list_employee we ON wl.wo_id = we.wo_id
WHERE mp_id <> 0 AND employee_id IS NULL

UNION

SELECT
  -- -工单中任务是空的
  wl.wo_id,
  mp_id,
  wo_name
FROM wo_list wl LEFT JOIN wo_list_task wt ON wl.wo_id = wt.wo_id
WHERE
  mp_id <> 0 AND task_id IS NULL;

SELECT wo_status
FROM wo_list
WHERE wo_id = 292;

SELECT *
FROM mic00001.admin_employee;

SELECT
  table_name,
  column_name
FROM information_schema.COLUMNS
WHERE columns.COLUMN_NAME LIKE '%last%';

SELECT
  employee_id,
  employee_name,
  position employee_last_position_time
FROM mic00001.admin_employee;

-- 每日报修汇总
SELECT
  date(mr_failure_time),
  count(mr_id)
FROM mic00001.mr_list
GROUP BY day(mr_failure_time);
-- ;


-- 维护计划中，闲置的安检AJ
SELECT
  mp_code,
  asset_code,
  mp_name
FROM mic00001.eng_maintenance_plan mp
  JOIN mic00001.asset_list al ON mp.mp_asset_id = al.asset_id
WHERE mp_status = 0 AND asset_code LIKE '%-aj%';
-- ;

SELECT
  substring_index(location_code, '-', -1) code,
  location_name
FROM mic00001.asset_location
WHERE location_code LIKE '%-%';

SELECT count(mr_id)
FROM mic00001.mr_list;

SELECT DISTINCT mr_status
FROM mic00001.mr_list;

-- 用户活跃率
SELECT concat(round((active_user / all_users) * 100, 2), '%') '用户活跃度'
FROM
  (SELECT count(employee_code) active_user
   FROM mic00001.admin_employee
   WHERE employee_last_activity >= '2017-04-01') AS T1,
  (SELECT count(employee_code) all_users
   FROM mic00001.admin_employee) AS T2;
-- ;

-- 查冷媒检漏仪（卤检）日常点检下次推送日期
SELECT
  mp_code,
  asset_code,
  mp_name
FROM mic00001.eng_maintenance_plan mp
  JOIN mic00001.asset_list al ON mp.mp_asset_id = al.asset_id
WHERE mp_name LIKE '%冷媒%' AND mp_name LIKE '%日常%' AND mp_next_date < '2017-04-12';
-- ;

SELECT *
FROM mic00001.asset_characteristic;


SELECT asset_code
FROM asset_list al LEFT JOIN asset_characteristic ac ON al.asset_id = ac.asset_id
WHERE asset_code LIKE '%srv%'
LIMIT 100;

-- Unitech 各种电脑CPU列表
SELECT
  asset_code,
  asset_class_code,
  characteristic_value
FROM
  (SELECT
     asset_code,
     asset_class_code,
     characteristic_id,
     characteristic_value
   FROM asset_list al
     JOIN mic_asset_class ac ON al.asset_class_id = ac.asset_class_id
     RIGHT JOIN asset_characteristic acc ON al.asset_id = acc.asset_id
   WHERE asset_class_code IN ('SRV', 'DKT', 'LPT')) AS S1
WHERE asset_class_code = 'LPT' AND characteristic_id = 48 OR asset_class_code = 'DKT' AND characteristic_id = 60

UNION

SELECT
  asset_code,
  asset_class_code,
  NULL
FROM asset_list al
  JOIN mic_asset_class ac ON al.asset_class_id = ac.asset_class_id
WHERE asset_class_code = 'SRV';
-- ;
USE hisense_hitachi;

SELECT *
FROM asset_list;

-- Check database size
SELECT
  table_schema                                            "DB Name",
  Round(Sum(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB"
FROM information_schema.tables
GROUP BY table_schema;
-- ;
SELECT
  sp_code,
  sp_name
FROM sp_list
ORDER BY sp_code DESC
LIMIT 100;

SELECT User
FROM mysql.user;

SELECT *
FROM asset_list
WHERE asset_warranty_date < now();

SELECT *
FROM mic_cost_center;

SELECT *
FROM sp_list
WHERE sp_code =
      'SP00001';

SELECT *
FROM sp_receipt_details
ORDER BY receipt_id DESC;

SHOW STATUS;

-- Check who changed OA number:
SELECT *
FROM audit_trail_varchar
WHERE change_table_id = 32
      AND change_field = 'requisition_oa_number';
-- ;

SELECT DISTINCT TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME IN ('columnA', 'change_table_id')
      AND TABLE_SCHEMA = 'hisense_hitachi';

SELECT *
FROM audit_trail_text;

SELECT *
FROM sp_list;

-- 数值类任务（需要读取仪表数值的）
SELECT *
FROM eng_task
WHERE task_name REGEXP '[0-9][^,.。、]' AND task_name NOT LIKE '%1次%' AND task_name NOT LIKE '%:%';
-- ;

SELECT default_character_set_name
FROM information_schema.SCHEMATA
WHERE schema_name = "hisense_hitachi";

SHOW FULL COLUMNS FROM hisense_hitachi.eng_task;

SELECT '15:30' LIKE '%:%';

SELECT *
FROM audit_trail_varchar;

-- Find which table a column name belongs to.
SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%table_id%';
-- ;

SELECT *
FROM wo_list
WHERE wo_speciality_id = 'MT01';

SELECT *
FROM wo_history
WHERE wo_speciality_code = 'MT01';

-- display work orders in 'on-going'
SELECT DISTINCT
  wo_list.wo_id,
  wo_name,
  wo_schedule_time,
  asset_code,
  employee_name
FROM wo_list
  LEFT JOIN admin_employee ON wo_responsible_id = employee_id
  LEFT JOIN mic_speciality ON wo_speciality_id = speciality_id
  INNER JOIN asset_list ON (asset_id = wo_asset_id)
  NATURAL JOIN asset_location
  INNER JOIN (
               SELECT
                 location_lft,
                 location_rgt
               FROM admin_employee_location
                 NATURAL JOIN asset_location
               WHERE employee_id = :employee_id
               UNION ALL
               SELECT
                 location_lft,
                 location_rgt
               FROM admin_employee
                 INNER JOIN asset_location ON location_id = employee_location_id
               WHERE employee_id = :employee_id
             ) scope
WHERE wo_status < 6
      AND CURDATE() <= DATE(wo_target_time)
      AND DATE(wo_finish_time) = '0000-00-00'
      AND scope.location_lft <= asset_location.location_lft
      AND scope.location_rgt >= asset_location.location_rgt
      AND (:employee_speciality_id = 0 OR :employee_speciality_id = wo_speciality_id)
--    AND (4 = 0 OR 4 = wo_speciality_id) -- 4 is employee_speciality_id

ORDER BY wo_schedule_time ASC;
-- ;

SELECT *
FROM mic_speciality;

USE hisense_hitachi_20170418;

-- Check who changed OA number:
SELECT *
FROM audit_trail_varchar
WHERE -- change_table_id = 3
  change_field LIKE '%document%';

-- check who changed a field
SELECT *
FROM audit_trail_varchar
WHERE -- change_table_id = 3
  change_field LIKE '%oa%';
-- ;

SHOW VARIABLES LIKE '%version%';

DROP DATABASE hisense_hitachi;


SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%ff%';

SELECT
  asset_code,
  asset_ff_varchar_1,
  asset_ff_varchar_2,
  asset_ff_varchar_3
FROM asset_list
WHERE asset_code = 'N8-ZDH01'

SELECT *
FROM wo_list wl
  JOIN admin_employee ae ON wl.wo_responsible_id = ae.employee_id
WHERE ae.employee_name = '王继强' AND wo_creation_time > '2017-04-20';

-- 从"开始日期"到今天，用户活跃度
SELECT concat(round((active_user / all_users) * 100, 2), '%') '用户活跃度'
FROM
  (SELECT count(employee_code) active_user
   FROM mic00001.admin_employee
   WHERE
     employee_last_activity >= date_format(:start_date, '%Y-%m-%d 00:00:00')) AS T1,
  (SELECT count(employee_code) all_users
   FROM mic00001.admin_employee) AS T2;
-- ;


SELECT date_format('2017-04-21', '%Y-%m-%d 00:00:00');

SELECT date_add(date('2017-04-21'), INTERVAL '23:59' HOUR_MINUTE);

-- 手机型号：
SELECT
  employee_name                '姓名',
  employee_device_manufacturer '品牌',
  employee_device_model        '型号',
  employee_device_platform     '平台',
  employee_device_version      '版本'
FROM admin_employee;
-- ;

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%cost_center%';

-- 点检完成率趋势图
SELECT
  d xkey,
  #   round(f_ins / all_ins * 100, 1) '完成率'
  f_ins,
  all_ins
FROM
  (SELECT
     date(wo_creation_time) d,
     count(wo_id)           f_ins
   FROM

     (SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_list
      WHERE wo_type_id = 3

      UNION

      SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_history
      WHERE wo_type_code = 'INS' OR wo_type_code = 'PAT') AS all_wo
   WHERE wo_status >= 6 AND wo_status <= 8 AND dayofweek(wo_creation_time) <> 1
   GROUP BY DAte(wo_creation_time)) AS aa

  NATURAL JOIN

  (SELECT
     date(wo_creation_time) d,
     count(wo_id)           all_ins
   FROM
     (SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_list
      WHERE wo_type_id = 3

      UNION

      SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_history
      WHERE wo_type_code = 'INS' OR wo_type_code = 'PAT') AS all_wo2
   WHERE dayofweek(wo_creation_time) <> 1 AND wo_status <> 9
   GROUP BY
     date(wo_creation_time)) AS bb;
-- ；


-- 维修完成率
SELECT
  d                             xkey,
  -- f_cm, all_cm
  round(f_cm / all_cm * 100, 1) '完成率'
FROM
  (SELECT
     date(wo_creation_time) d,
     count(wo_id)           f_cm
   FROM

     (SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_list
      WHERE wo_type_id = 1

      UNION

      SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_history
      WHERE wo_type_code = 'CM') AS all_wo
   WHERE wo_status >= 6 AND wo_status <= 8 AND dayofweek(wo_creation_time) <> 1
   GROUP BY DAY(wo_creation_time)) AS aa

  NATURAL JOIN

  (SELECT
     date(wo_creation_time) d,
     count(wo_id)           all_cm
   FROM
     (SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_list
      WHERE wo_type_id = 1

      UNION

      SELECT
        wo_id,
        wo_status,
        wo_creation_time
      FROM wo_history
      WHERE wo_type_code = 'CM') AS all_wo2
   WHERE dayofweek(wo_creation_time) <> 1
   GROUP BY
     day(wo_creation_time)) AS bb;
-- ;


SELECT
  requisition_id,
  requisition_details_id,
  requisition_details_remarks,
  process_remarks
FROM pur_requisition_details;

SHOW STATUS;

USE hisense_hitachi_20170423;
SELECT count(*)
FROM wo_list;

-- Find which table a column name belongs to.
SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%table_id%';

SELECT *
FROM information_schema.TABLES
WHERE TABLE_NAME LIKE '%table_id%'

SELECT *
FROM audit_trail_varchar -- where change_field like '%clos%'

SELECT *
FROM sp_closing;

SHOW TABLE STATUS FROM hisense_hitachi_20170423
LIKE 'sp_closing';

SHOW CREATE TABLE sp_closing;

CREATE TABLE `sp_closing` (
  `closing_id`    INT(10) UNSIGNED     NOT NULL AUTO_INCREMENT,
  `closing_year`  SMALLINT(5) UNSIGNED NOT NULL,
  `closing_month` TINYINT(3) UNSIGNED  NOT NULL,
  `is_closed`     TINYINT(3) UNSIGNED  NOT NULL,
  PRIMARY KEY (`closing_id`),
  UNIQUE KEY `closing_year` (`closing_year`, `closing_month`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 2
  DEFAULT CHARSET = utf8
  COLLATE = utf8_unicode_ci;


USE information_schema;

SELECT DISTINCT
  TABLE_SCHEMA,
  TABLE_NAME
FROM
  TABLES
WHERE UPDATE_TIME IS NOT NULL
      AND
      UPDATE_TIME > NOW() - INTERVAL 7 DAY
      AND
      TABLE_SCHEMA <> 'information_schema';

SHOW VARIABLES LIKE "innodb_version";

SELECT UPDATE_TIME
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'hisense_hitachi_20170423'
      AND TABLE_NAME = 'sp_closing';

CHECKSUM TABLE sp_closing;

SELECT *
FROM audit_trail_text atv
  JOIN information_schema.INNODB_SYS_TABLES ist ON atv.change_table_id = ist.TABLE_ID
WHERE change_table_id = '344';


SELECT *
FROM information_schema.INNODB_SYS_TABLES
WHERE name LIKE '%sp_closing%';

SHOW VARIABLES LIKE '%log_file%';

SELECT day(now()) = dayofmonth(now());

SELECT version();

-- -------------------------------- 五亭桥 -------------------------------------------------

-- 一厂设备列表
SELECT
  @cnt := @cnt + 1 AS '序号',
  asset_code          '设备编码',
  asset_name          '设备名称'
FROM (SELECT @cnt := 0) AS cnt,
  asset_list alst
  JOIN asset_location alc ON alst.location_id = alc.location_id
WHERE asset_nature = 0 AND location_lft BETWEEN 1492 AND 1733
ORDER BY asset_code;
-- ;

# location_id	location_code	location_name	location_lft	location_rgt
# 1	WTQ	扬州五亭桥缸套有限公司	1	1734
# 2	WTQ-01	机加一厂	1492	1733
# 3	WTQ-02	机加二厂	740	1491
# 4	WTQ-03	机加三厂	238	739
# 5	WTQ-ZZ	铸造厂	28	237

-- ;

-- 工时工单统计
SELECT
  employee_name                           AS '姓名',
  SUM(TIME_TO_SEC(wo_worked_hour)) / 3600 AS '工时小时',
  count(wo_history_employee.wo_id)        AS '工单数'
FROM wo_history_employee
  INNER JOIN wo_history ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND employee_code <> "E001"
      AND wo_worked_hour > 0
      AND wo_status = 8
GROUP BY employee_name
ORDER BY 工时小时 DESC;
--
SELECT DISTINCT
  wo_history.wo_id,
  wo_name,
  wo_status
FROM wo_history_employee
  INNER JOIN wo_history
    ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND employee_name = :row AND wo_worked_hour > 0
      AND wo_status = 8
ORDER BY wo_history.wo_id DESC;
-- ;


-- MTTR
SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
  (SUM(TIME_TO_SEC(
           timediff(wo_finish_time, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time))) /
       3600) / COUNT(wo_id))             AS val
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND wo_finish_time <> '0000-00-00 00:00:00'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND location_code IN (
  SELECT location_code
  FROM asset_location
    INNER JOIN (
                 SELECT
                   location_lft,
                   location_rgt
                 FROM asset_location
                 WHERE location_id = :location_id AND :location_id <> 0
                 UNION ALL
                 SELECT
                   location_lft,
                   location_rgt
                 FROM admin_employee_location
                   NATURAL JOIN asset_location
                 WHERE employee_id = :employee_id AND :location_id = 0
                 UNION ALL
                 SELECT
                   location_lft,
                   location_rgt
                 FROM admin_employee
                   INNER JOIN asset_location ON location_id = employee_location_id
                 WHERE employee_id = :employee_id AND :location_id = 0
               ) scope
  WHERE scope.location_lft <= asset_location.location_lft
        AND scope.location_rgt >= asset_location.location_rgt
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;


SELECT
  sp_code             编号,
  sp_name             名称,
  sp_specification    规格,
  sp_current_quantity 数量,
  sp_unit             单位,
  sp_unit_price       价格,
  sp_last_update_time 最后更新时间
FROM sp_list
ORDER BY sp_name, sp_specification
LIMIT 100;


SELECT
  sp_issue.issue_Code                                                AS '出库单号',
  sp_issue.issue_time                                                AS '出库时间',
  sp_issue.issue_validator                                           AS '审批人',
  sp_issue.issue_type                                                AS '出库类型',
  MIC_FEE_TYPE.fee_TYPE_NAME                                         AS '费用去向	',
  MIC_FEE_CLASS.fee_class_NAME                                       AS '费用科目',
  sp_issue_details.sp_id                                             AS '备件编码',
  mic_cost_center.cost_center_name                                   AS '领用部门',
  concat(admin_employee.employee_code, admin_employee.employee_name) AS '领用人',
  sp_list.sp_name                                                    AS '备件名',
  sp_list.sp_specification                                           AS '规格型号',
  sp_issue_details.issue_qty                                         AS '领用数量',
  sp_issue_details.issue_sp_unit_price                               AS '领用单价',
  asset_list.asset_code                                              AS '使用设备',
  asset_list.asset_name                                              AS '设备名称',
  asset_list.asset_alternative_code                                  AS '固定资产编号',
  concat(YEAR(sp_issue.issue_time), '-', MONTH(sp_issue.issue_time)) AS '月份'
FROM sp_issue_details
  INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN (wo_list
    LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_Asset_id) ON wo_list.wo_id = sp_issue.wo_id
  INNER JOIN MIC_FEE_TYPE ON MIC_FEE_TYPE.fee_type_id = SP_ISSUE.issue_fee_type
  INNER JOIN MIC_FEE_CLASS ON MIC_FEE_CLASS.fee_class_id = SP_ISSUE.ISSUE_FEE_CLASS
  INNER JOIN mic_cost_Center ON mic_cost_center.cost_center_id = sp_issue.issue_cost_center_id
  LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id


-- 入库单格式
SELECT *
FROM sp_receipt sr
  JOIN sp_receipt_details srd ON sr.receipt_id = srd.receipt_id
LIMIT 100;
-- ;


-- 海信入库清单
SELECT
  sr.receipt_id         入库单号,
  -- EXTRACT( YEAR_MONTH FROM receipt_time)   月份,
  receipt_time          入库时间,
  receipt_delivery_note 送货单号,
  receipt_creation_time 录入时间,
  receipt_creator       入库人,
  sp_code               备件编码,
  sp_name               名称,
  sp_specification      规格,
  receipt_qty           数量,
  receipt_sp_unit_price 单价
FROM sp_receipt sr
  JOIN sp_receipt_details srd ON sr.receipt_id = srd.receipt_id
  LEFT JOIN sp_list sl ON srd.sp_id = sl.sp_id
ORDER BY receipt_time;
-- ;

SELECT
  sr.receipt_id         入库单号,
  receipt_time          入库时间,
  receipt_delivery_note 送货单号,
  receipt_creation_time 录入时间,
  receipt_creator       入库人,
  sp_code               备件编码,
  sp_name               名称,
  sp_specification      规格,
  receipt_qty           数量,
  sp_unit_price         单价
FROM sp_receipt sr
  JOIN sp_receipt_details srd ON sr.receipt_id = srd.receipt_id
  LEFT JOIN sp_list sl ON srd.sp_id = sl.sp_id
WHERE receipt_time BETWEEN :start_date AND :end_date
ORDER BY receipt_time;

-- 五亭桥一厂设备列表（二维码打印）
SELECT
  location_code '位置编码',
  asset_code    '设备编码',
  asset_name    '设备名称'
FROM
  asset_list alst
  JOIN asset_location alc ON alst.location_id = alc.location_id
WHERE asset_nature = 0 AND location_lft BETWEEN 1492 AND 1733
ORDER BY asset_id;
-- ;


SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%asset_category%';

SHOW CREATE TABLE mic_asset_category;


INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('HC', '行车');

USE hisense_hitachi_20170423;

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%wo_type_id%';

SELECT *
FROM mic_type;

SELECT
  wo_id                                                               工单号,
  location_name                                                       设备位置,
  asset_code                                                          设备编码,
  asset_name                                                          设备名称,
  TIME_FORMAT(SEC_TO_TIME(wo_finish_time - wo_start_time), '%Hh %im') 设备维修时间
FROM wo_list wl
  JOIN asset_list al ON wl.wo_asset_id = al.asset_id
  JOIN asset_location aloc ON al.location_id = aloc.location_id
WHERE wo_type_id = 1 AND wo_status IN (6, 7);


SELECT *
FROM wo_list wl
  JOIN asset_list al ON wl.wo_asset_id = al.asset_id
  JOIN;

SELECT location_name
FROM asset_list al
  JOIN asset_location aloc ON al.location_id = aloc.location_id;

SELECT *
FROM asset_location;


SELECT *
FROM wo_list;


SELECT *
FROM audit_trail_text
WHERE change_field LIKE '%wo%';


SELECT
  wo_id                                            工单号,
  location_name                                    设备位置,
  asset_code                                       设备编码,
  asset_name                                       设备名称,
  CASE WHEN wo_finish_time = ''
    THEN timediff(wo_last_update_time, wo_start_time)
  ELSE timediff(wo_finish_time, wo_start_time) END 设备维修时间
FROM wo_list wl
  JOIN asset_list al ON wl.wo_asset_id = al.asset_id
  JOIN asset_location aloc ON al.location_id = aloc.location_id
WHERE wo_type_id = 1 AND wo_status IN (6, 7);


SELECT 288 / 24


SELECT
  employee_name                           AS '姓名',
  SUM(TIME_TO_SEC(wo_worked_hour)) / 3600 AS '工时小时',
  count(wo_history_employee.wo_id)        AS '工单数'
FROM wo_history_employee
  INNER JOIN wo_history ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND employee_code <> "E001"
      AND wo_worked_hour > 0
      AND wo_status = 8
GROUP BY employee_name
ORDER BY 工时小时 DESC;

SELECT *
FROM sp_list;

-- 海西账龄分析
SELECT
  sp_name                                     名称,
  sp_specification                            规格型号,
  sp_class_name                               设备类型,
  sp_unit                                     单位,
  sp_current_quantity                         数量,
  sp_ff_2                                     加权单价,
  sp_ff_2 * sp_current_quantity               金额,
  sp_category_name                            备件分类,
  requisition_creator                         责任人,
  receipt_time                                入库时间,
  supplier_name                               供应商名称,
  @zq := datediff(curdate(), receipt_time) AS 账期,
  CASE WHEN @zq < 30
    THEN '30天以内'
  WHEN @zq >= 30 AND @zq < 90
    THEN '30~90天'
  WHEN @zq >= 90 AND @zq < 180
    THEN '90~180天'
  WHEN @zq >= 180 AND @zq < 365
    THEN '180~365天'
  ELSE '365天以上' END                           账期分类
FROM sp_list sl RIGHT JOIN
  (SELECT
     requisition_creator,
     sp_id,
     requisition_supplier_id
   FROM pur_requisition pr RIGHT JOIN pur_requisition_details prd
       ON pr.requisition_id = prd.requisition_id
   ORDER BY pr.requisition_creation_time DESC) AS PR
    ON sl.sp_id = pr.sp_id

  LEFT JOIN

  (SELECT
     sp_id,
     max(receipt_time) AS receipt_time
   FROM sp_receipt sr RIGHT JOIN sp_receipt_details srd ON sr.receipt_id = srd.receipt_id
   GROUP BY sp_id) AS rec
    ON PR.sp_id = rec.sp_id

  LEFT JOIN pur_supplier ps ON requisition_supplier_id = ps.supplier_id
  LEFT JOIN mic_sp_category msc ON sl.sp_category_id = msc.sp_category_id
  LEFT JOIN mic_sp_class spcls ON sl.sp_class_id = spcls.sp_class_id
WHERE sp_last_update_time <> '' AND sp_current_quantity <> 0;
--;

SELECT *
FROM sp_list
WHERE sp_unit_price <> 0 AND sp_unit_price <> sp_ff_2;

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%pur%';

SELECT *
FROM sp_receipt;

SELECT *
FROM pur_requisition pr RIGHT JOIN pur_requisition_details prd ON pr.requisition_id = prd.requisition_id
ORDER BY pr.requisition_creation_time DESC;

SELECT *
FROM mic_sp_category;

SELECT
  po.order_id      采购单号,
  sp_name          备件名称,
  sp_specification 备件规格,
  order_unit_price 价格
FROM pur_order po RIGHT JOIN pur_order_details pod ON po.order_id = pod.order_id
  LEFT JOIN sp_list sl ON pod.sp_id = sl.sp_id;

SELECT *
FROM sp_list;
SELECT *
FROM sp_receipt;
SELECT *
FROM sp_receipt_details;
SELECT *
FROM pur_requisition_details;

SELECT
  sp_name,
  max(receipt_time)
FROM sp_receipt sr RIGHT JOIN sp_receipt_details srd ON sr.receipt_id = srd.receipt_id
  LEFT JOIN sp_list sl ON srd.sp_id = sl.sp_id
GROUP BY sp_name;

WHERE receipt_time = ( SELECT (max(rec.receipt_time)));

SELECT t1.*
FROM lms_attendance t1
WHERE t1.time = (SELECT MAX(t2.time)
                 FROM lms_attendance t2
                 WHERE t2.user = t1.user);


SELECT max(receipt_time)
FROM sp_receipt
GROUP BY reci;

SELECT *
FROM sp_receipt;

SELECT date('2017-05-04 20:16:00');

SHOW STATUS;

-- -----------------------------------------------
# 平均故障间隔期 (MTBF)
# In order to keep computation of operating simple, we assume that the plant is always running, 24 hours per day,
# 7 days per week
# Operating time = DAY(LAST_DAY(wo_creation_time)) * 24 is the number of days in month x 24 hours per day  →
# This is has to be adjusted to the situation of the plant

SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m')                AS xkey,
  (DAY(LAST_DAY(wo_creation_time)) * 24) / COUNT(wo_id) AS val
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND location_code IN (
  SELECT location_code
  FROM asset_location
  WHERE location_lft >= (SELECT location_lft
                         FROM asset_location
                         WHERE location_id = :location_id)
        AND location_rgt <= (SELECT location_rgt
                             FROM asset_location
                             WHERE location_id = :location_id)
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;

# WHEN operating TIME IS linked WITH a parameter (parameter_id should be FIXED ) :

SELECT
  t1.datep                                                       AS xkey,
  IF(t2.nb_failures <> 0, t1.operating_time / t2.nb_failures, 0) AS MTBF
FROM (
       SELECT
         DATE_FORMAT(parameter_reading_time, '%Y-%m') AS datep,
         SUM(parameter_reading_value)                 AS Operating_time
       FROM asset_parameter_reading
       WHERE parameter_id = 55
             AND DATE(parameter_reading_time) BETWEEN :start_date AND :end_date
       GROUP BY YEAR(parameter_reading_time), MONTH(parameter_reading_time)
       ORDER BY parameter_reading_time ASC) t1
  LEFT JOIN (
              SELECT
                DATE_FORMAT(wo_creation_time, '%Y-%m') AS datepp,
                COUNT(wo_id)                           AS nb_failures
              FROM wo_history
              WHERE wo_type_type = 'CORR'
                    AND wo_status = 8
                    AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
              GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
              ORDER BY wo_creation_time ASC) t2
    ON t1.datep = t2.datepp;

# 平均修复时间 (MTTR)
# WHEN restoring TIME IS computed automatically based ON dates recorded IN WORK ORDER :

SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
  (SUM(time_to_sec(
           timediff(wo_finish_time, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time))) /
       3600) / COUNT(wo_id))             AS val
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND wo_finish_time <> '0000-00-00 00:00:00'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND location_code IN (
  SELECT location_code
  FROM asset_location
  WHERE location_lft >= (SELECT location_lft
                         FROM asset_location
                         WHERE location_id = :location_id)
        AND location_rgt <= (SELECT location_rgt
                             FROM asset_location
                             WHERE location_id = :location_id)
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;

# WHEN the MTTR IS based ON downtime recorded BY technicians AND operator IN WORK orders:

SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
  (SUM(wo_downtime) / COUNT(wo_id))      AS MTTR
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;

# 预防性保养工作完成率 (PM ratio)

SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m')                           AS xkey,
  CONCAT(100 * FORMAT(COUNT(IF(DATE(wo_target_time) >= DATE(wo_finish_time), 1,
                               IF(DATE(wo_target_time) > CURDATE() AND wo_finish_time = '0000-00-00 00:00:00', 1,
                                  NULL))) / COUNT(wo_id), 2), '%') AS val
FROM wo_history
WHERE wo_type_type = 'PREV'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND wo_status = 8
      AND location_code IN (
  SELECT location_code
  FROM asset_location
  WHERE location_lft >= (SELECT location_lft
                         FROM asset_location
                         WHERE location_id = :location_id)
        AND location_rgt <= (SELECT location_rgt
                             FROM asset_location
                             WHERE location_id = :location_id)
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC

Equipment reliability
NUMBER of equipment / NUMBER of failures

SELECT
  z.xkey,
  CONCAT(FORMAT((100 - 100 * w.nb_faulty_asset / z.nb_asset), 2), '%') AS val
FROM (
       SELECT
         xkey,
         (@s := @s + t.nb_asset) AS nb_asset
       FROM (
              SELECT
                DATE_FORMAT(asset_creation_time, '%Y-%m') AS xkey,
                count(asset_id)                           AS nb_asset
              FROM asset_list
              WHERE asset_nature = 0 OR asset_nature = 1
              GROUP BY YEAR(asset_creation_time), MONTH(asset_creation_time)
              ORDER BY YEAR(asset_creation_time), MONTH(asset_creation_time)
            ) t
         JOIN (SELECT @s := 0) r
     ) z
  LEFT JOIN (
              SELECT
                DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
                COUNT(DISTINCT asset_id)               AS nb_faulty_asset
              FROM wo_history
              WHERE wo_type_type = 'CORR'
                    AND wo_status = 8
              GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
              ORDER BY wo_creation_time ASC
            ) w ON w.xkey = z.xkey;

# Spare parts received
SELECT
  sp_code,
  sp_name,
  SUM(receipt_qty)
FROM sp_receipt
  NATURAL JOIN sp_receipt_details
  NATURAL JOIN sp_list
WHERE DATE(receipt_time) BETWEEN :start_date AND :end_date
GROUP BY sp_code
ORDER BY sp_code;

# Spare parts issued

SELECT
  DATE(a.issue_time) AS 'issue_date',
  sp_list.sp_code,
  sp_list.sp_name,
  a.sum_sp_issue,
  b.sum_sp_return
FROM sp_list
  NATURAL JOIN (
                 SELECT
                   sp_id,
                   SUM(issue_qty) AS sum_sp_issue,
                   sp_issue.issue_id,
                   issue_time
                 FROM sp_issue
                   LEFT JOIN sp_issue_details ON sp_issue_details.issue_id = sp_issue.issue_id
                 WHERE DATE(issue_time) BETWEEN :start_date AND :end_date
                 GROUP BY sp_issue_details.sp_id
               ) a
  LEFT JOIN (
              SELECT
                sp_id,
                SUM(return_qty) AS sum_sp_return,
                sp_return.issue_id
              FROM sp_return
                LEFT JOIN sp_return_details ON sp_return_details.return_id = sp_return.return_id
                JOIN sp_issue ON sp_issue.issue_id = sp_return.issue_id
              WHERE DATE(issue_time) BETWEEN :start_date AND :end_date
              GROUP BY sp_return_details.sp_id
            ) b ON b.sp_id = sp_list.sp_id;

# NUMBER of WORK orders per DAY
SELECT
  datep,
  SUM(value) AS value
FROM (
       SELECT
         DATE_FORMAT(wo_creation_time, '%y-%m-%d') AS datep,
         wo_type_code                              AS label,
         COUNT(wo_id)                              AS value
       FROM wo_history
       WHERE DATE(wo_creation_time) BETWEEN DATE(:start_date) AND DATE(:end_date)
             AND wo_status = 8
             AND location_code IN (
         SELECT location_code
         FROM asset_location
         WHERE location_lft >= (SELECT location_lft
                                FROM asset_location
                                WHERE location_id = :location_id)
               AND location_rgt <= (SELECT location_rgt
                                    FROM asset_location
                                    WHERE location_id = :location_id)
       )
       GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time), DAY(wo_creation_time)

       UNION ALL

       SELECT
         DATE_FORMAT(wo_creation_time, '%y-%m-%d') AS datep,
         type_code                                 AS label,
         COUNT(wo_id)                              AS value
       FROM wo_list
         INNER JOIN asset_list ON asset_id = wo_asset_id
         NATURAL JOIN asset_location
         INNER JOIN mic_type ON wo_type_id = type_id
       WHERE DATE(wo_creation_time) BETWEEN DATE(:start_date) AND DATE(:end_date)
             AND location_lft >= (SELECT location_lft
                                  FROM asset_location
                                  WHERE location_id = :location_id)
             AND location_rgt <= (SELECT location_rgt
                                  FROM asset_location
                                  WHERE location_id = :location_id)
       GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time), DAY(wo_creation_time)
       ORDER BY datep ASC
     ) a
GROUP BY datep
ORDER BY datep ASC;
# Worked hours per employee

SELECT
  employee_code                                          AS '员工编码',
  employee_name                                          AS '姓名',
  COUNT(employee_code)                                   AS '工单数',
  LEFT(SEC_TO_TIME(SUM(TIME_TO_SEC(wo_worked_hour))), 5) AS '工时统计'
FROM wo_history_employee
  NATURAL JOIN wo_history
WHERE DATE(wo_creation_time) BETWEEN :start_date AND :end_date
GROUP BY employee_code
ORDER BY employee_code;

-- -----------------------------

SELECT
  location_code,
  location_name,
  employee_code,
  employee_name
FROM asset_location al
  JOIN asset_location_responsible alr ON al.responsible_id = alr.location_responsible_id
  JOIN admin_employee ae ON alr.employee_id = ae.employee_id
GROUP BY location_code;

SELECT *
FROM admin_employee emp
  JOIN asset_location；

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%confir%'

SELECT
  wo_feedback,
  wo_confirmation
FROM wo_list
WHERE wo_type_id = 1;

SELECT *
FROM mic_type;

USE hisense_hitachi_20170423;
SELECT *
FROM wo_list
LIMIT 100;
TRUNCATE TABLE wo_list;

SELECT
  pr.requisition_id         申购单号,
  requisition_creator       申购人,
  sp_name                   备件名称,
  sp_specification          规格,
  requisition_qty           数量,
  requisition_creation_time 申购日期
FROM pur_requisition pr RIGHT JOIN pur_requisition_details prd ON pr.requisition_id = prd.requisition_id
  JOIN sp_list sl ON prd.sp_id = sl.sp_id
WHERE requisition_creation_time > curdate() - INTERVAL 2 MONTH
ORDER BY requisition_creation_time DESC;

SELECT *
FROM pur_requisition_details;


SELECT
  al.location_id,
  sum(if(asset_class_id = 236, 1, 0)) 笔记本,
  sum(if(asset_class_id = 237, 1, 0)) 台式机
FROM asset_list al
  INNER JOIN
  (SELECT
     location_id,
     location_code,
     location_name
   FROM asset_location aloc
   WHERE aloc.location_lft > 408 AND aloc.location_rgt < 545) mis
GROUP BY location_id
ORDER BY aloc.location_lft
--   ORDER BY location_rgt - location_lft DESC) AS parent ON asset_list.location_id = parent.location_id

SELECT *
FROM asset_location;
SELECT *
FROM asset_list;
SELECT *
FROM asset_list alst
  JOIN asset_location aloc ON alst.asset_id = aloc.location_asset_id;


SELECT
  aloc.location_id,
  location_name,
  sum(if(asset_class_id = 236, 1, 0)) 笔记本,
  sum(if(asset_class_id = 237, 1, 0)) 台式机
-- asset_id 设备ID,

--       WHERE al.asset_structure_lft > loc.location_lft AND al.asset_structure_rgt < loc.location_rgt),
#   asset_structure_lft,
#   asset_structure_rgt,
FROM asset_list al LEFT JOIN asset_location aloc ON al.location_id = aloc.location_id -- where asset_nature = 0
WHERE al.location_id IN (SELECT location_id
                         FROM
                           (SELECT
                              location_id,
                              location_lft,
                              location_rgt
                            FROM asset_location
                            WHERE location_lft > 408 AND location_rgt < 545) loc)
GROUP BY location_id;
;
-- where al.location_id = loc.location_id),

SELECT
  asset_code    '设备编号',
  location_code '设备位置',
  asset_name    '设备名称'
FROM
  asset_list alst
  JOIN asset_location alc ON alst.location_id = alc.location_id
-- WHERE asset_nature = 0 AND location_lft BETWEEN 1492 AND 1733
-- ORDER BY asset_id;

SELECT count(location_id)
FROM asset_list
WHERE asset_nature = 0;


SELECT
  fu                                  部门,
  parent.location_id,
  sum(if(asset_class_id = 236, 1, 0)) 笔记本,
  sum(if(asset_class_id = 237, 1, 0)) 台式机
FROM asset_list
  INNER JOIN
  (SELECT
     location_id,
     (SELECT CONCAT(location_code, ' ', location_name)
      FROM asset_location t2
      WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
      ORDER BY t2.location_rgt - t1.location_rgt ASC
      LIMIT 0, 1) AS fu
   FROM asset_location t1
   WHERE t1.location_id > 203
   ORDER BY location_rgt - location_lft DESC) AS parent
    ON asset_list.location_id = parent.location_id
GROUP BY fu;


SELECT
  --  fu                                  部门,
  parent.location_id,
  sum(if(asset_class_id = 236, 1, 0)) 笔记本,
  sum(if(asset_class_id = 237, 1, 0)) 台式机
FROM asset_list

  INNER JOIN
  ((SELECT
      location_id,
      (SELECT CONCAT(location_code, ' ', location_name)
       FROM asset_location t2
       WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
       ORDER BY t2.location_rgt - t1.location_rgt DESC
       LIMIT 2, 1) AS fu
    FROM asset_location t1
    WHERE t1.location_lft > 408 AND t1.location_rgt < 545) AS p1
   -- ORDER BY location_rgt - location_lft DESC

   UNION

  ( SELECT
    location_id,
  ( SELECT CONCAT(location_code, ' ', location_name)
  FROM asset_location t2
  WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
                             ORDER BY t2.location_rgt - t1.location_rgt DESC
                                   LIMIT 2, 1) AS fu
                                                  FROM asset_location t1
                                                  WHERE t1.location_lft > 408 AND t1.location_rgt < 545) AS p2)
  --   ORDER BY location_rgt - location_lft DESC) AS parent

    ON asset_list.location_id = parent.location_id

GROUP BY location_code


SELECT
  location_id,
  (SELECT CONCAT(location_code, ' ', location_name)
   FROM asset_location t2
   WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
   ORDER BY t2.location_rgt - t1.location_rgt DESC
   LIMIT 1, 1) AS fu
FROM asset_location t1
WHERE t1.location_lft > 408 AND t1.location_rgt < 545
-- ORDER BY location_rgt - location_lft DESC

UNION

SELECT
  location_id,
  (SELECT CONCAT(location_code, ' ', location_name)
   FROM asset_location t2
   WHERE t2.location_lft < t1.location_lft AND t2.location_rgt > t1.location_rgt
   ORDER BY t2.location_rgt - t1.location_rgt DESC
   LIMIT 2, 1) AS fu
FROM asset_location t1
WHERE t1.location_lft > 408 AND t1.location_rgt < 545;


SELECT
  t0.location_id,
  (SELECT concat(t1.location_id, t1.location_code, t1.location_name)
   FROM asset_location t1
   WHERE t1.location_lft < t0.location_lft AND t1.location_rgt > t0.location_id
   LIMIT 0, 1) parent
FROM asset_location t0;

SELECT
  wo_id,
  wo_finish_time - wo_creation_time,
  wo_status
FROM wo_list;

SELECT *
FROM mic_status;

-- 延迟的报修
SELECT
  mr_id                                报修单号,
  concat(location_code, location_name) 位置,
  concat(asset_code, asset_name)       设备名称,
  mr_name                              申请名称,
  mr_request_time                      报修时间,
  mr_requester                         报修人,
  timediff(now(), mr_request_time)     延迟
FROM mr_list mrlst
  JOIN asset_list alst ON mrlst.mr_asset_id = alst.asset_id
  JOIN asset_location aloc ON alst.location_id = aloc.location_id
WHERE mr_status = 0
ORDER BY '延迟' DESC;
-- ;

-- 工单完成进度
SELECT
  wo_id                                          工单号,
  wo_name                                        工单名称,
  concat(aloc.location_code, ' ', location_name) 位置,
  concat(asset_code, ' ', asset_name)            设备名称,
  status_name_cn                                 工单状态,
  CASE WHEN wo_status < 6
    THEN timediff(now(), (if((wo_start_time <> 0), wo_start_time, wo_creation_time)))
  ELSE
    timediff(wo_finish_time, wo_start_time) END  用时
FROM wo_list wlst LEFT JOIN asset_list alst ON wlst.wo_asset_id = alst.asset_id
  LEFT JOIN asset_location aloc ON alst.location_id = aloc.location_id
  LEFT JOIN mic_status ms ON wlst.wo_status = ms.status_id
ORDER BY 用时 DESC;
-- ;


SELECT *
FROM wo_list
WHERE wo_responsible_id <> 0
LIMIT 100;

SELECT *
FROM wo_list
ORDER BY wo_responsible_id DESC
LIMIT 100;

SELECT *
FROM wo_list_employee
ORDER BY wo_employee_id DESC
LIMIT 100;

-- 空闲的维修人员
SELECT @loc_rank := NULL;
SELECT
  loc_rank,
  工号,
  姓名,
  职务,
  实体位置,
  手机,
  最后一次活跃时间
FROM
  (SELECT
     工号,
     姓名,
     职务,
     实体位置,
     employee_location_id,
     手机,
     最后一次活跃时间,
     @loc_rank := IF(@cur_loc = location_id, @loc_rank + 1, 1) AS loc_rank,
     @cur_loc := location_id
   FROM
     (SELECT
        employee_code                                               工号,
        employee_name                                               姓名,
        role_name_cn                                                职务,
        location_id,
        employee_location_id,
        location_name                                               实体位置,
        employee_email                                              手机,
        IF(employee_last_activity <> 0, employee_last_activity, '') 最后一次活跃时间
      FROM (SELECT empall.employee_id
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
        LEFT JOIN asset_location aloc ON emp.employee_location_id = aloc.location_id
      WHERE employee_role IN (2, 4)
      ORDER BY location_id, 最后一次活跃时间) allfree
   ORDER BY employee_location_id)
  ranked
WHERE loc_rank <= 2;
-- ;


SELECT
  loc_rank,
  employee_id,
  employee_location_id
FROM
  (SELECT
     employee_id,
     employee_location_id,
     @loc_rank := IF(@current_loc = employee_location_id, @loc_rank + 1, 1) AS loc_rank,
     @current_loc := admin_employee.employee_location_id
   FROM admin_employee
   ORDER BY employee_location_id
  ) ranked
WHERE loc_rank <= 2;


SELECT *
FROM admin_employee
LIMIT 10;


SELECT
  table_name,
  column_name
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%role%';

EXPLAIN SELECT *
        FROM mic_cost_center
        WHERE cost_center_code = 1000130001;

SELECT *
FROM sp_issue
WHERE issue_cost_center_id = 77;

SELECT *
FROM admin_employee_role;


SELECT location_id
FROM asset_location
WHERE location_id IN (
  SELECT node.location_id
  FROM asset_location AS node,
    asset_location AS parent
  WHERE node.location_lft BETWEEN parent.location_lft AND parent.location_rgt)
GROUP BY parent;

SELECT *
FROM mic_asset_category;
SELECT *
FROM mic_asset_class;
SELECT *
FROM mic_asset_type;
SELECT *
FROM mic_asset_type_class;


SELECT *
FROM mr_cancelled;

-- 五亭桥工单完成进度20170511
SELECT
  wo_id                                          工单号,
  employee_name                                  负责人,
  wo_name                                        工单名称,
  concat(aloc.location_code, ' ', location_name) 位置,
  concat(asset_code, ' ', asset_name)            设备名称,
  status_name_cn                                 工单状态,
  CASE WHEN wo_status < 6
    THEN timediff(now(), (if((wo_start_time <> 0), wo_start_time, wo_creation_time)))
  ELSE
    timediff(wo_finish_time, wo_start_time) END  用时
FROM wo_list wlst LEFT JOIN asset_list alst ON wlst.wo_asset_id = alst.asset_id
  LEFT JOIN asset_location aloc ON alst.location_id = aloc.location_id
  LEFT JOIN mic_status ms ON wlst.wo_status = ms.status_id
  LEFT JOIN admin_employee emp ON wo_responsible_id = emp.employee_id
ORDER BY 用时 DESC;
-- ;

SELECT now() - '2017-05-10 00:00:00';

-- 五亭桥延迟的报修20170511
SELECT
  mr_id                                      报修单号,
  concat(location_code, ' ', location_name)  位置,
  concat(asset_code, ' ', asset_name)        设备名称,
  mr_name                                    申请名称,
  mr_request_time                            报修时间,
  mr_requester                               报修人,
  @delay := timediff(now(), mr_request_time) 延迟
FROM mr_list mrlst
  JOIN asset_list alst ON mrlst.mr_asset_id = alst.asset_id
  JOIN asset_location aloc ON alst.location_id = aloc.location_id
WHERE mr_status = 0
ORDER BY unix_timestamp(@delay) DESC;
-- ；
SELECT @cur_loc := NULL;


EXPLAIN
SELECT
  loc_rank,
  ranked.工号,
  ranked.实体位置,
  location_name
FROM

  (SELECT
     工号,
     实体位置,

     @loc_rank := if(@cur_loc = employee_location_id, @loc_rank + 1, 1) AS loc_rank,
     @cur_loc := employee_location_id
   FROM


     (SELECT
        employee_code                                               工号,
        employee_name                                               姓名,
        role_name_cn                                                职务,
        employee_location_id,
        location_name                                               实体位置,
        employee_email                                              手机,
        if(employee_last_activity <> 0, employee_last_activity, '') 最后一次活跃时间
      FROM (SELECT empall.employee_id
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
        LEFT JOIN asset_location aloc ON emp.employee_location_id = aloc.location_id
      WHERE employee_role IN (2, 4)) allfree
   ORDER BY employee_location_id, 最后一次活跃时间) ranked


WHERE loc_rank <= 3;


SELECT *
FROM mic_criticality;

SELECT
  asset_code,
  asset_name,
  criticality_id
FROM asset_list
WHERE criticality_id = 11;

SELECT 0 = '0';

SELECT version();

SELECT @@innodb_buffer_pool_size / 1024 / 1024;


SELECT
  mr_id                                     报修单号,
  concat(location_code, ' ', location_name) 位置,
  concat(asset_code, ' ', asset_name)       设备名称,
  mr_name                                   申请名称,
  mr_request_time                           报修时间,
  mr_requester                              报修人,
  timediff(now(), mr_request_time)          延迟
FROM mr_list mrlst
  JOIN asset_list alst ON mrlst.mr_asset_id = alst.asset_id
  JOIN asset_location aloc ON alst.location_id = aloc.location_id
WHERE mr_status = 0 AND location_lft BETWEEN 1492 AND 1733
ORDER BY 延迟 DESC;

SELECT location_id
FROM asset_location
WHERE location_lft BETWEEN 1492 AND 1733

SELECT *
FROM admin_employee;

SELECT
  employee_code                                               工号,
  employee_name                                               姓名,
  role_name_cn                                                职务,
  employee_email                                              手机,
  if(employee_last_activity <> 0, employee_last_activity, '') 最后一次活跃时间
FROM (SELECT empall.employee_id
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
                                                           WHERE location_lft BETWEEN 1492 AND 1733)
ORDER BY employee_last_activity
LIMIT 10;

-- 五亭桥停机时间统计
SELECT
  location AS Xkey,
  downtime AS '停机时间'
FROM (
       SELECT
         '一厂'                                    AS location,
         SUM(TIMESTAMPDIFF(SECOND, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time),
                           wo_finish_time) / 60) AS downtime
       FROM wo_history
       WHERE wo_archive_time BETWEEN :start_date AND :end_date
             AND location_code IN (SELECT location_code
                                   FROM asset_location
                                   WHERE location_lft >= (SELECT location_lft
                                                          FROM asset_location
                                                          WHERE location_id = 2)
                                         AND location_rgt <= (SELECT location_rgt
                                                              FROM asset_location
                                                              WHERE location_id = 2)
       )

       UNION ALL

       SELECT
         '二厂'                                    AS location,
         SUM(TIMESTAMPDIFF(SECOND, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time),
                           wo_finish_time) / 60) AS downtime
       FROM wo_history
       WHERE wo_archive_time BETWEEN :start_date AND :end_date
             AND location_code IN (SELECT location_code
                                   FROM asset_location
                                   WHERE location_lft >= (SELECT location_lft
                                                          FROM asset_location
                                                          WHERE location_id = 3)
                                         AND location_rgt <= (SELECT location_rgt
                                                              FROM asset_location
                                                              WHERE location_id = 3)
       )

       UNION ALL

       SELECT
         '三厂'                                    AS location,
         SUM(TIMESTAMPDIFF(SECOND, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time),
                           wo_finish_time) / 60) AS downtime
       FROM wo_history
       WHERE wo_archive_time BETWEEN :start_date AND :end_date
             AND location_code IN (SELECT location_code
                                   FROM asset_location
                                   WHERE location_lft >= (SELECT location_lft
                                                          FROM asset_location
                                                          WHERE location_id = 4)
                                         AND location_rgt <= (SELECT location_rgt
                                                              FROM asset_location
                                                              WHERE location_id = 4)
       )

       UNION ALL

       SELECT
         '铸造厂'                                   AS location,
         SUM(TIMESTAMPDIFF(SECOND, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time),
                           wo_finish_time) / 60) AS downtime
       FROM wo_history
       WHERE wo_archive_time BETWEEN :start_date AND :end_date
             AND location_code IN (SELECT location_code
                                   FROM asset_location
                                   WHERE location_lft >= (SELECT location_lft
                                                          FROM asset_location
                                                          WHERE location_id = 5)
                                         AND location_rgt <= (SELECT location_rgt
                                                              FROM asset_location
                                                              WHERE location_id = 5)
       )
     ) a

  JOIN (SELECT @s := 0) r
  JOIN (
         SELECT SUM(TIMESTAMPDIFF(SECOND,
                                  IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time),
                                  wo_finish_time) / 60) AS total_downtime
         FROM wo_history
         WHERE wo_archive_time BETWEEN :start_date AND :end_date
               AND location_code IN
                   (SELECT location_code
                    FROM asset_location
                    WHERE (location_lft >= (SELECT location_lft
                                            FROM asset_location
                                            WHERE location_id = 2)
                           AND location_rgt <= (SELECT location_rgt
                                                FROM asset_location
                                                WHERE location_id = 2))
                          OR

                          (location_lft >= (SELECT location_lft
                                            FROM asset_location
                                            WHERE location_id = 3)
                           AND location_rgt <= (SELECT location_rgt
                                                FROM asset_location
                                                WHERE location_id = 3))
                          OR

                          (location_lft >= (SELECT location_lft
                                            FROM asset_location
                                            WHERE location_id = 4)
                           AND location_rgt <= (SELECT location_rgt
                                                FROM asset_location
                                                WHERE
                                                  location_id = 4)
                           OR

                           (location_lft >= (SELECT location_lft
                                             FROM asset_location
                                             WHERE location_id = 5)
                            AND location_rgt <= (SELECT location_rgt
                                                 FROM asset_location
                                                 WHERE location_id = 5)))
                   )

       ) t
ORDER BY downtime DESC
LIMIT 0, 5;
-- ;

SELECT *
FROM wo_history;

-- 海信日立按格式统计设备故障维修记录
SELECT
  (@cnt := @cnt + 1) AS                                        序号,
  year(wo_creation_time)                                       年,
  month(wo_creation_time)                                      月,
  substring_index(asset_code, '-', 1)                          线体,
  asset_name                                                   设备名称,
  @start_time := wo_start_time                                 开始时间,
  @end_time := wo_finish_time                                  结束时间,
  round(time_to_sec(timediff(@end_time, @start_time)) / 60, 2) '耗时(min)',
  wo_name                                                      现象,
  wo_failure_mode_name                                         故障模式,
  wo_failure_cause_subdivision_name                            故障机制,
  wo_failure_mechanism_subdivision_name                        故障原因,
  wo_maintenance_activity_name                                 解决办法,
  wo_feedback                                                  维修反馈

FROM wo_history, (SELECT @cnt := 0) AS cnt
WHERE wo_type_code = 'CM' AND wo_status = 8 AND year(wo_creation_time) = 2017;


SELECT timediff(wo_finish_time, wo_start_time)
FROM wo_history;

USE hisense_hitachi;

-- 五亭桥一厂设备：
SELECT
  asset_code    '设备编号',
  location_code '设备位置',
  asset_name    '设备名称'
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_code = 'WTQ-01') AS T, asset_list alst
  JOIN asset_location alc ON alst.location_id = alc.location_id
WHERE asset_nature = 0 AND alc.location_lft BETWEEN T.location_lft AND T.location_rgt
ORDER BY asset_id;
-- ;

SELECT wo_confirmation
FROM wo_history

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%code%';

-- 五亭桥维修工工时、评价统计
-- (1)
SELECT
  whe.employee_name                                 AS '姓名',
  round(SUM(TIME_TO_SEC(wo_worked_hour)) / 3600, 2) AS '工时小时',
  count(whe.wo_id)                                  AS '工单数',
  SUM(wo_confirmation = 3)                          AS '满意',
  SUM(wo_confirmation = 2)                          AS '一般',
  SUM(wo_confirmation = 1)                          AS '差评'
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND whe.employee_code <> "E001"
      AND wo_status = 8
      AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
GROUP BY whe.employee_name
ORDER BY 工时小时 DESC;

-- (2)
SELECT DISTINCT
  wo_history.wo_id '工单号',
  wo_name          '工单名称',
  CASE wo_confirmation
  WHEN 3
    THEN '满意'
  WHEN 2
    THEN '一般'
  WHEN 1
    THEN '差评'
  ELSE '未评价' END   '评价',
  wo_feedback      '反馈'
FROM wo_history_employee
  INNER JOIN wo_history
    ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND employee_name = :row
      AND wo_status = 8
ORDER BY wo_history.wo_id DESC;
-- ;

SELECT *
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%fee_class%';

SELECT wo_feedback
FROM wo_history;


SELECT *
FROM asset_list
LIMIT 100;
SELECT
  fee_type_id,
  fee_type_name
FROM mic_fee_type -- , sp_issue limti 100

SELECT
  issue_code,
  issue_fee_type2,
  issue_fee_class2
FROM sp_issue;

SELECT *
FROM mic_fee_class;


SELECT
  sp_code,
  sp_name,
  #   balance_month_before,
  SUM(receipt_qty * receipt_sp_bidding_unit_price)                  AS value_received_this_month,
  SUM(consumed_qty * receipt_sp_bidding_unit_price)                 AS value_issued_this_month,
  SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
FROM sp_receipt_details
  INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
#   LEFT JOIN (
#               SELECT
#                 sp_receipt_details.sp_id,
#                 SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
#               FROM sp_receipt_details
#                 INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
#                 INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
#               WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
#                     AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
#               GROUP BY sp_receipt_details.sp_id
#
#             ) b ON sp_receipt_details.sp_id = b.sp_id
WHERE MONTH(receipt_time) = MONTH(:start_date)
      AND YEAR(receipt_time) = YEAR(:start_date);

SELECT
  sp_code,
  sp_name,
  #   balance_month_before,
  SUM(receipt_qty * receipt_sp_bidding_unit_price)                  AS value_received_this_month,
  SUM(consumed_qty * receipt_sp_bidding_unit_price)                 AS value_issued_this_month,
  SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
FROM sp_receipt_details
  INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id

# LEFT JOIN (
#   (SELECT
#      sp_receipt_details.sp_id,
#      SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
#    FROM sp_receipt_details
#      INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
#      INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
#    WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
#          AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
#    GROUP BY sp_receipt_details.sp_id
#
#   ) b -- ON sp_receipt_details.sp_id = b.sp_id
WHERE MONTH(receipt_time) = MONTH(:start_date)
      AND YEAR(receipt_time) = YEAR(:start_date);

SELECT
  sp_code,
  sp_name,
  balance_month_before,
  sum(receipt_qty * receipt_sp_bidding_unit_price)                  AS value_received_this_month,
  sum(consumed_qty * receipt_sp_bidding_unit_price)                 AS value_issued_this_month,
  sum((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
FROM sp_receipt_details
  INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
  LEFT JOIN (
              SELECT
                sp_receipt_details.sp_id,
                sum((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
              FROM sp_receipt_details
                INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
                INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
              WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
                    AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
              GROUP BY sp_receipt_details.sp_id
            ) b ON sp_receipt_details.sp_id = b.sp_id
WHERE MONTH(receipt_time) = MONTH(:start_date)
      AND YEAR(receipt_time) = YEAR(:start_date)
GROUP BY sp_receipt_details.sp_id;


SELECT
  sp_code,
  sp_name,
  balance_month_before,
  SUM(receipt_qty * receipt_sp_bidding_unit_price)                                         AS value_received_this_month,
  SUM(consumed_qty * receipt_sp_bidding_unit_price)                                        AS value_issued_this_month,
  balance_month_before + SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
FROM sp_receipt_details
  INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
  ,
  (
    SELECT
      sp_receipt_details.sp_id,
      SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
    FROM sp_receipt_details
      INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
      INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
    WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
          AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
    GROUP BY sp_receipt_details.sp_id

  ) b -- ON sp_receipt_details.sp_id = b.sp_id
WHERE MONTH(receipt_time) = MONTH(:start_date)
      AND YEAR(receipt_time) = YEAR(:start_date);


SELECT
  @balance_month_before,
  value_received_this_month,
  value_issued_this_month,
  balance_this_month
FROM
  (
    SELECT
      sp_receipt_details.sp_id,
      @balance_month_before := SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
    FROM sp_receipt_details
      INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
      INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
    WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
          AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
    GROUP BY sp_receipt_details.sp_id

  ) b, -- ON sp_receipt_details.sp_id = b.sp_id
  (SELECT
     balance_month_before,
     SUM(receipt_qty * receipt_sp_bidding_unit_price)                  AS value_received_this_month,
     SUM(consumed_qty * receipt_sp_bidding_unit_price)                 AS value_issued_this_month,
     SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
   FROM
     sp_receipt_details
     INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
     INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id

   WHERE MONTH(receipt_time) = MONTH(:start_date)
         AND YEAR(receipt_time) = YEAR(:start_date)) a;

SELECT SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
FROM sp_receipt_details
  INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
      AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
GROUP BY month(receipt_time)


SELECT
  --     balance_month_before,
  SUM(receipt_qty * receipt_sp_bidding_unit_price)                  AS value_received_this_month,
  SUM(consumed_qty * receipt_sp_bidding_unit_price)                 AS value_issued_this_month,
  SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
FROM
  sp_receipt_details
  INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id

WHERE MONTH(receipt_time) = MONTH(:start_date)
      AND YEAR(receipt_time) = YEAR(:start_date)


SELECT
  balance_month_before,
  value_received_this_month,
  value_issued_this_month,
  balance_this_month

FROM

  (SELECT
     @balance_month_before := SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_month_before
   FROM sp_receipt_details
     INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
     INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
   WHERE MONTH(receipt_time) = MONTH(DATE_SUB(:start_date, INTERVAL 1 MONTH))
         AND YEAR(receipt_time) = YEAR(DATE_SUB(:start_date, INTERVAL 1 MONTH))
   GROUP BY month(receipt_time)) pre_mon,


  (SELECT
     SUM(receipt_qty * receipt_sp_bidding_unit_price)                                          AS value_received_this_month,
     SUM(consumed_qty *
         receipt_sp_bidding_unit_price)                                                        AS value_issued_this_month,
     @balance_month_before + SUM((receipt_qty - consumed_qty) * receipt_sp_bidding_unit_price) AS balance_this_month
   FROM
     sp_receipt_details
     INNER JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
     INNER JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id

   WHERE MONTH(receipt_time) = MONTH(:start_date)
         AND YEAR(receipt_time) = YEAR(:start_date)) cur_mon;


SELECT '2017-05-13' BETWEEN :start_date AND :end_date;

SELECT *
FROM sp_receipt_details

CREATE DATABASE hisense_hitachi;

USE hisense_hitachi;

-- 五亭桥维修记录
SELECT
  wo_id                                 工单号,
  wo_name                               工单名称,
  aloc.location_code                    位置编码,
  alst.asset_code                       设备编码,
  alst.asset_name                       设备名称,
  wo_creation_time                      创建时间,
  wo_finish_time                        完成时间,
  wo_responsible_name                   负责人,
  wo_description                        故障描述,
  wo_creator                            工单创建人,
  wo_failure_mode_name                  故障模式,
  wo_failure_mechanism_subdivision_name 故障机制,
  wo_failure_cause_subdivision_name     故障原因,
  wo_maintenance_activity_name          解决办法,
  wo_feedback                           反馈
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history wohist
  JOIN asset_list alst ON wohist.asset_id = alst.asset_id
  JOIN asset_location aloc ON alst.location_id = aloc.location_id
WHERE
  aloc.location_lft BETWEEN T.location_lft AND T.location_rgt
  AND wo_creation_time BETWEEN :start_date AND :end_date
ORDER BY wo_id;
-- ;

RENAME TABLE
    woh TO wo_history;

SELECT
  wo_responsible_id,
  employee_name
FROM wo_list wolst
  JOIN admin_employee ae ON wolst.wo_responsible_id = ae.employee_id
WHERE wo_name LIKE '%签到%' AND wo_status = 6

DROP DATABASE hisense_hitachi;
CREATE DATABASE hisense_hitachi;

USE hisense_hitachi;

SELECT *
FROM sp_receipt
WHERE receipt_id = '14394';
SELECT *
FROM sp_receipt_details
WHERE receipt_id = '14394';

-- delete from sp_receipt_details -- where receipt_id = '14394';

-- 海信日立按月份入库明细（报给财务）
SELECT
  invoice_code                                                      发票号,
  sp_name                                                           名称,
  sp_specification                                                  型号,
  sr.supplier_id                                                    供应商,
  supplier_name                                                     供应商名称,
  receipt_qty                                                       数量,
  srd.receipt_sp_bidding_unit_price                                 '单价',
  receipt_qty * srd.receipt_sp_bidding_unit_price                   金额,
  date(si.invoice_date)                                             日期,
  concat(DATE_FORMAT(now(), '%y'), DATE_FORMAT(invoice_date, '%m')) 记账月份
FROM sp_receipt_details srd LEFT JOIN sp_receipt sr ON srd.receipt_id = sr.receipt_id
  LEFT JOIN sp_list splst ON srd.sp_id = splst.sp_id
  LEFT JOIN sp_invoice si ON sr.invoice_id = si.invoice_id
  LEFT JOIN pur_supplier psup ON sr.supplier_id = psup.supplier_id
WHERE receipt_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')
ORDER BY invoice_code;
-- ;


-- 筛选是否已开发票
SELECT
  sr.receipt_id                                                              入库单号,
  if(invoice_code <> '', '是', '否')                                           '发票已开？',
  invoice_code                                                               发票号,
  receipt_delivery_note                                                      送货单号,
  sp_name                                                                    名称,
  sp_specification                                                           型号,
  sr.supplier_id                                                             供应商,
  supplier_name                                                              供应商名称,
  receipt_qty                                                                数量,
  srd.receipt_sp_bidding_unit_price                                          '单价',
  receipt_qty * srd.receipt_sp_bidding_unit_price                            金额,
  date(si.invoice_creation_time)                                             日期,
  concat(DATE_FORMAT(now(), '%y'), DATE_FORMAT(invoice_creation_time, '%m')) 记账月份
FROM sp_receipt_details srd LEFT JOIN sp_receipt sr ON srd.receipt_id = sr.receipt_id
  LEFT JOIN sp_list splst ON srd.sp_id = splst.sp_id
  LEFT JOIN sp_invoice si ON sr.invoice_id = si.invoice_id
  LEFT JOIN pur_supplier psup ON sr.supplier_id = psup.supplier_id
WHERE receipt_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')
ORDER BY invoice_code, 送货单号;

SELECT *
FROM mr_cancelled;

-- 海信日立 28 有库存备件清单
SELECT
  sp_code                       备件编码,
  sp_name                       备件名,
  sp_specification              规格型号,
  sp_unit                       单位,
  sp_current_quantity           当前数量,
  sp_minimum_quantity           安全库存,
  sp_storage_bin                库位,
  receipt_sp_bidding_unit_price 招标价
FROM sp_list splst
  LEFT JOIN sp_receipt_details srd ON splst.sp_id = srd.sp_id
WHERE sp_current_quantity > 0
ORDER BY sp_name;
-- ;

SELECT *
FROM sp_receipt_details
GROUP BY sp_id;

SELECT
  sp_issue.issue_Code                                                AS '出库单号',
  sp_issue.issue_time                                                AS '出库时间',
  sp_issue_details.sp_id                                             AS '备件编码',
  sp_list.sp_name                                                    AS '备件名',
  sp_list.sp_specification                                           AS '规格型号',
  sp_issue_details.issue_qty                                         AS '领用数量',
  sp_issue_details.issue_sp_unit_price                               AS '领用单价',
  concat(sp_issue.issue_status, mic_status.status_name_cn)              '状态',
  concat(YEAR(sp_issue.issue_time), '-', MONTH(sp_issue.issue_time)) AS '月份'

FROM sp_issue_details
  INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id

WHERE sp_issue.issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59') AND issue_status = 6

ORDER BY sp_issue.issue_Code DESC;

-- 有库存备件清单（用上次招标价）
SELECT DISTINCT
  sp_code                       备件编码,
  sp_name                       备件名,
  sp_specification              规格型号,
  sp_unit                       单位,
  sp_current_quantity           当前数量,
  sp_minimum_quantity           安全库存,
  sp_storage_bin                库位,
  receipt_sp_bidding_unit_price 上次招标价
FROM sp_list splst
  LEFT JOIN
  (SELECT m1.*
   FROM
     (SELECT
        srd.receipt_id,
        sp_id,
        receipt_time,
        receipt_sp_bidding_unit_price
      FROM sp_receipt_details srd
        JOIN sp_receipt sr ON srd.receipt_id = sr.receipt_id) AS m1
     LEFT JOIN
     (SELECT
        srd.receipt_id,
        sp_id,
        receipt_time,
        receipt_sp_bidding_unit_price
      FROM sp_receipt_details srd
        JOIN sp_receipt sr ON srd.receipt_id = sr.receipt_id) AS m2
       ON m1.sp_id = m2.sp_id AND m1.receipt_time < m2.receipt_time
   WHERE m2.receipt_time IS NULL) bidding_price ON splst.sp_id = bidding_price.sp_id
WHERE sp_current_quantity > 0
ORDER BY sp_name;
-- ;

-- 最后一次招标价
SELECT m1.*
FROM
  (SELECT
     srd.receipt_id,
     sp_id,
     receipt_time,
     receipt_sp_bidding_unit_price
   FROM sp_receipt_details srd
     JOIN sp_receipt sr ON srd.receipt_id = sr.receipt_id) AS m1
  LEFT JOIN
  (SELECT
     srd.receipt_id,
     sp_id,
     receipt_time,
     receipt_sp_bidding_unit_price
   FROM sp_receipt_details srd
     JOIN sp_receipt sr ON srd.receipt_id = sr.receipt_id) AS m2
    ON m1.sp_id = m2.sp_id AND m1.receipt_time < m2.receipt_time
WHERE m2.receipt_time IS NULL;
-- ;

SELECT *
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%bidding%';


SELECT
  sp_issue.issue_Code                                                AS '出库单号',
  sp_issue.issue_time                                                AS '出库时间',
  sp_issue.issue_validator                                           AS '审批人',
  sp_issue.issue_type                                                AS '出库类型',
  MIC_FEE_TYPE.fee_TYPE_NAME                                         AS '费用去向',
  MIC_FEE_CLASS.fee_class_NAME                                       AS '费用科目',
  sp_issue_details.sp_id                                             AS '备件编码',
  mic_cost_center.cost_center_name                                   AS '领用部门',
  concat(admin_employee.employee_code, admin_employee.employee_name) AS '领用人',
  sp_list.sp_name                                                    AS '备件名',
  sp_list.sp_specification                                           AS '规格型号',
  sp_issue_details.issue_qty                                         AS '领用数量',
  sp_issue_details.issue_sp_unit_price                               AS '领用单价',
  asset_list.asset_code                                              AS '使用设备',
  asset_list.asset_name                                              AS '设备名称',
  asset_list.asset_alternative_code                                  AS '固定资产编号',
  concat(sp_issue.issue_status, mic_status.status_name_cn)              状态,
  concat(YEAR(sp_issue.issue_time), '-', MONTH(sp_issue.issue_time)) AS '月份'
FROM sp_issue_details
  INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN (wo_list
    LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_Asset_id) ON wo_list.wo_id = sp_issue.wo_id
  INNER JOIN MIC_FEE_TYPE ON MIC_FEE_TYPE.fee_type_id = SP_ISSUE_details.issue_fee_type
  INNER JOIN MIC_FEE_CLASS ON MIC_FEE_CLASS.fee_class_id = SP_ISSUE_details.ISSUE_FEE_CLASS
  INNER JOIN mic_cost_Center ON mic_cost_center.cost_center_id = sp_issue.issue_cost_center_id
  INNER JOIN mic_status ON mic_Status.status_id = sp_issue.issue_status
  LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id
WHERE sp_issue.issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')
ORDER BY sp_issue.issue_Code DESC;

-- 海信日立实际出库（有效-退还）
SELECT
  -- part 1: valid spare part issues
  issue_code                      出库单号,
  issue_time                      时间,
  sp_id                           备件号,
  issue_qty                       数量,
  sid.issue_sp_unit_price         价格,
  issue_qty * issue_sp_unit_price 金额
FROM sp_issue_details sid LEFT JOIN sp_issue si ON sid.issue_id = si.issue_code
WHERE issue_status = 6 AND issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')

UNION

SELECT
  -- part 2: spare parts returned (with quantity in negative number)
  ret.issue_id                          出库单号,
  return_time                           时间,
  retd.sp_id                            备件号,
  return_qty * -1                       数量,
  issue_sp_unit_price                   价格,
  return_qty * -1 * issue_sp_unit_price 金额
FROM sp_return_details retd
  JOIN sp_return ret ON retd.return_id = ret.return_id
  JOIN sp_issue_details sid ON retd.sp_id = sid.sp_id
WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59');
-- ;

-- Pierre's logic on calculating consumed spare parts. (wrong).
SELECT
  sp_issue.issue_id,
  issue_time,
  sp_code,
  sp_name,
  sp_specification,
  issue_sp_unit_price,
  issue_qty,
  sp_unit,
  employee_code,
  employee_name,
  cost_center_code,
  cost_center_name
FROM sp_issue
  INNER JOIN sp_issue_details ON sp_issue_details.issue_id = sp_issue.issue_id
  INNER JOIN sp_list ON sp_issue_details.sp_id = sp_list.sp_id
  LEFT JOIN mic_sp_category ON mic_sp_category.sp_category_id = sp_list.sp_category_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id
  LEFT JOIN mic_cost_center ON sp_issue.issue_cost_center_id = mic_cost_center.cost_center_id
WHERE MONTH(issue_time) = MONTH(:date)
      AND YEAR(issue_time) = YEAR(:date));

-- ;

SELECT *
FROM sp_receipt_details
LIMIT 100;

-- Get return for exampe for Pierre.
SELECT
  ret.return_id,
  ret.issue_id,
  si.issue_time,
  retd.sp_id,
  return_qty * -1,
  issue_sp_unit_price
FROM sp_return_details retd
  JOIN sp_return ret ON retd.return_id = ret.return_id
  JOIN sp_issue_details sid ON retd.sp_id = sid.sp_id
  JOIN sp_issue si ON sid.issue_id = si.issue_id
WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')


SELECT
  出库单号,
  时间,
  备件号,
  sp_name          备件名称,
  sp_specification 备件规格,
  数量,
  价格,
  金额
FROM
  (SELECT
     -- part 1: valid spare part issues
     issue_code                      出库单号,
     issue_time                      时间,
     sp_id                           备件号,
     issue_qty                       数量,
     sid.issue_sp_unit_price         价格,
     issue_qty * issue_sp_unit_price 金额
   FROM sp_issue_details sid LEFT JOIN sp_issue si ON sid.issue_id = si.issue_code
   WHERE issue_status = 6 AND issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')

   UNION

   SELECT
     -- part 2: spare parts returned (with quantity in negative number)
     ret.issue_id                          出库单号,
     return_time                           时间,
     retd.sp_id                            备件号,
     return_qty * -1                       数量,
     issue_sp_unit_price                   价格,
     return_qty * -1 * issue_sp_unit_price 金额
   FROM sp_return_details retd
     JOIN sp_return ret ON retd.return_id = ret.return_id
     JOIN sp_issue_details sid ON retd.sp_id = sid.sp_id
   WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')) issued
  JOIN sp_list ON issued.备件号 = sp_list.sp_id;


TRUNCATE TABLE sp_return_details;
TRUNCATE TABLE sp_return;

SHOW CREATE TABLE sp_return_details;
SHOW CREATE TABLE sp_return;

SELECT *
FROM sp_issue_details sid LEFT JOIN mic_fee_class ON sid.issue_fee_class = mic_fee_class.fee_class_id
WHERE fee_class_id <> 0

SELECT *
FROM mic_fee_class;
SELECT *
FROM sp_issue_details;


SELECT 2453810 - 2453794;


SELECT
  出库单号,
  时间,
  备件号,
  sp_name          备件名称,
  sp_specification 备件规格,
  数量,
  价格,
  金额,
  issue_cost_center_id
FROM
  (SELECT
     -- part 1: valid spare part issues
     issue_code                      出库单号,
     issue_time                      时间,
     sp_id                           备件号,
     issue_qty                       数量,
     sid.issue_sp_unit_price         价格,
     issue_qty * issue_sp_unit_price 金额,
     cost_center_name
   FROM sp_issue_details sid LEFT JOIN sp_issue si ON sid.issue_id = si.issue_code
     LEFT JOIN mic_cost_center mcc ON si.issue_cost_center_id = mcc.cost_center_id
   WHERE issue_status = 6 AND issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')

   UNION

   SELECT
     -- part 2: spare parts returned (with quantity in negative number)
     ret.issue_id                          出库单号,
     return_time                           时间,
     retd.sp_id                            备件号,
     return_qty * -1                       数量,
     issue_sp_unit_price                   价格,
     return_qty * -1 * issue_sp_unit_price 金额,
     NULL
   FROM sp_return_details retd
     JOIN sp_return ret ON retd.return_id = ret.return_id
     JOIN sp_issue_details sid ON retd.sp_id = sid.sp_id
   WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')) issued
  JOIN sp_list ON issued.备件号 = sp_list.sp_id
ORDER BY 时间;

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%issue_%';

-- 海信日立 出库明细（结账用）备份 20170605 19:12
SELECT
  出库单号,
  时间,
  备件号,
  sp_name          备件名称,
  sp_specification 备件规格,
  数量,
  价格,
  金额,
  审批人,
  成本中心,
  出库类型,
  费用去向,
  设备编码,
  设备名称,
  固定资产编号,
  领用人
FROM
  (SELECT
     -- part 1: valid spare part issues
     issue_code                                                            出库单号,
     issue_time                                                            时间,
     sp_id                                                                 备件号,
     issue_qty                                                             数量,
     sid.issue_sp_unit_price                                               价格,
     issue_qty * issue_sp_unit_price                                       金额,
     issue_validator                                                       审批人,
     si.issue_type                                                      AS '出库类型',
     MIC_FEE_TYPE.fee_TYPE_NAME                                         AS '费用去向',
     cost_center_name                                                      成本中心,
     asset_list.asset_code                                              AS 设备编码,
     asset_list.asset_name                                              AS 设备名称,
     asset_list.asset_alternative_code                                  AS 固定资产编号,
     concat(admin_employee.employee_code, admin_employee.employee_name) AS 领用人
   FROM sp_issue_details sid LEFT JOIN sp_issue si ON sid.issue_id = si.issue_code
     LEFT JOIN mic_cost_center mcc ON si.issue_cost_center_id = mcc.cost_center_id
     LEFT JOIN (wo_list
       LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_Asset_id) ON wo_list.wo_id = si.wo_id
     LEFT JOIN admin_employee ON admin_employee.employee_id = si.employee_id
     LEFT JOIN MIC_FEE_TYPE ON MIC_FEE_TYPE.fee_type_id = sid.issue_fee_type


   WHERE issue_status = 6 AND issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')

   UNION

   SELECT
     -- part 2: spare parts returned (with quantity in negative number)
     ret.issue_id                          出库单号,
     return_time                           时间,
     retd.sp_id                            备件号,
     return_qty * -1                       数量,
     issue_sp_unit_price                   价格,
     return_qty * -1 * issue_sp_unit_price 金额,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL
   FROM sp_return_details retd
     JOIN sp_return ret ON retd.return_id = ret.return_id
     JOIN sp_issue_details sid ON retd.sp_id = sid.sp_id
   WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')) issued
  JOIN sp_list ON issued.备件号 = sp_list.sp_id
ORDER BY 时间;
-- ;


SHOW CREATE TABLE mic_fee_class;
SHOW CREATE TABLE mic_fee_type

SELECT 2540475.5700 - 8807.7050
SELECT *
FROM sp_issue_details;

SELECT *
FROM sp_issue_details;
SELECT *
FROM sp_return_details;

-- 海信日立 出库明细 20170606 Pierre : sp_return_details.line_issue_details_id
SELECT
  出库单号,
  时间,
  备件号,
  sp_name          备件名称,
  sp_specification 备件规格,
  数量,
  价格,
  金额,
  审批人,
  成本中心,
  出库类型,
  费用去向,
  设备编码,
  设备名称,
  固定资产编号,
  领用人
FROM
  (SELECT
     -- part 1: valid spare part issues
     issue_code                                                         出库单号,
     issue_time                                                         时间,
     sp_id                                                              备件号,
     issue_qty                                                          数量,
     sid.issue_sp_unit_price                                            价格,
     issue_qty * issue_sp_unit_price                                    金额,
     issue_validator                                                    审批人,
     si.issue_type                                                      出库类型,
     MIC_FEE_TYPE.fee_TYPE_NAME                                         费用去向,
     cost_center_name                                                   成本中心,
     asset_list.asset_code                                              设备编码,
     asset_list.asset_name                                              设备名称,
     asset_list.asset_alternative_code                                  固定资产编号,
     concat(admin_employee.employee_code, admin_employee.employee_name) 领用人
   FROM sp_issue_details sid LEFT JOIN sp_issue si ON sid.issue_id = si.issue_code
     LEFT JOIN mic_cost_center mcc ON si.issue_cost_center_id = mcc.cost_center_id
     LEFT JOIN (wo_list
       LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_Asset_id) ON wo_list.wo_id = si.wo_id
     LEFT JOIN admin_employee ON admin_employee.employee_id = si.employee_id
     LEFT JOIN MIC_FEE_TYPE ON MIC_FEE_TYPE.fee_type_id = sid.issue_fee_type


   WHERE issue_status = 6 AND issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')

   UNION ALL

   SELECT
     -- part 2: spare parts returned (with quantity in negative number)
     ret.issue_id                          出库单号,
     return_time                           时间,
     retd.sp_id                            备件号,
     return_qty * -1                       数量,
     issue_sp_unit_price                   价格,
     return_qty * -1 * issue_sp_unit_price 金额,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL
   FROM sp_return_details retd
     JOIN sp_return ret ON retd.return_id = ret.return_id
     JOIN sp_issue_details ON sp_issue_details.issue_details_id = retd.line_issue_details_id
   WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')) issued
  JOIN sp_list ON issued.备件号 = sp_list.sp_id
ORDER BY 时间;
-- ;

CREATE DATABASE hh6;
USE hh6;

SELECT *
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%type%';

SELECT *
FROM mic_type;

SELECT *
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%canc%';

-- 五亭桥工时统计 20170607
SELECT
  wo_id                                           工单号,
  wo_name                                         工单名称,
  aloc.location_code                              位置编码,
  alst.asset_code                                 设备编码,
  alst.asset_name                                 设备名称,
  DATE_FORMAT(wo_creation_time, '%Y-%m-%d %H:%i') 创建时间,
  DATE_FORMAT(wo_start_time, '%Y-%m-%d %H:%i')    开始时间,
  DATE_FORMAT(wo_finish_time, '%Y-%m-%d %H:%i')   完成时间,
  round(
      sum(time_to_sec(
              if(timediff(wo_finish_time, wo_start_time) < 0, 0, timediff(wo_finish_time, wo_start_time))
          ) / 3600), 2)                           停机时间,
  wo_responsible_name                             负责人,
  wo_description                                  故障描述,
  wo_creator                                      工单创建人,
  wo_failure_mode_name                            故障模式,
  wo_failure_mechanism_subdivision_name           故障机制,
  wo_failure_cause_subdivision_name               故障原因,
  wo_maintenance_activity_name                    解决办法,
  wo_feedback                                     反馈
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history wohist
  JOIN asset_list alst ON wohist.asset_id = alst.asset_id
  JOIN asset_location aloc ON alst.location_id = aloc.location_id
WHERE
  aloc.location_lft BETWEEN T.location_lft AND T.location_rgt
  AND wo_creation_time BETWEEN :start_date AND :end_date
  AND wo_status = 8
ORDER BY wo_id;

-- jack
SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
  100 * FORMAT(COUNT(IF(wo_target_time >= wo_finish_time, 1,
                        IF(wo_target_time > NOW() AND wo_finish_time = '0000-00-00 00:00:00', 1, NULL)))
               / COUNT(wo_id),
               2)                        AS val
FROM wo_history
WHERE wo_type_type = 'PREV'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND wo_status = 8
      AND location_code IN (
  SELECT location_code
  FROM asset_location
  WHERE location_lft >= (SELECT location_lft
                         FROM asset_location
                         WHERE location_id = :location_id)
        AND location_rgt <= (SELECT location_rgt
                             FROM asset_location
                             WHERE location_id = :location_id)
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;


SELECT time_to_sec(timediff('2017-05-16 10:40', '2017-05-15 18:48')) / 3600;


SELECT
  whe.employee_name        AS '姓名',
  -- round(SUM(TIME_TO_SEC(wo_worked_hour)) / 3600, 2) AS '工时小时',
  round(
      sum(time_to_sec(
              if(timediff(wo_finish_time, wo_start_time) < 0, 0, timediff(wo_finish_time, wo_start_time))
          )) / 3600, 2)       `工时（小时）`,
  COUNT(whe.wo_id)         AS '工单数',
  SUM(wo_confirmation = 3) AS '满意',
  SUM(wo_confirmation = 2) AS '一般',
  SUM(wo_confirmation = 1) AS '差评'
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
      AND whe.employee_code <> "E001"
      AND wo_status = 8
      AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
GROUP BY whe.employee_name
ORDER BY `工时（小时）` DESC;

SELECT *
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%posi%';

SELECT *
FROM admin_employee;

SELECT EXTRACT(YEAR_MONTH FROM now());

-- 山东彤运报修响应率
SELECT
  xkey,
  round(维修 / 报修 * 100, 0) 维修响应率
FROM
  (SELECT
     extract(YEAR_MONTH FROM mr_request_time) xkey,
     count(mr_id)                             维修
   FROM mr_list
   WHERE mr_status = 6
   GROUP BY extract(YEAR_MONTH FROM mr_request_time)) resp

  NATURAL JOIN

  (SELECT
     extract(YEAR_MONTH FROM mr_request_time) xkey,
     count(mr_id)                             报修
   FROM mr_list
   GROUP BY extract(YEAR_MONTH FROM mr_request_time)) req

SELECT *
FROM mr_list
  LEFT JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id


--
SELECT *
FROM mic_failure_mode
WHERE asset_category_id = 4;

SELECT *
FROM audit_trail_wo_status
ORDER BY wo_id;

SELECT *
FROM mic_status;

SELECT *
FROM wo_history;

-- 五亭桥维修记录 20170612
SELECT
  wo_id                                                     工单号,
  wo_name                                                   工单名称,
  aloc.location_code                                        位置编码,
  alst.asset_code                                           设备编码,
  if(alst.asset_nature <> 0, (SELECT asset_name
                              FROM asset_list
                              WHERE location_id = alst.location_id
                              LIMIT 1, 1), alst.asset_name) 设备名称,
  DATE_FORMAT(wo_creation_time, '%Y-%m-%d %H:%i')           创建时间,
  DATE_FORMAT(wo_start_time, '%Y-%m-%d %H:%i')              开始时间,
  DATE_FORMAT(wo_finish_time, '%Y-%m-%d %H:%i')             完成时间,
  round(
      time_to_sec(
          if(timediff(wo_finish_time, wo_start_time) < 0, 0, timediff(wo_finish_time, wo_start_time))
      ) / 3600, 2)                                          停机时间,
  wo_responsible_name                                       负责人,
  wo_description                                            故障描述,
  wo_creator                                                工单创建人,
  wo_failure_mode_name                                      故障模式,
  wo_failure_mechanism_subdivision_name                     故障机制,
  wo_failure_cause_subdivision_name                         故障原因,
  wo_maintenance_activity_name                              解决办法,
  wo_feedback                                               反馈
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history wohist
  JOIN asset_list alst ON wohist.asset_id = alst.asset_id
  JOIN asset_location aloc ON alst.location_id = aloc.location_id
WHERE
  aloc.location_lft BETWEEN T.location_lft AND T.location_rgt
  AND wo_creation_time BETWEEN :start_date AND :end_date
  AND wo_status = 8
ORDER BY wo_id;

-- 五亭桥报修确认及评分 20170612
SELECT
  mr_requester                        AS '报修人员',
  COUNT(wo_id)                        AS '报修单量',
  SUM(IF(wo_confirmation = 0, 1, 0))  AS '未维修确认总数',
  SUM(IF(wo_confirmation <> 0, 1, 0)) AS '维修确认总数',
  SUM(wo_confirmation = 3)            AS '满意',
  SUM(wo_confirmation = 2)            AS '一般',
  SUM(wo_confirmation = 1)            AS '差评'
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  wo_history
  JOIN asset_location aloc ON wo_history.location_code = aloc.location_code
WHERE aloc.location_lft BETWEEN T.location_lft AND T.location_rgt AND
      DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND wo_type_type = 'CORR'
      AND mr_id <> 0
      AND wo_status = 8
GROUP BY mr_requester;
-- ;


SELECT
  sp_issue.issue_code                                                AS '出库/退库单号',
  sp_issue.issue_time                                                AS '领/退时间',
  concat(sp_issue_details.sp_id, sp_list.sp_name)                    AS '备件名',
  sp_list.sp_specification                                           AS '规格型号',
  sp_list.sp_storage_bin                                             AS '货架编号',
  concat(admin_employee.employee_code, admin_employee.employee_name) AS '申领/退人',
  sp_issue.wo_id                                                     AS '工单号(退库则为空)',
  wo_list.wo_name                                                    AS '工单名称(退库则为空)',
  asset_list.asset_code                                              AS '设备编码(退库则为空)',
  asset_list.asset_name                                              AS '设备名称(退库则为空)',
  sp_issue_details.issue_qty                                         AS '领/退数量',
  #   sp_list.sp_ff_1                                                    AS '是否购买',
  sp_issue_details.issue_sp_unit_price                               AS '单价',
#   sp_list.sp_ff_2                                                    AS '损坏类别',
#   sp_list.sp_ff_3                                                    AS '旧品处理方法',
#   sp_list.sp_ff_2                                                    AS '课别'

FROM sp_issue_details
  INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN wo_list ON wo_list.wo_id = sp_issue.wo_id
  LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_asset_id
  LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id

WHERE sp_issue.issue_status = '6' AND wo_list.wo_status >= 0
      AND sp_issue.issue_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')
UNION ALL

SELECT
  sp_return.return_id,
  return_time,
  concat(sp_list.sp_Code, sp_list.sp_name),
  sp_list.sp_specification                                           规格型号,
  sp_list.sp_storage_bin                                             货架编号,
  concat(admin_employee.employee_code, admin_employee.employee_name) 申领人,
  '',
  '',
  '',
  '',
  concat('-', return_qty),
  #   sp_list.sp_ff_1                                                    是否购买,
  sp_list.sp_unit_price                                              单价,
#   sp_list.sp_ff_2                                                    损坏类别,
#   sp_list.sp_ff_3                                                    旧品处理方法,
#   sp_list.sp_ff_2                                                    课别
FROM sp_return_details
  LEFT JOIN sp_list ON sp_list.sp_id = sp_return_details.sp_id
  INNER JOIN sp_return ON sp_return.return_id = sp_return_details.return_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_return.employee_id
WHERE sp_return.return_status = '6'
      AND sp_return.return_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30');


SELECT
  sp_issue.issue_code                                                AS '出库/退库单号',
  sp_issue.issue_time                                                AS '领/退时间',
  concat(sp_issue_details.sp_id, sp_list.sp_name)                    AS '备件名',
  sp_list.sp_specification                                           AS '规格型号',
  sp_list.sp_storage_bin                                             AS '货架编号',
  concat(admin_employee.employee_code, admin_employee.employee_name) AS '申领/退人',
  sp_issue.wo_id                                                     AS '工单号(退库则为空)',
  wo_list.wo_name                                                    AS '工单名称(退库则为空)',
  asset_list.asset_code                                              AS '设备编码(退库则为空)',
  asset_list.asset_name                                              AS '设备名称(退库则为空)',
  sp_issue_details.issue_qty                                         AS '领/退数量',
  #   sp_list.sp_ff_1                                                    AS '是否购买',
  sp_issue_details.issue_sp_unit_price                               AS '单价'
#   sp_list.sp_ff_2                                                    AS '损坏类别',
#   sp_list.sp_ff_3                                                    AS '旧品处理方法',
#   sp_list.sp_ff_2                                                    AS '课别'
FROM sp_issue_details
  INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN wo_list ON wo_list.wo_id = sp_issue.wo_id
  LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_asset_id
  LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id

# WHERE sp_issue.issue_status = '6' AND wo_list.wo_status >= 0
#     AND sp_issue.issue_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')

UNION ALL

SELECT
  sp_return.return_id,
  return_time,
  concat(sp_list.sp_Code, sp_list.sp_name),
  sp_list.sp_specification                                           规格型号,
  sp_list.sp_storage_bin                                             货架编号,
  concat(admin_employee.employee_code, admin_employee.employee_name) 申领人,
  '',
  '',
  '',
  '',
  concat('-', return_qty),
  #   sp_list.sp_ff_1                                                    是否购买,
  sp_list.sp_unit_price                                              单价
#   sp_list.sp_ff_2                                                    损坏类别,
#   sp_list.sp_ff_3                                                    旧品处理方法,
#   sp_list.sp_ff_2                                                    课别
FROM sp_return_details
  LEFT JOIN sp_list ON sp_list.sp_id = sp_return_details.sp_id
  INNER JOIN sp_return ON sp_return.return_id = sp_return_details.return_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_return.employee_id
# WHERE sp_return.return_status = '6'
#      AND sp_return.return_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')SELECT
sp_issue.issue_code AS '出库/退库单号',
sp_issue.issue_time AS '领/退时间',
concat(sp_issue_details.sp_id, sp_list.sp_name) AS '备件名',
sp_list.sp_specification AS '规格型号',
sp_list.sp_storage_bin AS '货架编号',
concat(admin_employee.employee_code, admin_employee.employee_name) AS '申领/退人',
sp_issue.wo_id AS '工单号(退库则为空)',
wo_list.wo_name AS '工单名称(退库则为空)',
asset_list.asset_code AS '设备编码(退库则为空)',
asset_list.asset_name AS '设备名称(退库则为空)',
sp_issue_details.issue_qty AS '领/退数量',
#   sp_list.sp_ff_1                                                    AS '是否购买',
sp_issue_details.issue_sp_unit_price AS '单价'
#   sp_list.sp_ff_2                                                    AS '损坏类别',
#   sp_list.sp_ff_3                                                    AS '旧品处理方法',
#   sp_list.sp_ff_2                                                    AS '课别'
FROM sp_issue_details
INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
LEFT JOIN wo_list ON wo_list.wo_id = sp_issue.wo_id
LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_asset_id
LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id
LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id

# WHERE sp_issue.issue_status = '6' AND wo_list.wo_status >= 0
#     AND sp_issue.issue_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')

UNION ALL

SELECT
  sp_return.return_id,
  return_time,
  concat(sp_list.sp_Code, sp_list.sp_name),
  sp_list.sp_specification                                           规格型号,
  sp_list.sp_storage_bin                                             货架编号,
  concat(admin_employee.employee_code, admin_employee.employee_name) 申领人,
  '',
  '',
  '',
  '',
  concat('-', return_qty),
  #   sp_list.sp_ff_1                                                    是否购买,
  sp_list.sp_unit_price                                              单价
#   sp_list.sp_ff_2                                                    损坏类别,
#   sp_list.sp_ff_3                                                    旧品处理方法,
#   sp_list.sp_ff_2                                                    课别
FROM sp_return_details
  LEFT JOIN sp_list ON sp_list.sp_id = sp_return_details.sp_id
  INNER JOIN sp_return ON sp_return.return_id = sp_return_details.return_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_return.employee_id
# WHERE sp_return.return_status = '6'
#      AND sp_return.return_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')


--
-- 雪花出库明细（含工单信息）20170612 只保留了前半段
SELECT
  sp_issue.issue_code                                                AS '出库/退库单号',
  sp_issue.issue_time                                                AS '领/退时间',
  concat(sp_issue_details.sp_id, sp_list.sp_name)                    AS '备件名',
  sp_list.sp_specification                                           AS '规格型号',
  sp_list.sp_storage_bin                                             AS '货架编号',
  concat(admin_employee.employee_code, admin_employee.employee_name) AS '申领/退人',
  sp_issue.wo_id                                                     AS '工单号(退库则为空)',
  wo_list.wo_name                                                    AS '工单名称(退库则为空)',
  asset_list.asset_code                                              AS '设备编码(退库则为空)',
  asset_list.asset_name                                              AS '设备名称(退库则为空)',
  sp_issue_details.issue_qty                                         AS '领/退数量',
  #   sp_list.sp_ff_1                                                    AS '是否购买',
  sp_issue_details.issue_sp_unit_price                               AS '单价'
#   sp_list.sp_ff_2                                                    AS '损坏类别',
#   sp_list.sp_ff_3                                                    AS '旧品处理方法',
#   sp_list.sp_ff_2                                                    AS '课别'
FROM sp_issue_details
  INNER JOIN sp_issue ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN wo_list ON wo_list.wo_id = sp_issue.wo_id
  LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_asset_id
  LEFT JOIN sp_list ON sp_list.sp_id = sp_issue_details.sp_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_issue.employee_id

# WHERE sp_issue.issue_status = '6' AND wo_list.wo_status >= 0
#     AND sp_issue.issue_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')

UNION ALL

SELECT
  sp_return.return_id,
  return_time,
  concat(sp_list.sp_Code, sp_list.sp_name),
  sp_list.sp_specification                                           规格型号,
  sp_list.sp_storage_bin                                             货架编号,
  concat(admin_employee.employee_code, admin_employee.employee_name) 申领人,
  '',
  '',
  '',
  '',
  concat('-', return_qty),
  #   sp_list.sp_ff_1                                                    是否购买,
  sp_list.sp_unit_price                                              单价
#   sp_list.sp_ff_2                                                    损坏类别,
#   sp_list.sp_ff_3                                                    旧品处理方法,
#   sp_list.sp_ff_2                                                    课别
FROM sp_return_details
  LEFT JOIN sp_list ON sp_list.sp_id = sp_return_details.sp_id
  INNER JOIN sp_return ON sp_return.return_id = sp_return_details.return_id
  LEFT JOIN admin_employee ON admin_employee.employee_id = sp_return.employee_id
# WHERE sp_return.return_status = '6'
#      AND sp_return.return_time BETWEEN concat(:start_date, ' 06:30') AND concat(:end_date, ' 14:30')


-- ;
SELECT DISTINCT
  whe.employee_name         AS '姓名',
  -- round(SUM(TIME_TO_SEC(wo_worked_hour)) / 3600, 2) AS '工时小时',
  sum(round(time_to_sec(
                if(timediff(wo_finish_time, wo_start_time) < 0, 0, timediff(wo_finish_time, wo_start_time))
            ) / 3600, 2))      `工时（小时）`,
  COUNT(DISTINCT whe.wo_id) AS '工单数',
  SUM(wo_confirmation = 3)  AS '满意',
  SUM(wo_confirmation = 2)  AS '一般',
  SUM(wo_confirmation = 1)  AS '差评'
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
      AND whe.employee_code <> "E001"
      AND wo_status = 8
      AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
GROUP BY whe.employee_name
ORDER BY `工时（小时）` DESC;

--
SELECT DISTINCT
  wo_history.wo_id '工单号',
  wo_name          '工单名称',
  round(
      time_to_sec(
          if(timediff(wo_finish_time, wo_start_time) < 0, 0, timediff(wo_finish_time, wo_start_time))
      ) / 3600, 2) `工时（小时）`,
  CASE wo_confirmation
  WHEN 3
    THEN '满意'
  WHEN 2
    THEN '一般'
  WHEN 1
    THEN '差评'
  ELSE '未评价' END   '评价',
  wo_feedback      '反馈'
FROM wo_history_employee
  LEFT JOIN wo_history
    ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
      AND employee_name = :row
      AND wo_status = 8
ORDER BY wo_history.wo_id DESC;


SELECT wo_type_code
FROM wo_history
--
SELECT
  whe.employee_name AS '姓名',
  COUNT(whe.wo_id)  AS '工单总数',
  sum(CASE WHEN wo_history.wo_type_code = 'CM'
    THEN 1
      ELSE 0 END)      维修类工单数
FROM
  #   (SELECT
  #         location_lft,
  #         location_rgt
  #       FROM asset_location
  #       WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
# WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
#       AND whe.employee_code <> "E001"
#       AND wo_status = 8
#       AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
GROUP BY whe.employee_name;

-- 传化标签打印
SELECT
  asset_code             设备编码,
  asset_alternative_code 资产编码,
  asset_name             设备名称
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  LEFT JOIN asset_location aloc ON asset_list.location_id = aloc.location_id
WHERE asset_nature = 0 AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt;
-- ;


SELECT *
FROM wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
LIMIT 10
-- select count(*), sum(case when wo_type_code = 'CM' then 1 else 0 end) from wo_history


-- 彤运 工单完成情况2017-06-15
SELECT
  whe.employee_name AS                               '姓名',
  COUNT(whe.wo_id)  AS                               '工单总数',
  sum(CASE WHEN wo_type_code = 'INSP'
    THEN 1
      ELSE 0 END)                                    点巡检,
  sum(CASE WHEN wo_type_code = 'CM'
    THEN 1
      ELSE 0 END)                                    维修,
  sum(CASE WHEN wo_type_code = 'PM'
    THEN 1
      ELSE 0 END)                                    预防性保养,
  sum(CASE WHEN wo_finish_time <= wo_target_time
    THEN 1
      ELSE 0 END)                                    按时完成,
  round(sum(CASE WHEN wo_finish_time <= wo_target_time
    THEN 1
            ELSE 0 END) / count(whe.wo_id) * 100, 2) `按时完成率%`
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
      AND whe.employee_code <> "E001"
      AND wo_status = 8
      AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
GROUP BY whe.employee_name;
-- ;

SELECT DISTINCT
  TABLE_NAME,
  INDEX_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'hh6';

SHOW INDEX FROM asset_list;

USE hh6;

SELECT *
FROM audit_trail_wo_status;


SELECT
  whe.employee_name                  AS '姓名',
  -- round(SUM(TIME_TO_SEC(wo_worked_hour)) / 3600, 2) AS '工时小时',
  round(
      sum(time_to_sec(
              if(timediff(wo_finish_time, wo_start_time) < 0
                 OR (wo_start_time = 0),
                 0, timediff(wo_finish_time, wo_start_time))
          )) / 3600, 2)              AS `工时（小时）`,

  COUNT(DISTINCT CASE WHEN new_status IN (1, 2, 3, 4)
    THEN 0
                 ELSE whe.wo_id END) AS '工单数',
  SUM(wo_confirmation = 3)           AS '满意',
  SUM(wo_confirmation = 2)           AS '一般',
  SUM(wo_confirmation = 1)           AS '差评'
FROM (SELECT
        location_lft,
        location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
  LEFT JOIN audit_trail_wo_status ON wo_history.wo_id = audit_trail_wo_status.wo_id
WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
      AND whe.employee_code <> "E001"
      AND wo_status = 8
      AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
      --       and new_status not IN (1, 2, 3, 4)
      AND new_status IS NULL
GROUP BY whe.employee_name
ORDER BY `工时（小时）` DESC


SELECT
  whe.employee_name         AS '姓名',
  -- round(SUM(TIME_TO_SEC(wo_worked_hour)) / 3600, 2) AS '工时小时',
  round(
      sum(
          time_to_sec(
              if(timediff(wo_finish_time, wo_start_time) < 0
                 OR (wo_start_time = 0),
                 0,
                 timediff(wo_finish_time, wo_start_time))
          )
      ) / 3600, 2)          AS `工时（小时）`,

  COUNT(DISTINCT
        CASE WHEN new_status IN (1, 2, 3, 4)
          THEN 0
        ELSE whe.wo_id END) AS '工单数',
  SUM(wo_confirmation = 3)  AS '满意',
  SUM(wo_confirmation = 2)  AS '一般',
  SUM(wo_confirmation = 1)  AS '差评'
FROM
  #   (SELECT
  #         location_lft,
  #         location_rgt
  #       FROM asset_location
  #       WHERE location_id = :location_id) AS T,
  wo_history_employee whe
  LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
  LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
  LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
  NATURAL LEFT JOIN audit_trail_wo_status
WHERE

  #   DATE(wo_finish_time) BETWEEN :start_date AND :end_date
  #       AND whe.employee_code <> "E001"
  #       AND wo_status = 8
  #       AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
  # --       and new_status not IN (1, 2, 3, 4)
  # and
  audit_trail_wo_status.new_status IS NULL
GROUP BY whe.employee_name
ORDER BY `工时（小时）` DESC







