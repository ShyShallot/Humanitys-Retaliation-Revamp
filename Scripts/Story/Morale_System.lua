require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PGStoryMode")

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
        ["Morale_Lost_Battle"] = {Value = 1, Subtract = true, KD_Influence = true},
        ["Morale_Lost_Battle_Major"] = {Value = 3, Subtract = true, KD_Influence = true},
        ["Morale_Won_Battle"] = {Value = 1, Subtract = false, KD_Influence = true},
        ["Morale_Won_Battle_Major"] = {Value = 3, Subtract = false, KD_Influence = true},
        ["Morale_Construction_Event_Minor"] = {Value = 1, Subtract = false},
        ["Morale_Construction_Event"] = {Value = 2, Subtract = false},
        ["Morale_Construction_Event_Major"] = {Value = 3, Subtract = false},
        ["Hero_Lost"] = {Value = 3, Subtract = true},
        ["Hero_Killed"] = {Value = 3, Subtract = false},
    }

    UNSC_Kill_Ratio_Table = {0.0625, 0.07, 0.1 , 0.16, 0.3} -- the index is the morale gain from the kill ratio at that index

    COVN_Kill_Ratio_Table = {0.3, 0.5, 1, 2, 3}

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

    win_streak = 0

    loss_streak = 0

    player = nil
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

        GlobalValue.Set("Morale_Active", 1)

        local Difficulty = player.Get_Difficulty()

        if Difficulty == "Normal" then
            global_morale_level = 75
        elseif Difficulty == "Hard" then
            global_morale_level = 50
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

        if global_morale_level <= 25 then -- low morale

        elseif global_morale_level < 80 then -- medium morale

        else -- high morale

        end
    end
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

function Modify_Morale(event_table)

    if event_table == nil then
        return
    end

    if type(event_table) ~= "table" then
        DebugMessage("%s -- Morale Value is NOT a valid Table", tostring(Script))
        return
    end

    if tableLength(event_table) ~= 2 then
        return
    end

    local Morale_Value = event_table.Value

    local bad = event_table.Subtract

    DebugMessage("%s -- Event Morale Value: %s, Subtract: %s", tostring(Script), tostring(Morale_Value), tostring(bad))

    local Next_Morale_Level = global_morale_level + Morale_Value

    if bad then
        Next_Morale_Level = global_morale_level - Morale_Value
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

            return {Value = New_Morale_Value, Subtract = Morale_Values.Subtract}
        else
            return Morale_Values
        end
    else
        return {Value = 0, Subtract = false}
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