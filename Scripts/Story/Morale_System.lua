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
        Morale_Construction_Event_Minor = Construction_Minor,
        Morale_Construction_Event = Construction,
        Morale_Construction_Event_Major = Construction_Major,
        Hero_Lost = Hero_Lost,
        Hero_Killed = Hero_Killed,
        Flush = Flush,
        Morale_Update = Morale_System_Update,
    }

    morale_event_table = {
        ["Morale_Lost_Battle"] = {Name = "Battle Lost", Value = 1, Subtract = true, KD_Influence = true},
        ["Morale_Lost_Battle_Major"] = {Name = "Battle Loss Streak", Value = 3, Subtract = true, KD_Influence = true},
        ["Morale_Won_Battle"] = {Name = "Battle Won", Value = 1, Subtract = false, KD_Influence = true},
        ["Morale_Won_Battle_Major"] = {Name = "Battle Win Streak", Value = 3, Subtract = false, KD_Influence = true},
        ["Morale_Construction_Event_Minor"] = {Name = "Minor Construction", Value = 1, Subtract = false},
        ["Morale_Construction_Event"] = {Name = "Construction", Value = 2, Subtract = false},
        ["Morale_Construction_Event_Major"] = {Name = "Construction Major", Value = 3, Subtract = false},
        ["Hero_Lost"] = {Name = "Major Hero Lost", Value = 3, Subtract = true},
        ["Hero_Killed"] = {Name = "Major Hero Killed", Value = 3, Subtract = false},
    }

    UNSC_Kill_Ratio_Table = {0.0625, 0.07, 0.1 , 0.16, 0.3} -- the index is the morale gain from the kill ratio at that index

    COVN_Kill_Ratio_Table = {0.3, 0.5, 1, 2, 3}

    Morale_Levels = {
        [15] = "Compromised",
        [35] = "Strained",
        [50] = "Stabilized",
        [75] = "Resolute",
        [90] = "Ascendant",
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

    global_morale_level = 100

    low_morale_threshold = 15

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

        morale_string.Target_Planet = ""

        GlobalValue.Set("Morale_Active", 1)

        local Difficulty = player.Get_Difficulty()

        if Difficulty == "Normal" then
            global_morale_level = 75
        elseif Difficulty == "Hard" then
            global_morale_level = 50
        end

        Planetary_Pathing_Table = Build_Neighbor_Table()

        Planet_Morale_Table = Build_Morale_Table()

        local planets = FindPlanet.Get_All_Planets()

        for i,planet in ipairs(planets) do

            local select_event = plot.Get_Event("SELECT_"..planet.Get_Type().Get_Name())

            select_event.Set_Reward_Parameter(1, player.Get_Faction_Name())

        end

        Set_Next_State("Flush")
    end
end

function Morale_System_Update(message)
    if message == OnUpdate then

        DebugMessage("%s -- Current Game Mode: %s", tostring(Script), tostring(Get_Game_Mode()))

        DebugMessage("%s -- Galactic Time: %s", tostring(Script), tostring(GetCurrentTime.Galactic_Time()))

        DebugMessage("%s -- Win Streak: %s, Loss Streak: %s", tostring(Script), tostring(win_streak), tostring(loss_streak))

        DebugMessage("%s -- Current Morale Level: %s", tostring(Script), tostring(global_morale_level))

        Check_Hero_Status()

        if GlobalValue.Get("Morale_Planet_Owner_Changed") == 1 then
            GlobalValue.Set("Morale_Planet_Owner_Changed", 0)

            Planet_Morale_Updater()
        end

        selected_planet = Get_Selected_Planet()

        local Current_Morale_Status = "Stabilized"

        for level, status in pairs(Morale_Levels) do
            if global_morale_level >= level then
                Current_Morale_Status = status
            end
        end

        GlobalValue.Set("Morale_Status", Current_Morale_Status)

        DebugMessage("%s -- Current Morale Status: %s", tostring(Script), tostring(Current_Morale_Status))

        if display_event ~= nil then

            display_event.Clear_Dialog_Text()

            display_event.Add_Dialog_Text(morale_string.Level, Build_Morale_Display_String())

        end

        if Is_Morale_Too_Low(Current_Morale_Status) then
            Low_Planet_Morale()

            display_event.Add_Dialog_Text(morale_string.Target_Planet, Readable_Planet_Name(targeted_planet))

            Selected_Planet_Morale_Display()
        else
            High_Planet_Morale()
        end
    
    end
end

function Selected_Planet_Morale_Display()
    if selected_planet ~= nil then
        local selected_planet_morale_entry = Get_Planet_Morale(selected_planet)

        if selected_planet_morale_entry ~= nil then

            local planet_name = Get_Cus_Name(selected_planet.Get_Type().Get_Name())

            local morale_name = "Morale Index"

            if StringCompare(player.Get_Faction_Name(), "Empire") then
                morale_name = "Religious Resolve Index"
            end

            local selected_planet_morale_string = planet_name .. "'s " .. morale_name .. ": " .. tostring(selected_planet_morale_entry.Morale) .. "/100, Last " .. morale_name .. ": " .. tostring(selected_planet_morale_entry.Last_Morale) .. "/100"
            
            Show_Screen_Text(selected_planet_morale_string, 3, nil, false)
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

    local planets = FindPlanet.Get_All_Planets()

    for _,planet in pairs(planets) do

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

function Is_Morale_Too_Low(Current_Morale_Level)

    local Low_Morale_Levels = {}

    for level_num, level_string in pairs(Morale_Levels) do
        if level_num <= low_morale_threshold then
            table.insert(Low_Morale_Levels, level_string)
        end
    end

    for _, level in pairs(Low_Morale_Levels) do
        if Current_Morale_Level == level then
            return true
        end
    end

    return false
end

function Low_Planet_Morale()

    if targeted_planet == nil or targeted_planet.Get_Owner() ~= player then
        targeted_planet = Find_First_Loss_Planet()
    end
            
    if targeted_planet == nil then
        return
    end

    local target_planet_morale = Get_Planet_Morale(targeted_planet)

    if target_planet_morale == nil then
        return
    end

    if target_planet_morale.When_Morale_Last_Changed < Get_Current_Week() then
        Modify_Planet_Morale(target_planet, -10)
    end

end

function High_Planet_Morale()
    for planet_name, planet_entry in pairs(Planet_Morale_Table) do
        local planet_owner = planet_entry.Owner

        if planet_owner == player then
            Modify_Planet_Morale(planet_entry.Object, 5)
        end
    end
end

function Modify_Morale(event_table)

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

        Event_String = Event_String .. "Decreased Morale by: " .. tostring(Next_Morale_Level)

        Show_Screen_Text(Event_String, 6, nil, false)
    else

        Event_String = Event_String .. "Increased Morale by: " .. tostring(Next_Morale_Level)

        Show_Screen_Text(Event_String, 6, nil, false)
    end

    DebugMessage("%s -- Next Morale Value: %s", tostring(Script), tostring(Next_Morale_Level))

    if Next_Morale_Level < 0 then
        Next_Morale_Level = 0
    elseif Next_Morale_Level > 100 then
        Next_Morale_Level = 100
    end

    DebugMessage("%s -- Final Morale Value: %s", tostring(Script), tostring(Next_Morale_Level))

    global_morale_level = Next_Morale_Level

end

function Get_Morale_Influence()
    local State = Get_Current_State()

    local Morale_Values = morale_event_table[State]

    DebugMessage("%s -- Morale Value for State %s", tostring(Script), tostring(State))

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

function Build_Morale_Display_String()
    local final_string = ""

    local Current_Morale_Status = "Stabilized"

    for level, status in pairs(Morale_Levels) do
        if global_morale_level >= level then
            Current_Morale_Status = status
        end
    end

    final_string = final_string .. Current_Morale_Status .. "(" .. tostring(global_morale_level) .. "/100)"

    return final_string
end

function Show_Screen_Text(text, time_to_show, color, teletype) -- inspired by the Thrawns Revenge Team but slightly modified to fit our purpose
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

    DebugMessage("%s -- Running Screen Text for Output: %s", tostring(Script), tostring(text))

    text_event.Set_Reward_Parameter(0,text)
    text_event.Set_Reward_Parameter(1,tostring(time_to_show)) -- time in seconds
    text_event.Set_Reward_Parameter(2, "") -- parameter we dont care about
    text_event.Set_Reward_Parameter(3, "")
    text_event.Set_Reward_Parameter(4, use_teletype) -- whether or not the text is slowly typed out or is just shown
    text_event.Set_Reward_Parameter(5, colorstring) -- for color
    Story_Event("SHOW_SCREEN_TEXT")
end

function Build_Neighbor_Table()
    local planets = FindPlanet.Get_All_Planets()

    local neighbor_table = {}

    for _, planet in pairs(planets) do
        for _, second_planet in pairs(planets) do
            if second_planet ~= planet then
                if table.getn(Find_Path(player, planet, second_planet)) == 2 then

                    local planet_name = planet.Get_Type().Get_Name()

                    if neighbor_table[planet_name] == nil then
                        neighbor_table[planet_name] = {} 
                        neighbor_table[planet_name].Object = planet
                        neighbor_table[planet_name].Neighbors = {}
                    end

                    table.insert(neighbor_table[planet_name].Neighbors, second_planet)
                end
            end
        end
    end

    return neighbor_table
end

function Build_Morale_Table()
    local planets = FindPlanet.Get_All_Planets()

    local morale_table = {}

    for _, planet in pairs(planets) do
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

    planet_morale.Last_Morale = planet_morale.Morale

    planet_morale.Morale = New_Morale

    planet_morale.When_Morale_Last_Changed = Get_Current_Week()
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

    local enemy_nighbors = 0

    if planet_neighbors == nil then
        return enemy_nighbors
    end

    for _, neighbor in pairs(planet_neighbors) do
        if neighbor.Get_Owner() ~= planet.Get_Owner() and neighbor.Get_Owner() ~= Find_Player("NEUTRAL") then
            enemy_nighbors = enemy_nighbors + 1
        end
    end

    return enemy_nighbors
end

function Find_First_Loss_Planet()
    local All_Planets = FindPlanet.Get_All_Planets()

    local player_owned_planets = {}

    for _, planet in pairs(All_Planets) do
        if planet.Get_Owner() == player then
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

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Morale_Update")
    end
end

function Lost_Battle(message)
    if message == OnEnter then
        loss_streak = loss_streak + 1

        win_streak = 0

        if loss_streak >= 3 then
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

        loss_streak = 0

        Set_Next_State("Flush")
    end
end

function Won_Battle(message)
    if message == OnEnter then

        win_streak = win_streak + 1

        loss_streak = 0

        if win_streak >= 3 then
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
        
        win_streak = 0

        Set_Next_State("Flush")
    end
end

function Construction_Minor(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Construction(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Construction_Major(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Hero_Lost(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Hero_Killed(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end