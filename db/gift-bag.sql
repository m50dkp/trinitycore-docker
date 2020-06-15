
delete from world.creature_queststarter where quest = 101001;
delete from world.creature_questender where quest = 101001;
delete from world.quest_offer_reward where ID = 101001;
delete from world.quest_template where ID = 101001;



insert into world.quest_template (ID, QuestType, QuestLevel, MinLevel, Flags, RewardItem1, RewardAmount1, LogTitle, LogDescription, QuestDescription, ObjectiveText1 )
values (101001, 2, 1, 1, 65536, 23162, 4, "Free bags", "Talk to me again to receive your reward!", "Hey $n. Welcome to this world. For a reward talk to me again!", "Talk to me again to receive your reward!");

insert into world.quest_offer_reward (ID, RewardText ) values (101001, "Hey $n. Welcome to this world. Here are some gifts to help you!");

insert into world.creature_queststarter (id, quest) value (15278, 101001), (1568, 101001), (10176, 101001), (2980, 101001), (25462, 101001), (823, 101001), (658, 101001), (2079, 101001), (16475, 101001);

insert into world.creature_questender (id, quest) value (15278, 101001), (1568, 101001), (10176, 101001), (2980, 101001), (25462, 101001), (823, 101001), (658, 101001), (2079, 101001), (16475, 101001);

