require("PGStateMachine")
require("HALOFunctions")

function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init)
    Define_State("State_Wave_Start", State_Wave_Start)
    Define_State("State_Wave_Active", State_Wave_Active)
    Define_State("State_Wave_End", State_Wave_End)
    Define_State("State_Wave_Transition", State_Wave_Transition)

    Waves = {
        Current_Wave = {
            Num = 0,
            Spawned_Units = {},
            Units_Left_To_Spawn = 0,
            Total_Units = {},
            Active = false,
        },
        Spawn_Rules = {
            REBEL = {
                [1] = {
                    Max_Power = 1000,
                    Possible_Units = {"BROADSWORD_SQUADRON", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "STALWART_SQUADRON", "LONGSWORD_SQUADRON"}
                }
            },
            EMPIRE = {
                [1] = {
                    Max_Power = 1000,
                    Possible_Units = {"SDV_SQUADRON", "CRS_SQUADRON", "COVN_RCS"}
                }
            },
        },
        Option_Objects = {
            ["Firefight_Start"] = function() Set_Next_State("State_Wave_Start") end,
            ["Firefight_20"] = function() Firefight_Set_Cap(20) end,
            ["Firefight_30"] = function() Firefight_Set_Cap(30) end,
            ["Firefight_40"] = function() Firefight_Set_Cap(40) end,
            ["Firefight_50"] = function() Firefight_Set_Cap(50) end,
            ["Firefight_100"] = function() Firefight_Set_Cap(100) end,
            ["Firefight_Infinite"] = function() Firefight_Set_Cap(0) end,
        },
        Wave_Limit = 10
    }

    Human = nil

    AI = nil

    Victory_Object = nil

end

function State_Init(message)

    if message == OnUpdate then
        for object_name, func in pairs(Waves.Option_Objects) do
            if TestValid(Find_First_Object(object_name)) then
                Game_Message("Changed Firefight Options")
                func()
            end
        end
    end

    if message ~= OnEnter then return end

    for faction, _ in pairs(Waves.Spawn_Rules) do
        local player = Find_Player(faction)

        if player.Get_Space_Station() ~= nil then
            Human = player
        else
            AI = player
        end
    end

    Victory_Object = AI.Get_Space_Station()
end

function State_Wave_Transition(message)
    if message == OnEnter then
        Waves.Current_Wave.Spawned_Units = {}
        Waves.Current_Wave.Total_Units = {}
        Waves.Current_Wave.Active = false
        Waves.Current_Wave.Units_Left_To_Spawn = 0

        Waves.Current_Wave.Num = Waves.Current_Wave.Num + 1

        Decide_Wave_Units()

        Sleep(30)

        Set_Next_State("State_Wave_Start")
    end
end

function State_Wave_Start(message)
    if message == OnEnter then
        Waves.Current_Wave.Active = true

        Waves.Current_Wave.Units_Left_To_Spawn = table.getn(Waves.Current_Wave.Total_Units)

        Set_Next_State("State_Wave_Active")
    end
end

function State_Wave_Active(message)

    if message == OnUpdate then

        while Waves.Current_Wave.Active do

            if Waves.Current_Wave.Units_Left_To_Spawn <= 0 then
                local Enemy_Units = Find_All_Objects_Of_Type(AI)

                if table.getn(Enemy_Units) <= 0 then
                    Waves.Current_Wave.Active = false

                    Set_Next_State("State_Wave_End")
                end
            end

            if Waves.Current_Wave.Units_Left_To_Spawn > 0 then

                local Mini_Wave_Size = EvenMoreRandom(2, 6)

                if Waves.Current_Wave.Units_Left_To_Spawn - Mini_Wave_Size < 0 then
                    Mini_Wave_Size = Waves.Current_Wave.Units_Left_To_Spawn
                end

                for i=1, Mini_Wave_Size do
                    local unit_type = table.remove(Waves.Current_Wave.Total_Units, 1)
                    
                    if unit_type then
                        Spawn_Wave_Unit(unit_type)
                    end
                end

                Waves.Current_Wave.Units_Left_To_Spawn = Waves.Current_Wave.Units_Left_To_Spawn - Mini_Wave_Size

                Sleep(EvenMoreRandom(1,5))
            end
        end
    end
end

function State_Wave_End(message)
    if message ~= OnEnter then return end

    Game_Message("Completed Wave " .. tostring(Waves.Current_Wave.Num))

    if Waves.Current_Wave.Num >= Waves.Wave_Limit then
        VO.Despawn()

        ScriptExit()
    end

    Set_Next_State("State_Wave_Transition")
end

function Firefight_Set_Cap(value)
    Waves.Wave_Limit = value
end

function Decide_Wave_Units()
    
    local Nearest_Spawn_Setting = nil

    if Waves.Spawn_Rules[AI.Get_Faction_Name()] == nil then
        return
    end

    for wave_num, settings in pairs(Waves.Spawn_Rules[AI.Get_Faction_Name()]) do
        if Waves.Current_Wave.Num >= wave_num then
            Nearest_Spawn_Setting = settings
        end
    end

    if Nearest_Spawn_Setting == nil then
        return
    end

    if table.getn(Nearest_Spawn_Setting.Possible_Units) == 0 then
        return
    end

    local Total_Power = 0

    local Spawn_Attmpts = 0

    while Total_Power < Nearest_Spawn_Setting.Max_Power and Spawn_Attmpts < 20 do
        local Random_Unit = Random_From_List(Nearest_Spawn_Setting.Possible_Units)

        local Random_Unit_Type = Find_Object_Type(Random_Unit)

        if Random_Unit_Type ~= nil then
            local Unit_Power = Random_Unit_Type.Get_Combat_Rating()

            Total_Power = Total_Power + Unit_Power

            table.insert(Waves.Current_Wave.Total_Units, Random_Unit_Type)
        else
            Spawn_Attmpts = Spawn_Attmpts + 1
        end
    end
end

function Spawn_Wave_Unit(Object_Type)

    if not TestValid(AI) then
        return
    end

    if Object_Type == nil then
        return
    end

    local Random_Position = Random_Position_In_Radius(Object, 400)

    local Spawned_Unit = Spawn_Unit(Object_Type, Random_Position, AI)

    if TestValid(Spawned_Unit[1]) then
        Spawned_Unit[1].Teleport_And_Face(Object)
        table.insert(Waves.Current_Wave.Spawned_Units, Spawned_Unit[1])
    end

end

function Random_Position_In_Radius(Flag, Radius)
    if not TestValid(Flag) then
        return nil
    end

    local Pos_X, Pos_Y, Pos_Z = Flag.Get_Position().Get_XYZ()

    local Random_X = EvenMoreRandom(1, Radius)
    local Random_Y = EvenMoreRandom(1, Radius)

    local X_Negative = Return_Chance(0.5)
    local Y_Negative = Return_Chance(0.5)

    if X_Negative then
        Pos_X = Pos_X - Random_X
    else
        Pos_X = Pos_X + Random_X
    end

    if Y_Negative then
        Pos_Y = Pos_Y - Random_Y
    else
        Pos_Y = Pos_Y + Random_Y
    end

    local New_Position = Create_Position(Pos_X, Pos_Y, Pos_Z)

    return New_Position
end