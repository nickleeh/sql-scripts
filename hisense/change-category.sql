-- Change `AJ` to category 14 CLSB
SET @eamic_user = 'va@hisense'; -- EAMic need to record who changed the data before `UPDATE` a field. 
UPDATE asset_list
SET asset_category_id = '14' 
WHERE asset_code REGEXP '-AJ[0-9]{2}-'; -- Change `AJ` to category 14 CLSB.
--