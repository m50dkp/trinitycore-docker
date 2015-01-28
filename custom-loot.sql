INSERT INTO `creature_template` (`entry`, `modelid1`, `name`, `subname`, `IconName`, `minlevel`, `maxlevel`, `faction`, `lootid`, `mingold`, `maxgold`, `AIName`, `unit_class`) VALUES (80010, 1337, "Imma get ya!", "Take My Stuff!", "Attack", 5, 5, 18, 80010, 10, 10000, "AgressorAI", 1);

# if all chances in a groupid are 0, then the group drop rate is 100%.
# i set the groupid to the InventorySlot (8 is footwear, 5 is chest)
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`, `Chance`, `GroupId`)
VALUES
  (80010, 33577, 0, 8),
  (80010, 37984, 0, 8),
  (80010, 30231, 0, 5),
  (80010, 35036, 0, 5);



docker run --rm -it --link tc-dbserver:TCDB trinitycore-db /bin/bash
$ mysql -hTCDB -uroot -ppassword
mysql> use world;
mysql>    paste your commands here.



DELIMITER //
DROP PROCEDURE IF EXISTS armorDrops;
CREATE PROCEDURE armorDrops
(InventoryType tinyint(3),
 Material tinyint(3))
BEGIN
  DROP TEMPORARY TABLE IF EXISTS loot;
  CREATE TEMPORARY TABLE loot AS
      SELECT cl.item, cl.Reference FROM creature_template as ct
      JOIN instance_encounters as ie ON ct.entry = ie.creditEntry
      JOIN creature_loot_template as cl ON cl.entry = ct.lootid
      WHERE ie.creditType = 0;

  DROP TEMPORARY TABLE IF EXISTS moreloot;
  CREATE TEMPORARY TABLE moreloot AS
    SELECT rl.item FROM reference_loot_template as rl
    JOIN loot as l ON l.Reference = rl.entry
    WHERE l.Reference != 0;

  SELECT DISTINCT it.entry, it.name FROM item_template as it
  WHERE it.class = 4
  AND it.InventoryType = InventoryType
  AND it.Material = Material
  AND (it.entry IN (SELECT item FROM loot) OR it.entry IN (SELECT item FROM moreloot));
END //
DELIMITER ;

CALL armorDrops(8, 8);
