SET @eamic_user = 'Pierre';

SET @a := 1;
SET @b := 2;

UPDATE asset_list
SET asset_structure_lft = @a := @a + 2, asset_structure_lft = @b := @b + 2
WHERE location_id = :location_id
      AND (asset_nature = 0 OR asset_nature = 1);

--

SET @eamic_user = 'Pierre';

UPDATE asset_list
SET asset_structure_lft = 0, asset_structure_lft = 0
WHERE location_id = :location_id
      AND (asset_nature = 0 OR asset_nature = 1);

SET @a := -1;
SET @b := 0;

UPDATE asset_list
SET asset_structure_lft = @a := @a + 2, asset_structure_lft = @b := @b + 2
WHERE location_id = :location_id
      AND (asset_nature = 0 OR asset_nature = 1);

--
SET @eamic_user = 'Pierre';

UPDATE asset_list
SET asset_structure_lft = 0, asset_structure_lft = 0
WHERE location_id = :location_id
      AND (asset_nature = 0 OR asset_nature = 1);