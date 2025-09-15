require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PGStoryMode")
require("PlanetNameTable")

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

    morale_event_table = {
        ["Morale_Lost_Battle"] = {Name = "Battle Lost", Value = 1, Subtract = true, KD_Influence = true},
        ["Morale_Lost_Battle_Major"] = {Name = "Battle Loss Streak", Value = 5, Subtract = true, KD_Influence = true},
        ["Morale_Won_Battle"] = {Name = "Battle Won", Value = 1, Subtract = false, KD_Influence = true},
        ["Morale_Won_Battle_Major"] = {Name = "Battle Win Streak", Value = 3, Subtract = false, KD_Influence = true},
        ["Morale_Construction_Event_Minor"] = {Name = "Minor Construction", Value = 1, Subtract = false},
        ["Morale_Construction_Event"] = {Name = "Construction", Value = 2, Subtract = false},
        ["Morale_Construction_Event_Major"] = {Name = "Construction Major", Value = 3, Subtract = false},
        ["Hero_Lost"] = {Name = "Major Hero Lost", Value = 8, Subtract = true},
        ["Hero_Killed"] = {Name = "Major Hero Killed", Value = 3, Subtract = false},
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

    planets_with_no_morale = {}

    global_morale_level = 100

    global_last_morale_level = 100

    win_streak = 0

    loss_streak = 0

    player = nil

    plot = nil

    display_event = nil

    morale_string = {}

    Planetary_Pathing_Table = nil

    Planet_Morale_Table = nil

    selected_planet = nil

    targeted_planet = nil

    recent_event = nil

    next_random_swing = 3

    Difficulty = ""

    enemy = nil

    invalid_planet_names = {}

    Planet_List = {
        All = {},
        Player = {}
    }

end

function Init_Morale_System(message)
    if message == OnEnter then

        player = Find_Human_Player()

        for hero, status in pairs(hero_status_table) do
            if EvaluatePerception(status.Equation, player) == 1 then
                hero_status_table[hero].Current_Status = true
                
                local hero_object = Find_First_Object(hero)

                if TestValid(hero_object) then
                    hero_status_table[hero].Object = hero_object
                    hero_status_table[hero].Owner = hero_object.Get_Owner()
                end

            end
        end

        plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Morale_System.xml")

        if StringCompare(player.Get_Faction_Name(), "Rebel") then
            Story_Event("Morale_Display_UNSC")

            display_event = plot.Get_Event("Morale_Display_UNSC")

            morale_string.Level = "TEXT_STORY_MORALE_DISPLAY_BODY_UNSC_VALUES"
        else
            Story_Event("Morale_Display_COVN")

            morale_string.Level = "TEXT_STORY_MORALE_DISPLAY_BODY_COVN_VALUES"

            display_event = plot.Get_Event("Morale_Display_COVN")
        end

        morale_string.Target_Planet = "TEXT_STORY_MORALE_DISPLAY_TARGET_PLANET"

        morale_string.Recent_Event = {}

        morale_string.Recent_Event.Bad = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_BAD"

        morale_string.Recent_Event.Good = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_GOOD"

        morale_string.Win_Streak = "TEXT_STORY_MORALE_DISPLAY_WIN_STREAK"

        morale_string.Loss_Streak = "TEXT_STORY_MORALE_DISPLAY_LOSS_STREAK"

        GlobalValue.Set("Morale_Active", 1)

        if StringCompare(player.Get_Faction_Name(), "Empire") then
            enemy = Find_Player("Rebel")
        else
            enemy = Find_Player("Empire")
        end

        DebugMessage("%s -- Enemy Player: %s", tostring(Script), tostring(enemy))

        if TestValid(enemy) then
            Difficulty = enemy.Get_Difficulty()
        end

        DebugMessage("%s -- Current Difficulty: %s", tostring(Script), tostring(Difficulty))

        if StringCompare(Difficulty, "Normal") then
            global_morale_level = 75

            global_last_morale_level = 75
        elseif StringCompare(Difficulty, "Hard") then
            global_morale_level = 45

            global_last_morale_level = 45
        end

    
        local planets = FindPlanet.Get_All_Planets()

        for _, entry in ipairs(Morale_Levels) do

            invalid_planet_names[string.upper(entry.Name)] = true

            --DebugMessage("%s -- Adding %s to invalid_planet_names: %s", tostring(Script), tostring(string.upper(entry.Name)), tostring(invalid_planet_names[string.upper(entry.Name)]))
        end

        for i,planet in ipairs(planets) do

            local planet_name = planet.Get_Type().Get_Name()

            local is_planet_invalid = invalid_planet_names[string.upper(planet_name)]

            --DebugMessage("%s -- Planet: %s, Is Invalid: %s", tostring(Script), tostring(string.upper(planet_name)), tostring(invalid_planet_names[string.upper(planet_name)]))

            if is_planet_invalid ~= true then

                table.insert(Planet_List.All, planet)

                local select_event = plot.Get_Event("SELECT_"..planet_name)

                if select_event ~= nil then
                    select_event.Set_Reward_Parameter(1, player.Get_Faction_Name())
                end
            end
        end

        Planetary_Pathing_Table = Build_Neighbor_Table()

        Planet_Morale_Table = Build_Morale_Table()

        Set_Next_State("Flush")
    end
end

function Morale_System_Update(message)
    if message == OnUpdate then

        DebugMessage("%s -- Current Game Mode: %s", tostring(Script), tostring(Get_Game_Mode()))

        DebugMessage("%s -- Galactic Time: %s, Current Week: %s", tostring(Script), tostring(GetCurrentTime.Galactic_Time()), tostring(Get_Current_Week()))

        DebugMessage("%s -- Win Streak: %s, Loss Streak: %s", tostring(Script), tostring(win_streak), tostring(loss_streak))

        DebugMessage("%s -- Current Morale Level: %s", tostring(Script), tostring(global_morale_level))

        Check_Hero_Status()

        Reset_Morale_Entries()

        selected_planet = Get_Selected_Planet()

        if global_morale_level > 100 then
            global_morale_level = 100
        elseif global_morale_level < 0 then
            global_morale_level = 0
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

        DebugMessage("%s -- Current Morale Status: %s", tostring(Script), tostring(Current_Morale_Status))

        if display_event ~= nil and Current_Morale_Status ~= nil then

            display_event.Clear_Dialog_Text()

            display_event.Add_Dialog_Text(morale_string.Level, Build_Morale_Display_String(Current_Morale_Entry))

            display_event.Add_Dialog_Text(" ")

            display_event.Add_Dialog_Text(morale_string.Description)

            display_event.Add_Dialog_Text(" ")

            display_event.Add_Dialog_Text(morale_string.Battle_Bonus)

            display_event.Add_Dialog_Text(" ")

            display_event.Add_Dialog_Text(morale_string.Production_Bonus)

            display_event.Add_Dialog_Text(" ")

            if recent_event ~= nil then

                local Recent_Event_String = morale_string.Recent_Event.Good

                if recent_event.Subtract then
                    Recent_Event_String = morale_string.Recent_Event.Bad
                end

                display_event.Add_Dialog_Text(Recent_Event_String, recent_event.Name, recent_event.Value)

                display_event.Add_Dialog_Text(" ")
            end

            if win_streak > 0 then
                display_event.Add_Dialog_Text(morale_string.Win_Streak, tostring(win_streak))

                display_event.Add_Dialog_Text(" ")
            end

            if loss_streak > 0 then
                display_event.Add_Dialog_Text(morale_string.Loss_Streak, tostring(loss_streak))

                display_event.Add_Dialog_Text(" ")
            end

            display_event.Add_Dialog_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_LEVELS")

            display_event.Add_Dialog_Text(" ")

            for _, entry in ipairs(Morale_Levels) do
                display_event.Add_Dialog_Text(entry.Display_Name .. "_RANGE", tostring(entry.Range[1]), tostring(entry.Range[2]))
            end
            
        end

        --DebugMessage("%s -- End of Main Event Display", tostring(Script))

        if Current_Morale_Entry.Punishment then
            Low_Planet_Morale()

            display_event.Add_Dialog_Text(" ")

            display_event.Add_Dialog_Text(morale_string.Target_Planet, Readable_Planet_Name(targeted_planet))

            Selected_Planet_Morale_Display()
        else
            High_Planet_Morale()
        end
    
    end
end

function Random_Morale_Swing()

    local Current_Week = Get_Current_Week()

    if next_random_swing <= Current_Week then
        next_random_swing = Current_Week + 2

        local Bad_Chance = EvenMoreRandom(40,60,1) / 100

        local Is_Bad = Return_Chance(Bad_Chance, 1)

        local Morale_Swing = EvenMoreRandom(0,2,15)

        if Morale_Swing == 0 then
            return
        end

        Modify_Morale({Name = "Random Morale Change", Value = Morale_Swing, Subtract = Is_Bad})
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

            DebugMessage("%s -- Entry: %s, Current Morale: %s, Planet Owner: %s", tostring(Script), tostring(entry.Name), tostring(Current_Morale_Entry.Name), tostring(level_planet.Get_Owner()))

            if entry.Name == Current_Morale_Entry.Name then

                if level_planet.Get_Owner() ~= player then
                    level_planet.Change_Owner(player)
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

        if global_morale_level >= min_val and global_morale_level <= max_val then
            return level
        end
    end

    local closest_level = nil
    local closest_distance = math.huge

    for _, level in ipairs(Morale_Levels) do
        local min_val = level.Range[1]
        local max_val = level.Range[2]

        local distance = 0
        if global_morale_level < min_val then
            distance = min_val - global_morale_level
        elseif global_morale_level > max_val then
            distance = global_morale_level - max_val
        end

        if distance < closest_distance then
            closest_distance = distance
            closest_level = level
        end
    end

    return closest_level
end

function Selected_Planet_Morale_Display()

    DebugMessage("%s -- Checking Selected Planet", tostring(Script))

    if selected_planet ~= nil then
        local selected_planet_morale_entry = Get_Planet_Morale(selected_planet)

        if selected_planet_morale_entry ~= nil then

            local planet_name = Get_Cus_Name(selected_planet.Get_Type().Get_Name())

            local morale_name = "Morale Index"

            if StringCompare(player.Get_Faction_Name(), "Empire") then
                morale_name = "Religious Resolve Index"
            end

            local selected_planet_morale_string = planet_name .. "'s " .. morale_name .. ": " .. tostring(selected_planet_morale_entry.Morale) .. "%, Last " .. morale_name .. ": " .. tostring(selected_planet_morale_entry.Last_Morale) .. "%"

            --Show_Screen_Text(selected_planet_morale_string, nil, 3, nil, false)
        end
    end
end

function Readable_Planet_Name(planet)
    if planet == nil then
        return ""
    end

    if planet.Get_Type == nil then
        return ""
    end

    local planet_name = planet.Get_Type().Get_Name()

    if Has_Custom_Name(planet_name) then
        return Get_Cus_Name(planet_name)
    else
        return Capital_First_Letter(planet_name)
    end
end

function Get_Selected_Planet()

    local player = Find_Human_Player()

    for _,planet in pairs(Planet_List.All) do

        local flag_name = "PLAYER_SELECTED_" .. string.upper(planet.Get_Type().Get_Name())
        --DebugMessage("Checking Planet: %s", flag_name)
        if Check_Story_Flag(player, flag_name, nil, true) then
            DebugMessage("Found Selected Planet: %s", planet.Get_Type().Get_Name())
            return planet
        end
    end

    return nil

end

function Check_Hero_Status()
    for hero, status in pairs(hero_status_table) do

        local Current_Status = EvaluatePerception(status.Equation, player)

        DebugMessage("%s -- Current Status for Hero: %s: %s, Last Known Status: %s", tostring(Script), tostring(hero), tostring(Current_Status), tostring(status.Current_Status))

        if type(Current_Status) == "number" then
            if (Current_Status == 0) and status.Current_Status == true then -- if perception returns 0 (not alive) and we last knew they were alive, we can assume they are dead

                DebugMessage("%s -- Hero %s has Died, Owner: %s", tostring(Script), tostring(hero), tostring(status.Owner))

                if status.Owner ~= nil then

                    hero_status_table[hero].Current_Status = false

                    if status.Owner ~= player then -- if the owner of the hero was not the player, we killed one
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

function Low_Planet_Morale()

    DebugMessage("%s -- Low Morale Active", tostring(Script))

    if targeted_planet == nil or targeted_planet.Get_Owner() ~= player then
        targeted_planet = Find_First_Loss_Planet()
    end
            
    if targeted_planet == nil then
        return
    end

    DebugMessage("%s -- Targeted Planet: %s", tostring(Script), tostring(targeted_planet))

    local target_planet_morale = Get_Planet_Morale(targeted_planet)

    if target_planet_morale == nil then
        return
    end

    DebugMessage("%s -- Targeted Planet Morale", tostring(Script))

    PrintTable(target_planet_morale)

    DebugMessage("%s -- %s Last Morale Update: %s, Current Week: %s", tostring(Script), tostring(targeted_planet), tostring(target_planet_morale.When_Morale_Last_Changed), tostring(Get_Current_Week()))

    if target_planet_morale.When_Morale_Last_Changed < Get_Current_Week() then
        Modify_Planet_Morale(targeted_planet, -10)
    end

end

function High_Planet_Morale()

    --DebugMessage("%s -- High Planet Morale", tostring(Script))

    for planet_name, planet_entry in pairs(Planet_Morale_Table) do
        local planet_owner = planet_entry.Owner

        --DebugMessage("%s -- Planet Name: %s, Owner: %s", tostring(Script), tostring(planet_name), tostring(planet_owner.Get_Faction_Name()))

        if planet_owner == player then
            Modify_Planet_Morale(planet_entry.Object, 5)
        end
    end
end

function Modify_Morale(event_table)

    if plot == nil then
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

    local Next_Morale_Level = global_morale_level + Morale_Value

    local Event_String = "Event " .. event_table.Name .. " has "

    if bad then
        Next_Morale_Level = global_morale_level - Morale_Value

        Event_String = Event_String .. "Decreased Morale by: " .. tostring(Morale_Value)

        Show_Screen_Text(Event_String, nil, 6, nil, true)
    else

        Event_String = Event_String .. "Increased Morale by: " .. tostring(Morale_Value)

        Show_Screen_Text(Event_String, nil, 6, nil, true)
    end

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

    Set_Recent_Event(event_table)

    global_last_morale_level = global_morale_level

    global_morale_level = Next_Morale_Level

end

function Get_Morale_Influence()
    local State = Get_Current_State()

    local Morale_Values = morale_event_table[State]

    DebugMessage("%s -- Morale Value for State %s", tostring(Script), tostring(State))

    if Morale_Values == nil then
        return
    end

    PrintTable(Morale_Values)

    if type(Morale_Values) == "table" then
        if Morale_Values.KD_Influence == true then
            local New_Morale_Value = Morale_Kill_Ratio_Influence(Morale_Values.Value, Morale_Values.Subtract)

            return {Value = New_Morale_Value, Subtract = Morale_Values.Subtract, Name = Morale_Values.Name}
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

    if player == Find_Player("EMPIRE") then
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

function Build_Morale_Display_String(Morale_Entry)

    if Morale_Entry == nil or type(Morale_Entry) ~= "table" then
        return ""
    end

    local final_string = ""

    final_string = final_string .. Morale_Entry.Name .. " " ..tostring(global_morale_level) .. tostring("%")

    return final_string
end

function Show_Screen_Text(text, var, time_to_show, color, teletype) -- inspired by the Thrawns Revenge Team but slightly modified to fit our purpose
    local text_event = plot.Get_Event("Show_Screen_Text")

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

    for _, planet in pairs(Planet_List.All) do

        if Is_Valid_Planet(planet) then

            local planet_name = planet.Get_Type().Get_Name()

            if neighbor_table[planet_name] == nil then
                neighbor_table[planet_name] = {} 
                neighbor_table[planet_name].Object = planet
                neighbor_table[planet_name].Neighbors = {}
            end

            for _, second_planet in pairs(Planet_List.All) do
                if second_planet ~= planet and Is_Valid_Planet(second_planet) then
                    if table.getn(Find_Path(player, planet, second_planet)) == 2 then
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

    for _, planet in pairs(Planet_List.All) do
        local planet_name = planet.Get_Type().Get_Name()

        morale_table[planet_name] = {}

        local planet_entry = morale_table[planet_name]

        planet_entry.Object = planet
        planet_entry.Owner = planet.Get_Owner()
        planet_entry.Last_Owner = planet.Get_Owner()
        planet_entry.Morale = 100
        planet_entry.Last_Morale = 100
        planet_entry.When_Morale_Last_Changed = 0
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
    
    if New_Morale == 0 and planet.Get_Owner() == player then

        local new_faction = nil

        if StringCompare(player.Get_Faction_Name(), "Rebel") then
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
    local planet_neighbors = Find_Neighbors(planet)

    local enemy_neighbors = 0

    if planet_neighbors == nil then
        return enemy_neighbors
    end

    for _, neighbor in pairs(planet_neighbors) do
        if neighbor.Get_Owner() ~= planet.Get_Owner() and neighbor.Get_Owner() ~= Find_Player("NEUTRAL") then
            enemy_neighbors = enemy_neighbors + 1
        end
    end

    return enemy_neighbors
end

function Find_First_Loss_Planet()

    local player_owned_planets = {}

    for _, planet in pairs(Planet_List.All) do
        if planet.Get_Owner() == player and Is_Valid_Planet(planet) then
            table.insert(player_owned_planets, planet)
        end
    end

    local highest_enemy_neighbors = 0

    local highest_enemy_neighbors_planet = nil
    
    for _, planet in pairs(player_owned_planets) do
        local enemy_neighbors = Count_Enemy_Neighbors(planet)

        if enemy_neighbors > highest_enemy_neighbors then
            highest_enemy_neighbors = enemy_neighbors
            highest_enemy_neighbors_planet = planet
        end
    end

    return highest_enemy_neighbors_planet
end

function Is_Valid_Planet(planet)

    if not TestValid(planet) then
        return false
    end

    if invalid_planet_names[string.upper(planet.Get_Type().Get_Name())] ~= true then
        return true
    end

    return false
end

function Set_Recent_Event(event_table)
    recent_event = event_table
end

function Update_Player_Owned_Planets()
    Planet_List.Player = {}

    for _, planet in pairs(Planet_List.All) do
        if planet.Get_Owner() == player then
            table.insert(Planet_List.Player, planet)
        end
    end
end

function Default_Event_Function(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Flush(message)
    if message == OnEnter then

        if plot == nil then
            Set_Next_State("Morale_Level_Init")
        else
            Set_Next_State("Morale_Update")
        end
    end
end

function Lost_Battle(message)
    if message == OnEnter then
        loss_streak = loss_streak + 1

        win_streak = 0

        if customModulo(loss_streak, 3) == 0 then
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

        win_streak = win_streak + 1

        loss_streak = 0

        if customModulo(win_streak, 3) == 0 then
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
