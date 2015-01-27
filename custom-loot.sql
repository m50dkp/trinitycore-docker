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

