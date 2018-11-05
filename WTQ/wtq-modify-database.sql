SHOW STATUS;

USE mic00001;
SELECT *
FROM asset_list
LIMIT 100;

-- Be careful!!!

SELECT *
FROM mic_asset_category
ORDER BY asset_category_id;

SELECT *
FROM mic_asset_class
ORDER BY asset_category_id;
SELECT *
FROM mic_asset_type;
SELECT *
FROM mic_asset_type_class;

UPDATE mic_asset_category
SET asset_category_id = 3
WHERE asset_category_code = 'MEC0';

INSERT INTO mic_asset_category (asset_category_id, asset_category_code, asset_category_name)
VALUES (1, 'MEC2', '钻床及镗床');

INSERT INTO mic_asset_category (asset_category_id, asset_category_code, asset_category_name) VALUES (2, 'MEC1', '车床');

INSERT INTO mic_asset_category (asset_category_id, asset_category_code, asset_category_name) VALUES (4, 'MEC3', '研磨机床');

DELETE FROM mr_list
WHERE mr_list.mr_id < 38;

SELECT *
FROM wo_list;
TRUNCATE TABLE wo_list;

SELECT *
FROM wo_list
LIMIT 10;

USE mic00001;
SELECT *
FROM asset_list
WHERE asset_nature = 5 AND asset_code LIKE 'W1%';

SET @eamic_user := 'E001 va@wutingqiao';

UPDATE asset_list
SET asset_name = '机加三分厂'
WHERE asset_code LIKE 'W0%'; -- AND asset_nature = 5 ;

SELECT
  TABLE_NAME,
  COLUMN_NAME
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE 'change_employee_name';

SELECT *
FROM audit_trail_varchar
ORDER BY change_datetime DESC;

SHOW CREATE TABLE audit_trail_varchar;

USE INFORMATION_SCHEMA;
SELECT
  TABLE_NAME,
  COLUMN_NAME,
  CONSTRAINT_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'mic00001' AND TABLE_NAME = 'asset_list'
      AND referenced_column_name IS NOT NULL;

SHOW TRIGGERS;
WHERE TABLE = 'asset_list';

use mic00001;
SELECT * from mic_asset_category;

DELETE from mic_failure_mode where asset_category_id = 2;
