USE mic00001;
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('HC', '行车');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('DL', '电炉');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('LQT', '冷却塔');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('XCQ', '吸尘器');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('JZJ', '大套浇注机');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('SZT', '双轴镗床');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('SK', '全功能数控车床');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('GST', '高速镗床');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('WXM', '无芯磨');
INSERT INTO mic_asset_category (asset_category_code, asset_category_name) VALUES ('HM', '珩磨');


SHOW CREATE TABLE mic_failure_mode;
# CREATE TABLE `mic_failure_mode` (
#   `failure_mode_id`   TINYINT(3) UNSIGNED     NOT NULL AUTO_INCREMENT,
#   `asset_category_id` TINYINT(3) UNSIGNED     NOT NULL,
#   `failure_mode_code` VARCHAR(3)
#                       COLLATE utf8_unicode_ci NOT NULL,
#   `failure_mode_name` VARCHAR(36)
#                       COLLATE utf8_unicode_ci NOT NULL,
#   PRIMARY KEY (`failure_mode_id`)
# )
#   ENGINE = MyISAM
#   AUTO_INCREMENT = 166
#   DEFAULT CHARSET = utf8
#   COLLATE = utf8_unicode_ci;


-- Change failure_mode_code to 4 characters
ALTER TABLE mic_failure_mode
  MODIFY `failure_mode_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT
  COLLATE utf8_unicode_ci NOT NULL;
-- ;

SELECT *
FROM mic_asset_category;

DELETE FROM mic_asset_category
WHERE asset_category_code IN ('MEC2', 'MEC1', 'MEC0');


SELECT * FROM mic_failure_mode;

SELECT * from wo_list;
TRUNCATE TABLE wo_history;

TRUNCATE table mr_list;
