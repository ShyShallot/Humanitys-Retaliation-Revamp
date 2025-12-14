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
        ["Compromised"] = {Space = "Morale_Compromised", Land = "Morale_Compromised_Ground"},
        ["Strained"] = {Space = "Morale_Strained", Land = "Morale_Strained_Ground"},
        ["Stabilized"] = nil,
        ["Resolute"] = {Space = "Morale_Resolute", Land = "Morale_Resolute_Ground"},
        ["Ascendant"] = {Space = "Morale_Ascendant", Land = "Morale_Ascendant_Ground"},
    }
end

function Morale_Tactical_Init(message)
    if message == OnEnter then

        Sleep(1)

        DebugMessage("%s -- Is Now Active", tostring(Script))

        player = Find_Human_Player()
        
        FogOfWar.Reveal_All(player)

        local Morale_Level = GlobalValue.Get("Morale_Status")

        if Morale_Level == nil then
            ScriptExit()
        end

        DebugMessage("%s -- Current Morale Level: %s", tostring(Script), tostring(Morale_Level))

        local Morale_Structure_Entry = Morale_Boost_Structures[Morale_Level]

        if Morale_Structure_Entry == nil then
            ScriptExit()
            return
        end

        local Morale_Structure = Morale_Structure_Entry.Space

        if Get_Game_Mode() == "Land" then
            Morale_Structure = Morale_Structure_Entry.Land
            ScriptExit()
            return
        end

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
