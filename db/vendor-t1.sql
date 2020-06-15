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
