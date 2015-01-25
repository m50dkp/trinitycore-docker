-- This script to be entered into world database

-- Vendor Template -- npcflag from 4096 (repair flag), 128 (base vendor flag)
INSERT INTO `creature_template` (`entry`, `modelid1`, `name`, `subname`, `minlevel`, `maxlevel`, `npcflag`) VALUES (80000 ,3276, "Bill", "T-1000 vendor", 5, 5, 4224);

-- NPC vedor items -- Lawbringer (paladin) 
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16853);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16854);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16855);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16856);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16857);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16858);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16859);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16860);

-- NPC vendor items -- Nightslayer (rogue)

INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16820);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16821);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16822);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16823);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16824);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16825);

INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16826);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16827);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16828);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16829);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16830);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16831);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16832);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 16833);

INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 27);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 45283);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`) VALUES (80000, 0, 76);

UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16820;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16821;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16822;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16823;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16824;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16825;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16826;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16827;

UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16853;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16854;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16855;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16856;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16857;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16858;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16859;
UPDATE `npc_vendor` SET `slot` = 0 WHERE `entry` = 80000 AND `item` = 16860;

DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16853;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16854;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16855;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16856;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16857;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16858;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16859;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16860;

DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16820;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16821;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16822;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16823;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16824;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16825;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16826;
DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 16827;

DELETE FROM `npc_vendor` WHERE `entry` = 80000 AND `item` = 45283;


UPDATE `creature_template` SET `npcflag` = 4224 WHERE `entry` = 80000;