--- given an item level range, create a creature per InventoryType that drop
--- items within that range.
-- TODO: think of a neat id naming system so they are manageable...
-- entry / lootid are both unsigned mediumints, so 16777215 is max.

/*
  Material:

  -1: consummable?
  0: not defined
  1: metal
  2: wood
  3: liquid
  4: jewelry
  5: chain
  6: plate
  7: cloth
  8: leather
*/

/*
  InventoryType (equipment slot type):

  0: non-equippable
  1: head
  2: neck
  3: shoulder
  4: shirt
  5: chest
  6: waist
  7: legs
  8: feet
  9: wrists
  10: hands

  11: finger
  12: trinket

  13: weapon
  14: shield

  15: ranged (bows)
  16: back
  17: two-hand

  18: bag
  19: tabard
  20: robe    <--- strangely has chest stuff too

  21: main hand
  22: off hand

  23: holdable (tome)
  24: ammo
  25: thrown

  26: ranged right (wands, guns)
  27: quiver

  28: relic
 */

use world;

-- level 28 - 33
SET @CreatureMinLvl := 28;
SET @CreatureMaxLvl := 35;
SET @MinItemLevel := 28;
SET @MaxItemLevel := 33;



SET @CreatureId := 80020;
SET @InventoryType := 1;

-- Kill old items!?
DELETE FROM creature_loot_template
WHERE Entry = @CreatureId;

-- Kill previous creature!?
DELETE FROM creature_template
WHERE entry = @CreatureId
LIMIT 1;

-- head, chain - leather
CALL armorDrops(@CreatureId, @InventoryType, 5, @MinItemLevel, @MaxItemLevel);
CALL armorDrops(@CreatureId, @InventoryType, 6, @MinItemLevel, @MaxItemLevel);
CALL armorDrops(@CreatureId, @InventoryType, 7, @MinItemLevel, @MaxItemLevel);
CALL armorDrops(@CreatureId, @InventoryType, 8, @MinItemLevel, @MaxItemLevel);

-- lootid == entry is just a convention, it doesn't have to. The foreign key
-- is that creature_template.lootid == creature_loot_template.entry
INSERT INTO creature_template (
  entry, modelid1, name, subname, IconName, minlevel, maxlevel,
  faction, lootid, mingold, maxgold, AIName, unit_class
) VALUES (
  @CreatureId, 1337, "LootDepot", "Head Gear", "Attack", @CreatureMinLvl, @CreatureMaxLvl,
  18, @CreatureId, 10, 10000, "AgressorAI", 1
);



SET @CreatureId := @CreatureId + 1;
SET @InventoryType := 5;

-- Kill old items!?
DELETE FROM creature_loot_template
WHERE Entry = @CreatureId;

-- Previous Creature!?
DELETE FROM creature_template
WHERE entry = @CreatureId
LIMIT 1;

-- chest, chain - leather
CALL armorDrops(@CreatureId, @InventoryType, 5, @MinItemLevel, @MaxItemLevel);
CALL armorDrops(@CreatureId, @InventoryType, 6, @MinItemLevel, @MaxItemLevel);
CALL armorDrops(@CreatureId, @InventoryType, 7, @MinItemLevel, @MaxItemLevel);
CALL armorDrops(@CreatureId, @InventoryType, 8, @MinItemLevel, @MaxItemLevel);

-- lootid == entry is just a convention, it doesn't have to. The foreign key
-- is that creature_template.lootid == creature_loot_template.entry
INSERT INTO creature_template (
  entry, modelid1, name, subname, IconName, minlevel, maxlevel,
  faction, lootid, mingold, maxgold, AIName, unit_class
) VALUES (
  @CreatureId, 1337, "LootDepo", "Chest Gear", "Attack", @CreatureMinLvl, @CreatureMaxLvl,
  18, @CreatureId, 10, 10000, "AgressorAI", 1
);
