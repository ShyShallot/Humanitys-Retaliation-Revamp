require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("globalPlanetTable")
require("globalUnitTable")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.3

    StoryModeEvents = {
        Init_GC = Init_GC,
        Structures_Super_Filter = Set_Structures_Super_Filter,
        Capitals_Filter = Set_Capitals_Filter,
        Frigate_Corvette_Filter = Set_Frigate_Corvette_Filter,
        Fighter_Filter = Set_Fighter_Filter,
        Flush = Flush,
        Update = Update,
    }

    ---@type Starting_Units_Handler
    Starting_Units = require("Starting_Units")

    Tech_Stealing = require("Tech_Stealing")

    ---@type Unit_Filters
    Unit_Filters = require("Unit_Filters")
    
    Great_Schism = require("Great_Schism")

    Far_Isle_Campaign = require("Far_Isle_Campaign")

    Random_Planet_Starter = require("Random_Planet_Starter")

    Utilize_Random_Start = false
    
end

function Init_GC(messsage)

    DebugMessage("%s -- Starting GC Init", tostring(Script))

    if messsage ~= OnEnter then
        return
    end

    local Single_Start_Object = Find_First_Object("Single_Random_Start")
    
    local Is_Single_Start = TestValid(Single_Start_Object)

    local Double_Start_Object = Find_First_Object("Double_Random_Start")

    local Is_Double_Start = TestValid(Double_Start_Object)

    if Is_Single_Start then
        Single_Start_Object.Despawn()
        Utilize_Random_Start = true
    end

    if Is_Double_Start then
        Double_Start_Object.Despawn()
        Utilize_Random_Start = true
        Random_Planet_Starter:Set_Starting_Planet_Count(2)
    end

    if Utilize_Random_Start then
        Random_Planet_Starter:Start()
    end

    if Utilize_Random_Start and Random_Planet_Starter:Is_Finished() then
        Starting_Units:Start()
    elseif not Utilize_Random_Start then
        Starting_Units:Start()
    end

    if Starting_Units:Is_Finished() then
        Unit_Filters:Init("HaloFiles\\Campaigns\\StoryMissions\\Common_Events.xml")

        Tech_Stealing:Init("HaloFiles\\Campaigns\\StoryMissions\\Common_Events.xml")

        Great_Schism:Init()

        Far_Isle_Campaign:Init()
    end

    Story_Event("Spawning_Done")

    Set_Next_State("Flush")
end

function Update(messsage)
    if messsage ~= OnUpdate then return end

    Unit_Filters:Update()

    Tech_Stealing:Update()

    Great_Schism:Check()

    Far_Isle_Campaign:Check()
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Update")
    end
end

function Set_Structures_Super_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Structures_Super_Filter: Setting structures super filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Structure_Super_Filter)
    Set_Next_State("Flush")
end

function Set_Capitals_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Capitals_Filter: Setting capitals filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Capitals_Filter)
    Set_Next_State("Flush")
end

function Set_Frigate_Corvette_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Frigate_Corvette_Filter: Setting frigate/corvette filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Frigate_Corvette_Filter)
    Set_Next_State("Flush")
end

function Set_Fighter_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Fighter_Filter: Setting fighter filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Fighter_Filter)
    Set_Next_State("Flush")
end