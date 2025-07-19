require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("PGStoryMode")

function Definitions()
    ServiceRate = 1
	
    StoryModeEvents = {
        Morale_Tactical_Battle_Start = Morale_Tactical_Init,
    }

    player = nil

    Morale_Boost_Structures = {
        ["Compromised"] = "Morale_Compromised",
        ["Strained"] = "Morale_Strained",
        ["Stabilized"] = nil,
        ["Resolute"] = "Morale_Resolute",
        ["Ascendant"] = "Morale_Ascendant",
    }
end

function Morale_Tactical_Init(message)
    if message == OnEnter then

        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end

        Sleep(1)

        DebugMessage("%s -- Is Now Active", tostring(Script))

        player = Find_Human_Player()

        local Morale_Level = GlobalValue.Get("Morale_Status")

        if Morale_Level == nil then
            ScriptExit()
        end

        DebugMessage("%s -- Current Morale Level: %s", tostring(Script), tostring(Morale_Level))

        local Morale_Structure = Morale_Boost_Structures[Morale_Level]

        if Morale_Structure == nil then
            ScriptExit()
            return
        end

        local Structure_Type = Find_Object_Type(Morale_Structure)

        if Structure_Type == nil then
            ScriptExit()
            return
        end

        local Spawn_POS = Create_Position(10000,-5000,10000)

        Spawn_Unit(Structure_Type, Spawn_POS, player)
    end
end
