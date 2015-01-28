use world//


DROP PROCEDURE IF EXISTS armorDrops;
CREATE PROCEDURE armorDrops
(CreatureId mediumint(8),
 InventoryType tinyint(3),
 Material tinyint(3),
 MinLevel int,
 MaxLevel int)
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

  INSERT INTO creature_loot_template
    (Entry, Item, Chance, GroupId)
  SELECT CreatureId, it.entry, 0, Material FROM item_template as it
    WHERE it.class = 4
    AND it.InventoryType = InventoryType
    AND it.Material = Material
    AND (it.entry IN (SELECT item FROM loot) OR it.entry IN (SELECT item FROM moreloot))
    AND it.ItemLevel >= MinLevel
    AND it.ItemLevel <= MaxLevel
    GROUP BY it.entry;

  -- TODO: would be nice if the name could be generated.. stuff like "Heady the Raptor"
  -- for head, "Braces the Raptor" for bracers, etc.

END //