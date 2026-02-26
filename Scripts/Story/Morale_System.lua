require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PGStoryMode")
require("globalPlanetTable")

function Definitions()

    ServiceRate = 0.75

    StoryModeEvents = 
    {
        Morale_Level_Init = Init_Morale_System,
        Morale_Lost_Battle = Lost_Battle,
        Morale_Lost_Battle_Major = Lost_Battle_Major,
        Morale_Won_Battle = Won_Battle,
        Morale_Won_Battle_Major = Won_Battle_Major,
        Morale_Construction_Event_Minor = Default_Event_Function,
        Morale_Construction_Event = Default_Event_Function,
        Morale_Construction_Event_Major = Default_Event_Function,
        Hero_Lost = Default_Event_Function,
        Hero_Killed = Default_Event_Function,
        Flush = Flush,
        Morale_Update = Morale_System_Update,
    }

    Morale_Event_Table = {
        Events = {
            ["Morale_Lost_Battle"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS_NAME", Value = 2, Subtract = true, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS"},
            ["Morale_Lost_Battle_Major"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS_STREAK_NAME", Value = 7, Subtract = true, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS_STREAK"},
            ["Morale_Won_Battle"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN_NAME", Value = 1, Subtract = false, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN"},
            ["Morale_Won_Battle_Major"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN_STREAK_NAME", Value = 3, Subtract = false, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN_STREAK"},
            ["Morale_Construction_Event_Minor"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MINOR_NAME", Value = 1, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MINOR"},
            ["Morale_Construction_Event"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_NAME", Value = 2, Subtract = false,String = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION"},
            ["Morale_Construction_Event_Major"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MAJOR_NAME", Value = 3, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MAJOR"},
            ["Hero_Lost"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_LOST_NAME", Value = 8, Subtract = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_LOST"},
            ["Hero_Killed"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_KILLED_NAME", Value = 3, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_KILLED"},
        },
        
        Recent = nil
    }

    function Morale_Event_Table:Set_Recent_Event(Event)
        if type(Event) ~= "table" or type(Event.Value) ~= "number" then
            self.Recent = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_UNKNOWN", Value = 0, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_UNKNOWN"}
        else
            self.Recent = Event
        end
    end

    Morale_Event_Table_Cache = {
        Positive = {},
        Negative = {},
    }

    UNSC_Kill_Ratio_Table = {0.09, 0.15, 0.25 , 0.35, 0.6} -- the index is the morale gain from the kill ratio at that index

    COVN_Kill_Ratio_Table = {0.3, 0.5, 1, 2, 3}

    Morale_Levels = {
        {Range = {0,15}, Punishment = true, Name = "Compromised", Display_Name = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED_DESCRIPTION"},
        {Range = {16,35}, Punishment = false, Name = "Strained", Display_Name = "TEXT_STORY_MORALE_DISPLAY_STRAINED", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_STRAINED_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_STRAINED_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_STRAINED_DESCRIPTION"},
        {Range = {36,74}, Punishment = false, Name = "Stabilized", Display_Name = "TEXT_STORY_MORALE_DISPLAY_STABILIZED", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_STABILIZED_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_STABILIZED_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_STABILIZED_DESCRIPTION"},
        {Range = {75,89}, Punishment = false, Name = "Resolute", Display_Name = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE_DESCRIPTION"},
        {Range = {90,100}, Punishment = false, Name = "Ascendant", Display_Name = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT_DESCRIPTION"},
    }

    hero_status_table = {
        UNSC_POA = {Current_Status = false, Equation = "Is_POA_Alive", Object = nil, Owner = nil},
        UNSC_IAC = {Current_Status = false, Equation = "Is_IAC_Alive", Object = nil, Owner = nil},
        UNSC_ROMAN_BLUE = {Current_Status = false, Equation = "Is_Roman_Blue_Alive", Object = nil, Owner = nil},
        UNSC_SOF = {Current_Status = false, Equation = "Is_SOF_Alive", Object = nil, Owner = nil},
        COVN_PIOUS = {Current_Status = false, Equation = "Is_Pious_Alive", Object = nil, Owner = nil},
        COVN_JUL = {Current_Status = false, Equation = "Is_Jul_Alive", Object = nil, Owner = nil},
        COVN_ARDO = {Current_Status = false, Equation = "Is_Ardo_Alive", Object = nil, Owner = nil},
        COVN_MACCABEUS = {Current_Status = false, Equation = "Is_Maccabeus_Alive", Object = nil, Owner = nil},
    }

    Modifiers = {
        EMPIRE = {
            ["Normal"] = {
                Morale_Gain_Multiplier = 0.75,
                Random_Morale_Negative_Chance = {50,60},
                Random_Morale_Gain_Loss = {1,5},
                Yearly_Planetary_Morale_Loss = -15, -- when player is in low morale, how much morale does a planet lose every year out of 100, so 100/10 = 10 years to planet loss
                Battle_Win_Streak_Requirement = 8,

            },
            ["Hard"] = {
                Morale_Gain_Multiplier = 0.5,
                Random_Morale_Negative_Chance = {60,80},
                Random_Morale_Gain_Loss = {3,6},
                Yearly_Planetary_Morale_Loss = -20,
                Battle_Win_Streak_Requirement = 12,
            }
        },
        Default = {
            ["Default"] = {
                Morale_Gain_Multiplier = 1,
                Random_Morale_Negative_Chance = {40,60},
                Random_Morale_Gain_Loss = {0,3},
                Yearly_Planetary_Morale_Loss = -10,
                Battle_Win_Streak_Requirement = 6,
            }
        }
    }

    function Modifiers:Get_Modifiers(Faction)
        if Faction == nil or Faction.Get_Faction_Name == nil then
            return self.Default["Default"]
        end

        local Faction_Name = string.upper(Faction.Get_Faction_Name())

        if self[Faction_Name] == nil then
            return self.Default["Default"]
        end

        if Global_Values.Difficulty == nil then
            return self.Default["Default"]
        end

        if self[Faction_Name][Global_Values.Difficulty] == nil then
            return self.Default["Default"]
        end

        return self[Faction_Name][Global_Values.Difficulty]
    end

    Global_Values = {
        Player = nil,
        Enemy = nil,
        Difficulty = nil,
        Plot = nil,
        Display_Event = nil,
        Can_Lose_Only_Planet = false,

    }

    Morale_Value_Status = {
        Current = 100,
        Last = 100,
        Targeted_Planet = nil,
        Next_Random_Morale_Swing = 3
    }

    Battle_Info = {
        Win_Streak = 0,
        Loss_Streak = 0
    }

    function Battle_Info:Increase_Win_Streak() 
        self.Win_Streak = self.Win_Streak + 1

        if type(self.Win_Streak) ~= "number" then
            self.Win_Streak = 0
        end

        self.Loss_Streak = 0
    end

    function Battle_Info:Increase_Loss_Streak()
        self.Loss_Streak = self.Loss_Streak + 1

        if type(self.Loss_Streak) ~= "number" then
            self.Loss_Streak = 0
        end

        self.Win_Streak = 0
    end

    morale_string = {
        Target_Planet = "TEXT_STORY_MORALE_DISPLAY_TARGET_PLANET_INFO",
        Recent_Event = {
            Bad = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_BAD",
            Good = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_GOOD"
        },
        Win_Streak = "TEXT_STORY_MORALE_DISPLAY_WIN_STREAK",
        Loss_Streak = "TEXT_STORY_MORALE_DISPLAY_LOSS_STREAK"
    }

    Planetary_Pathing_Table = nil

    Planet_Morale_Table = nil

end

function Init_Morale_System(message)
    if message == OnEnter then

        Global_Values.Player = Find_Human_Player()

        for hero, status in pairs(hero_status_table) do
            if EvaluatePerception(status.Equation, Global_Values.Player) == 1 then
                hero_status_table[hero].Current_Status = true
                
                local hero_object = Find_First_Object(hero)

                if TestValid(hero_object) then
                    hero_status_table[hero].Object = hero_object
                    hero_status_table[hero].Owner = hero_object.Get_Owner()
                end

            end
        end

        Global_Values.Plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Morale_System.xml")

        if StringCompare(Global_Values.Player.Get_Faction_Name(), "Rebel") or StringCompare(Global_Values.Player.Get_Faction_Name(), "Terrorists") then
            Story_Event("Morale_Display_UNSC")

            Global_Values.Display_Event = Global_Values.Plot.Get_Event("Morale_Display_UNSC")

            morale_string.Level = "TEXT_STORY_MORALE_DISPLAY_BODY_UNSC_VALUES"
        else
            Story_Event("Morale_Display_COVN")

            morale_string.Level = "TEXT_STORY_MORALE_DISPLAY_BODY_COVN_VALUES"

            Global_Values.Display_Event = Global_Values.Plot.Get_Event("Morale_Display_COVN")
        end

        GlobalValue.Set("Morale_Active", 1)

        if StringCompare(Global_Values.Player.Get_Faction_Name(), "Empire") then
            Global_Values.Enemy = Find_Player("Rebel")
        else
            Global_Values.Enemy = Find_Player("Empire")
        end

        --DebugMessage("%s -- Enemy Player: %s", tostring(Script), tostring(enemy))

        if TestValid(Global_Values.Enemy) then
            Global_Values.Difficulty = Global_Values.Enemy.Get_Difficulty()
        end

        --DebugMessage("%s -- Current Difficulty: %s", tostring(Script), tostring(Difficulty))

        if StringCompare(Global_Values.Difficulty, "Normal") then
            Morale_Value_Status.Current = 50

            Morale_Value_Status.Last = 50
        elseif StringCompare(Global_Values.Difficulty, "Hard") then
            Morale_Value_Status.Current = 25

            Morale_Value_Status.Last = 25

            Global_Values.Can_Lose_Only_Planet = true
        end

    
        local planets = Planet_Table:Return_All_Keys()

        for i,planet_name in ipairs(planets) do

            local select_event = Global_Values.Plot.Get_Event("SELECT_"..planet_name)

            if select_event ~= nil then
                select_event.Set_Reward_Parameter(1, Global_Values.Player.Get_Faction_Name())
            end
        end

        Planetary_Pathing_Table = Build_Neighbor_Table()

        Planet_Morale_Table = Build_Morale_Table()

        for _, Morale_Event in pairs(Morale_Event_Table.Events) do
            if Morale_Event.Subtract then
                table.insert(Morale_Event_Table_Cache.Negative, Morale_Event)
            else
                table.insert(Morale_Event_Table_Cache.Positive, Morale_Event)
            end
        end

        Set_Next_State("Flush")
    end
end

function Morale_System_Update(message)
    if message == OnUpdate then

        --DebugMessage("%s -- Current Game Mode: %s", tostring(Script), tostring(Get_Game_Mode()))

        --DebugMessage("%s -- Time: %s, Galactic Time: %s", tostring(Script), tostring(GetCurrentTime()), tostring(GetCurrentTime.Galactic_Time()))

        --DebugMessage("%s -- Win Streak: %s, Loss Streak: %s", tostring(Script), tostring(win_streak), tostring(loss_streak))

        --DebugMessage("%s -- Current Morale Level: %s", tostring(Script), tostring(global_morale_level))

        Check_Hero_Status()

        Reset_Morale_Entries()

        if Morale_Value_Status.Current > 100 then
            Morale_Value_Status.Current = 100
        elseif Morale_Value_Status.Current < 0 then
            Morale_Value_Status.Current = 0
        end

        local Current_Morale_Entry = Get_Morale_Level()

        local Current_Morale_Status = nil

        if Current_Morale_Entry ~= nil then

            Current_Morale_Status = Current_Morale_Entry.Name

            morale_string.Battle_Bonus = Current_Morale_Entry.Bonus.Battle

            morale_string.Production_Bonus = Current_Morale_Entry.Bonus.Production

            morale_string.Description = Current_Morale_Entry.Description

            --DebugMessage("%s -- Morale Display Strings: %s, %s, %s, %s", tostring(Script), tostring(Current_Morale_Status.Name), tostring(Current_Morale_Status.Bonus.Battle), tostring(status.Bonus.Production), tostring(status.Description))

            Handle_Planet_Production(Current_Morale_Entry)
        end

        Random_Morale_Swing()

        GlobalValue.Set("Morale_Status", Current_Morale_Status)

        --DebugMessage("%s -- Current Morale Status: %s", tostring(Script), tostring(Current_Morale_Status))

        if Global_Values.Display_Event ~= nil and Current_Morale_Status ~= nil then

            Global_Values.Display_Event.Clear_Dialog_Text()
            
            Global_Values.Display_Event.Add_Dialog_Text(morale_string.Level, Current_Morale_Entry.Display_Name, tostring(Morale_Value_Status.Current))

            Global_Values.Display_Event.Add_Dialog_Text(" ")

            Global_Values.Display_Event.Add_Dialog_Text(morale_string.Description)

            Global_Values.Display_Event.Add_Dialog_Text(" ")

            Global_Values.Display_Event.Add_Dialog_Text(morale_string.Battle_Bonus)

            Global_Values.Display_Event.Add_Dialog_Text(" ")

            Global_Values.Display_Event.Add_Dialog_Text(morale_string.Production_Bonus)

            Global_Values.Display_Event.Add_Dialog_Text(" ")

            if Morale_Event_Table.Recent ~= nil then

                local Recent_Event_String = morale_string.Recent_Event.Good

                if Morale_Event_Table.Recent.Subtract then
                    Recent_Event_String = morale_string.Recent_Event.Bad
                end

                Global_Values.Display_Event.Add_Dialog_Text(Recent_Event_String, Morale_Event_Table.Recent.Name, Morale_Event_Table.Recent.Value)

                Global_Values.Display_Event.Add_Dialog_Text(" ")
            end

            if Battle_Info.Win_Streak > 0 then
                Global_Values.Display_Event.Add_Dialog_Text(morale_string.Win_Streak, tostring(Battle_Info.Win_Streak))

                Global_Values.Display_Event.Add_Dialog_Text(" ")
            end

            if Battle_Info.Loss_Streak > 0 then
                Global_Values.Display_Event.Add_Dialog_Text(morale_string.Loss_Streak, tostring(Battle_Info.Loss_Streak))

                Global_Values.Display_Event.Add_Dialog_Text(" ")
            end

            Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_LEVELS")

            Global_Values.Display_Event.Add_Dialog_Text(" ")

            for _, entry in ipairs(Morale_Levels) do
                Global_Values.Display_Event.Add_Dialog_Text(entry.Display_Name .. "_RANGE", tostring(entry.Range[1]), tostring(entry.Range[2]))
            end
            
        end

        --DebugMessage("%s -- End of Main Event Display", tostring(Script))

        local Is_On_Last_Planet = Is_Player_On_Last_Planet()

        local Activate_Low_Morale = false

        if Current_Morale_Entry ~= nil and Current_Morale_Entry.Punishment then
            if (not Is_On_Last_Planet) or Global_Values.Can_Lose_Only_Planet then
                Activate_Low_Morale = true
            end
        end

        if Activate_Low_Morale then
            Low_Planet_Morale()

            if Morale_Value_Status.Targeted_Planet ~= nil then
                local targeted_planet_entry = Get_Planet_Morale(Morale_Value_Status.Targeted_Planet)

                if targeted_planet_entry ~= nil then
                    Global_Values.Display_Event.Add_Dialog_Text(" ")

                    Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_TARGET_PLANET_TITLE")

                    Global_Values.Display_Event.Add_Dialog_Text(morale_string.Target_Planet, Planet_Table:Get_Planet_String(Morale_Value_Status.Targeted_Planet), tostring(targeted_planet_entry.Morale))
                end
            end
        else
            High_Planet_Morale()
        end
    
        Global_Values.Display_Event.Add_Dialog_Text(" ")

        Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_EVENTS_POSITIVE")

        for _, Morale_Event in pairs(Morale_Event_Table_Cache.Positive) do
            Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_EVENT", Morale_Event.Name)
        end

        Global_Values.Display_Event.Add_Dialog_Text(" ")

        Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_EVENTS_NEGATIVE")

        for _, Morale_Event in pairs(Morale_Event_Table_Cache.Negative) do
            Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_EVENT", Morale_Event.Name)
        end

        Global_Values.Display_Event.Add_Dialog_Text(" ")

        Global_Values.Display_Event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_EVENT_RANDOM")
    end
end

function Random_Morale_Swing()

    local Current_Week = Get_Current_Week()

    if Morale_Value_Status.Next_Random_Morale_Swing <= Current_Week then
        Morale_Value_Status.Next_Random_Morale_Swing = Current_Week + EvenMoreRandom(2,4, 5)

        local Bad_Chances = {40,60}

        local Morale_Swings = {0,2}

        local Player_Modifiers_Entry = Modifiers:Get_Modifiers(Global_Values.Player)

        DebugMessage("%s -- %s Modifiers Entry: %s", tostring(Script), tostring(Global_Values.Player), tostring(Player_Modifiers_Entry))

        if Player_Modifiers_Entry ~= nil then

            if type(Player_Modifiers_Entry.Random_Morale_Gain_Loss) == "table" and type(Player_Modifiers_Entry.Random_Morale_Negative_Chance) == "table" then
                Bad_Chances = Player_Modifiers_Entry.Random_Morale_Negative_Chance

                Morale_Swings = Player_Modifiers_Entry.Random_Morale_Gain_Loss
            end
        end

        local Bad_Chance = EvenMoreRandom(Bad_Chances[1],Bad_Chances[2],1) / 100

        local Is_Bad = Return_Chance(Bad_Chance, 1)

        local Morale_Swing = EvenMoreRandom(Morale_Swings[1],Morale_Swings[2],15)

        if Morale_Swing == 0 then
            return
        end

        local Random_String = "TEXT_STORY_MORALE_DISPLAY_EVENT_RANDOM_SWING_NEGATIVE"

        if not Is_Bad then
            Random_String = "TEXT_STORY_MORALE_DISPLAY_EVENT_RANDOM_SWING_POSITIVE"
        end

        Modify_Morale({Name = "Random Morale Change", Value = Morale_Swing, Subtract = Is_Bad, String = Random_String})
    end
end

function Handle_Planet_Production(Current_Morale_Entry)

    if Current_Morale_Entry == nil or type(Current_Morale_Entry) ~= "table" or tableLength(Current_Morale_Entry) == 0 then
        return
    end

    local Neutral = Find_Player("NEUTRAL")

    if not TestValid(Neutral) then
        return
    end

    for _, entry in ipairs(Morale_Levels) do
        
        local level_planet = FindPlanet(entry.Name)

        if TestValid(level_planet) then

            --DebugMessage("%s -- Entry: %s, Current Morale: %s, Planet Owner: %s", tostring(Script), tostring(entry.Name), tostring(Current_Morale_Entry.Name), tostring(level_planet.Get_Owner()))

            if entry.Name == Current_Morale_Entry.Name then

                if level_planet.Get_Owner() ~= Global_Values.Player then
                    level_planet.Change_Owner(Global_Values.Player)
                end
            else
                if level_planet.Get_Owner() ~= Neutral then
                    level_planet.Change_Owner(Neutral)
                end
            end
        end
    end
end

function Get_Morale_Level()
    local morale_level = nil

    for _, level in ipairs(Morale_Levels) do
        local min_val = level.Range[1]
        local max_val = level.Range[2]

        if Morale_Value_Status.Current >= min_val and Morale_Value_Status.Current <= max_val then
            return level
        end
    end

    local closest_level = nil
    local closest_distance = math.huge

    for _, level in ipairs(Morale_Levels) do
        local min_val = level.Range[1]
        local max_val = level.Range[2]

        local distance = 0
        if Morale_Value_Status.Current < min_val then
            distance = min_val - Morale_Value_Status.Current
        elseif Morale_Value_Status.Current > max_val then
            distance = Morale_Value_Status.Current - max_val
        end

        if distance < closest_distance then
            closest_distance = distance
            closest_level = level
        end
    end

    return closest_level
end

function Check_Hero_Status()
    for hero, status in pairs(hero_status_table) do

        local Current_Status = EvaluatePerception(status.Equation, Global_Values.Player)

        DebugMessage("%s -- Current Status for Hero: %s: %s, Last Known Status: %s", tostring(Script), tostring(hero), tostring(Current_Status), tostring(status.Current_Status))

        if type(Current_Status) == "number" then
            if (Current_Status == 0) and status.Current_Status == true then -- if perception returns 0 (not alive) and we last knew they were alive, we can assume they are dead

                DebugMessage("%s -- Hero %s has Died, Owner: %s", tostring(Script), tostring(hero), tostring(status.Owner))

                if status.Owner ~= nil then

                    hero_status_table[hero].Current_Status = false

                    if status.Owner ~= Global_Values.Player then -- if the owner of the hero was not the player, we killed one
                        Set_Next_State("Hero_Killed")
                    else -- if the hero that was killed was ours
                        Set_Next_State("Hero_Lost")
                    end
                end
            end

            if (Current_Status == 1) then

                hero_status_table[hero].Current_Status = true

                if status.Object == nil or (not TestValid(status.Object)) then

                    local hero_object = Find_First_Object(hero)

                    if TestValid(hero_object) then
                        hero_status_table[hero].Object = hero_object
                        hero_status_table[hero].Owner = hero_object.Get_Owner()
                    end

                end
            end
        end
    end
end

function Planet_Morale_Updater()
    for planet_name, planet_entry in pairs(Planet_Morale_Table) do
        local planet_object = planet_entry.Object

        if TestValid(planet_object) then

            local new_owner = planet_object.Get_Owner()
            if new_owner ~= nil and planet_object.Get_Owner() ~= planet_entry.Owner then
                planet_entry.Last_Owner = planet_entry.Owner
                planet_entry.Owner = planet_object.Get_Owner()

                planet_entry.Morale = 100
                planet_entry.Last_Morale = 100
                planet_entry.When_Morale_Last_Changed = Get_Current_Week()
            end
        end
    end
end

function Is_Player_On_Last_Planet()
    local All_Planets = Planet_Table:Return_All_Keys()

    local Owned_Planets = 0

    for _, planet_name in pairs(All_Planets) do
        local Planet = FindPlanet(planet_name)

        if TestValid(Planet) then
            if Planet.Get_Owner() == Global_Values.Player then
                Owned_Planets = Owned_Planets + 1
            end
        end
    end

    return Owned_Planets > 1
end

function Low_Planet_Morale()

    DebugMessage("%s -- Low Morale Active", tostring(Script))

    if Morale_Value_Status.Targeted_Planet == nil or Morale_Value_Status.Targeted_Planet.Get_Owner() ~= Global_Values.Player then
        Morale_Value_Status.Targeted_Planet = Find_First_Loss_Planet()
    end
            
    if Morale_Value_Status.Targeted_Planet == nil then
        return
    end

    DebugMessage("%s -- Targeted Planet: %s", tostring(Script), tostring(Morale_Value_Status.Targeted_Planet))

    local target_planet_morale = Get_Planet_Morale(Morale_Value_Status.Targeted_Planet)

    if target_planet_morale == nil then
        return
    end

    DebugMessage("%s -- Targeted Planet Morale", tostring(Script))

    PrintTable(target_planet_morale)

    DebugMessage("%s -- %s Last Morale Update: %s, Current Week: %s", tostring(Script), tostring(Morale_Value_Status.Targeted_Planet), tostring(target_planet_morale.When_Morale_Last_Changed), tostring(Get_Current_Week()))

    if target_planet_morale.When_Morale_Last_Changed < Get_Current_Week() then

        local Modifier_Entry = Modifiers:Get_Modifiers(Global_Values.Player)

        if Modifier_Entry ~= nil then
            Modify_Planet_Morale(Morale_Value_Status.Targeted_Planet, Modifier_Entry.Yearly_Planetary_Morale_Loss)
        end       
    end

end

function High_Planet_Morale()

    --DebugMessage("%s -- High Planet Morale", tostring(Script))

    for planet_name, planet_entry in pairs(Planet_Morale_Table) do
        local planet_owner = planet_entry.Owner

        --DebugMessage("%s -- Planet Name: %s, Owner: %s", tostring(Script), tostring(planet_name), tostring(planet_owner.Get_Faction_Name()))

        if planet_owner == Global_Values.Player then
            Modify_Planet_Morale(planet_entry.Object, 5)
        end
    end
end

function Modify_Morale(event_table)

    if Global_Values.Plot == nil then
        return
    end

    if event_table == nil then
        return
    end

    if type(event_table) ~= "table" then
        DebugMessage("%s -- Morale Value is NOT a valid Table", tostring(Script))
        return
    end

    local Morale_Value = event_table.Value

    local bad = event_table.Subtract

    DebugMessage("%s -- Event Morale Value: %s, Subtract: %s, Event Name: %s", tostring(Script), tostring(Morale_Value), tostring(bad), tostring(event_table.Name))

    if not bad then
        DebugMessage("%s -- Applying Morale Gain Multiplier", tostring(Script))

        local Player_Modifiers_Entry = Modifiers:Get_Modifiers(Global_Values.Player)

        DebugMessage("%s -- %s Modifiers Entry: %s", tostring(Script), tostring(Global_Values.Player), tostring(Player_Modifiers_Entry))

        if Player_Modifiers_Entry ~= nil then

            Morale_Value = tonumber(Dirty_Floor(Morale_Value * Player_Modifiers_Entry.Morale_Gain_Multiplier))

            if type(Morale_Value) ~= "number" or Morale_Value < 1 then
                Morale_Value = event_table.Value
            end
        end
    end

    if bad then
        Morale_Value = Morale_Value * -1
    end

    local Next_Morale_Level = Morale_Value_Status.Current + Morale_Value

    local Fake_Morale_Type = Find_Object_Type(tostring(abs(Morale_Value)))

    if Fake_Morale_Type == nil then
        DebugMessage("%s -- Could not Find Fake_Morale_Type, was looking for: %s", tostring(Script), tostring(abs(Morale_Value)))
        return
    end

    Show_Screen_Text(event_table.String, Fake_Morale_Type, 5, nil, true)

    DebugMessage("%s -- Next Morale Value: %s", tostring(Script), tostring(Next_Morale_Level))

    if Next_Morale_Level < 0 then
        Next_Morale_Level = 0
    elseif Next_Morale_Level > 100 then
        Next_Morale_Level = 100
    end

    DebugMessage("%s -- Final Morale Value: %s", tostring(Script), tostring(Next_Morale_Level))

    if Next_Morale_Level == nil or type(Next_Morale_Level) ~= "number" then
        return
    end

    Morale_Event_Table:Set_Recent_Event(event_table)

    Morale_Value_Status.Last = Morale_Value_Status.Current

    Morale_Value_Status.Current = Next_Morale_Level

end

function Get_Morale_Influence()
    local State = Get_Current_State()

    local Morale_Values = Morale_Event_Table.Events[State]

    DebugMessage("%s -- Morale Value for State %s", tostring(Script), tostring(State))

    if Morale_Values == nil then
        return
    end

    PrintTable(Morale_Values)

    if type(Morale_Values) == "table" then
        if Morale_Values.KD_Influence == true then
            local New_Morale_Value = Morale_Kill_Ratio_Influence(Morale_Values.Value, Morale_Values.Subtract)

            return {Value = New_Morale_Value, Subtract = Morale_Values.Subtract, Name = Morale_Values.Name, String = Morale_Values.String}
        else
            return Morale_Values
        end
    else
        return {Value = 0, Subtract = false, Name = "No Entry"}
    end
end

function Morale_Kill_Ratio_Influence(Base_Morale, is_loss)

    if is_loss ~= true then
        is_loss = false
    end

    if type(Base_Morale) ~= "number" then
        return 0
    end

    local Kill_Ratio = GlobalValue.Get("Morale_Kill_Ratio")

    DebugMessage("%s -- Kill Ratio: %s", tostring(Script), tostring(Kill_Ratio))

    if Kill_Ratio == nil then
        return Base_Morale
    end

    if Kill_Ratio <= 0 then -- if this is true we didnt get the proper kill ratio
        return Base_Morale
    end

    local Nearest_Kill_Ratio_Morale_Gain = 0

    local Kill_Ratio_Table = UNSC_Kill_Ratio_Table

    if Global_Values.Player == Find_Player("EMPIRE") then
        Kill_Ratio_Table = COVN_Kill_Ratio_Table
    end

    for morale_gain, ratio in pairs(Kill_Ratio_Table) do
        if Kill_Ratio >= ratio then
            Nearest_Kill_Ratio_Morale_Gain = morale_gain
        end
    end

    DebugMessage("%s -- Morale Gain for KD %s: %s", tostring(Script), tostring(Kill_Ratio), tostring(Nearest_Kill_Ratio_Morale_Gain))

    local Final_Morale_Gain = Nearest_Kill_Ratio_Morale_Gain

    local Max_Morale_Gain = tableLength(Kill_Ratio_Table)

    if is_loss then
        Final_Morale_Gain = Max_Morale_Gain - Nearest_Kill_Ratio_Morale_Gain
    end
    
    if Final_Morale_Gain > Max_Morale_Gain then
        Final_Morale_Gain = Max_Morale_Gain
    elseif Final_Morale_Gain < 0 then
        Final_Morale_Gain = 0
    end

    DebugMessage("%s -- Final Morale Gain: %s", tostring(Script), tostring(Final_Morale_Gain))

    return Final_Morale_Gain
end

function Show_Screen_Text(text, var, time_to_show, color, teletype) -- inspired by the Thrawns Revenge Team but slightly modified to fit our purpose
    
    if Global_Values.Plot == nil then
        return
    end

    local text_event = Global_Values.Plot.Get_Event("Show_Screen_Text")

    if text_event == nil then
        return
    end

    if type(text) ~= "string" then
        return
    end

    local colorstring = ""

    if color == nil then
        color = {r = 255, g = 255, b = 255}
    end
    
    if color then
        colorstring = color.r .. " " .. color.g .. " " .. color.b 
    end

    local use_teletype = 1
    if teletype == false then
        use_teletype = 0
    end

    if var == nil then
        var = ""
    end

    DebugMessage("%s -- Running Screen Text for Output: %s", tostring(Script), tostring(text))

    text_event.Set_Reward_Parameter(0, text)
    text_event.Set_Reward_Parameter(1,tostring(time_to_show)) -- time in seconds
    text_event.Set_Reward_Parameter(2, var) -- parameter we dont care about
    text_event.Set_Reward_Parameter(3, "")
    text_event.Set_Reward_Parameter(4, use_teletype) -- whether or not the text is slowly typed out or is just shown
    text_event.Set_Reward_Parameter(5, colorstring) -- for color
    text_event.Set_Reward_Parameter(6, "System")
    Story_Event("SHOW_SCREEN_TEXT")
end

function Build_Neighbor_Table()

    local neighbor_table = {}

    local All_Planets = Planet_Table:Return_All_Keys()

    for _, planet_name in pairs(All_Planets) do

        local planet = FindPlanet(planet_name)

        if TestValid(planet) then

            if neighbor_table[planet_name] == nil then
                neighbor_table[planet_name] = {} 
                neighbor_table[planet_name].Object = planet
                neighbor_table[planet_name].Neighbors = {}
            end

            for _, second_planet_name in pairs(All_Planets) do

                local second_planet = FindPlanet(second_planet_name)

                if second_planet ~= planet and TestValid(second_planet) then
                    if table.getn(Find_Path(Global_Values.Player, planet, second_planet)) == 2 then
                        table.insert(neighbor_table[planet_name].Neighbors, second_planet)
                    end
                end
            end
        end
    end

    return neighbor_table
end

function Build_Morale_Table()
    local morale_table = {}

    for _, planet_name in pairs(Planet_Table:Return_All_Keys()) do

        local planet = FindPlanet(planet_name)

        if TestValid(planet) then
            morale_table[planet_name] = {}

            local planet_entry = morale_table[planet_name]

            planet_entry.Object = planet
            planet_entry.Owner = planet.Get_Owner()
            planet_entry.Last_Owner = planet.Get_Owner()
            planet_entry.Morale = 100
            planet_entry.Last_Morale = 100
            planet_entry.When_Morale_Last_Changed = 0
        end

    end
        
    return morale_table
end

function Reset_Morale_Entries()
    if Planet_Morale_Table == nil then
        return nil
    end

    for planet_name, entry in pairs(Planet_Morale_Table) do
        
        if TestValid(entry.Object) then
            if entry.Object.Get_Owner() ~= entry.Owner then
                entry.Morale = 100
                entry.Last_Morale = 100
                entry.When_Morale_Last_Changed = Get_Current_Week()
                entry.Last_Owner = entry.Owner
                entry.Owner = entry.Object.Get_Owner()
            end
        end
    end
end

function Get_Planet_Morale(planet)
    if Planet_Morale_Table == nil then
        return nil
    end

    if planet == nil then
        return nil
    end

    if planet.Get_Type == nil then
        return nil
    end

    local planet_name = planet.Get_Type().Get_Name()

    local morale_entry = Planet_Morale_Table[planet_name]

    if morale_entry == nil then
        return nil
    end

    return morale_entry
end

function Modify_Planet_Morale(planet, amount)

    if amount == nil then
        return
    end

    local planet_morale = Get_Planet_Morale(planet)

    if planet_morale == nil then
        return
    end

    local New_Morale = planet_morale.Morale + amount

    if New_Morale > 100 then
        New_Morale = 100
    elseif New_Morale < 0 then
        New_Morale = 0
    end
    
    if New_Morale == 0 and planet.Get_Owner() == Global_Values.Player then

        local new_faction = nil

        if StringCompare(Global_Values.Player.Get_Faction_Name(), "Rebel") then
            new_faction = Find_Player("TERRORISTS")
        else
            new_faction = Find_Player("Swords")
        end

        if TestValid(new_faction) then
            planet.Change_Owner(new_faction)
        end

        return
    end

    planet_morale.Last_Morale = planet_morale.Morale

    planet_morale.Morale = New_Morale

    planet_morale.When_Morale_Last_Changed = Get_Current_Week()
end

function Remove_Planet_Morale(planet)

    if not TestValid(planet) then
        return
    end

    local planet_name = planet.Get_Type().Get_Name()

    Planet_Morale_Table[planet_name] = nil

end

function Find_Neighbors(planet)

    if Planetary_Pathing_Table == nil then
        return nil
    end

    if planet == nil then
        return nil
    end

    if planet.Get_Type().Get_Name == nil then
        return nil
    end

    local planet_name = planet.Get_Type().Get_Name()

    if Planetary_Pathing_Table[planet_name] == nil then
        return nil
    end

    return Planetary_Pathing_Table[planet_name].Neighbors

end

function Count_Enemy_Neighbors(planet)

    if planet == nil then
        return 0
    end

    DebugMessage("%s -- Counting Neighbors for %s", tostring(Script), tostring(planet))

    local planet_neighbors = Find_Neighbors(planet)

    PrintTable(planet_neighbors)

    local enemy_neighbors = 0

    if planet_neighbors == nil then
        return enemy_neighbors
    end

    for _, neighbor in pairs(planet_neighbors) do
        DebugMessage("%s -- Found Neighbor: %s",tostring(Script), tostring(neighbor))
        if neighbor.Get_Owner() ~= planet.Get_Owner() and neighbor.Get_Owner() ~= Find_Player("NEUTRAL") then
            DebugMessage("%s -- Neighbor is Enemy", tostring(Script))
            enemy_neighbors = enemy_neighbors + 1
        end
    end

    return enemy_neighbors
end

function Find_First_Loss_Planet()

    local player_owned_planets = {}

    for _, planet_name in pairs(Planet_Table:Return_All_Keys()) do

        local planet = FindPlanet(planet_name)

        DebugMessage("%s -- Checking if %s is Owned by Player", tostring(Script), tostring(planet))

        if TestValid(planet) then
            if planet.Get_Owner() == Global_Values.Player then
                DebugMessage("%s -- %s is Owned by the Player", tostring(Script), tostring(planet))
                table.insert(player_owned_planets, planet)
            end
        end
    end

    local highest_enemy_neighbors = 0

    local highest_enemy_neighbors_planet = nil
    
    for _, planet in pairs(player_owned_planets) do
        local enemy_neighbors = Count_Enemy_Neighbors(planet)

        DebugMessage("%s -- Highest Enemy Neighbors %s for Planet: %s, Enemy Neighbors for Planet %s: %s", tostring(Script), tostring(highest_enemy_neighbors), tostring(highest_enemy_neighbors_planet), tostring(planet),tostring(enemy_neighbors))

        if enemy_neighbors > highest_enemy_neighbors then
            highest_enemy_neighbors = enemy_neighbors
            highest_enemy_neighbors_planet = planet
        end
    end

    DebugMessage("%s -- Planet %s has the Highest amount of Enemy Neighbors", tostring(Script), tostring(highest_enemy_neighbors_planet))

    return highest_enemy_neighbors_planet
end

function Default_Event_Function(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Flush(message)
    if message == OnEnter then

        if Global_Values.Plot == nil then
            Set_Next_State("Morale_Level_Init")
        else
            Set_Next_State("Morale_Update")
        end
    end
end

function Lost_Battle(message)
    if message == OnEnter then

        Battle_Info:Increase_Loss_Streak()

        if customModulo(Battle_Info.Loss_Streak, 3) == 0 then
            Set_Next_State("Morale_Lost_Battle_Major")

            return
        end

        Modify_Morale(Get_Morale_Influence())
        
        Set_Next_State("Flush")
    end
end

function Lost_Battle_Major(message)
    if message == OnEnter then

        Modify_Morale(Get_Morale_Influence())

        DebugMessage("%s -- Player On Loss Streak", tostring(Script))

        Set_Next_State("Flush")
    end
end

function Won_Battle(message)
    if message == OnEnter then

        Battle_Info:Increase_Win_Streak()

        local Faction_Modifiers = Modifiers:Get_Modifiers(Global_Values.Player)

        if customModulo(Battle_Info.Win_Streak, Faction_Modifiers.Battle_Win_Streak_Requirement) == 0 then
            Set_Next_State("Morale_Won_Battle_Major")

            return
        end

        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Won_Battle_Major(message)
    if message == OnEnter then

        Modify_Morale(Get_Morale_Influence())

        DebugMessage("%s -- Player On Win Streak", tostring(Script))

        Set_Next_State("Flush")
    end
end
