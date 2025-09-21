require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Init_Random = Global_Story,
        Update = Update,
        Structures_Super_Filter = Set_Structures_Super_Filter,
        Capitals_Filter = Set_Capitals_Filter,
        Frigate_Corvette_Filter = Set_Frigate_Corvette_Filter,
        Fighter_Filter = Set_Fighter_Filter,
        Flush = Flush,
    }

    Filter_System = nil

end

function Global_Story(message)
    if  message == OnEnter then 
        local Random_Planet_Starter = require("Random_Planet_Starter")

        local Starting_Units = require("Starting_Units")

        Filter_System = require("Unit_Filters") 

        Random_Planet_Starter:Start()

        if Random_Planet_Starter:Is_Finished() then
            Starting_Units:Start()

            if Starting_Units:Is_Finished() then
                Story_Event("Spawning_Done")

                Filter_System:Init(Player, "HaloFiles\\Campaigns\\StoryMissions\\Random_Start.xml")
                
                Set_Next_State("Flush")
            end
        end
    end
end

function Update(message)
    if message == OnUpdate then
        Filter_System:Update()
    end
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Update")
    end
end

function Set_Structures_Super_Filter(message)
    if message ~= OnEnter then return end
    
    Filter_System:Set_Filter(Filter_System.Structure_Super_Filter)

    Set_Next_State("Flush")
end

function Set_Capitals_Filter(message)
    if message ~= OnEnter then return end
    
    Filter_System:Set_Filter(Filter_System.Capitals_Filter)

    Set_Next_State("Flush")
end

function Set_Frigate_Corvette_Filter(message)
    if message ~= OnEnter then return end
    
    Filter_System:Set_Filter(Filter_System.Frigate_Corvette_Filter)

    Set_Next_State("Flush")
end

function Set_Fighter_Filter(message)
    if message ~= OnEnter then return end
    
    Filter_System:Set_Filter(Filter_System.Fighter_Filter)

    Set_Next_State("Flush")
end