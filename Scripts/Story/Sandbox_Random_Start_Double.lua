require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("globalPlanetTable")

local BaseStory = require("Sanbox_Base_Story")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    Define_State("State_Init", State_Init);

    ServiceRate = 0.3

    StoryModeEvents = {}
end

function State_Init(messsage)
    if messsage == OnEnter then
        StoryModeEvents = BaseStory:CreateStoryModeEvents()

        Sleep(1)

        BaseStory:Initialize(
            {
                {Name = "Random_Planet_Starter", File = "Random_Planet_Starter", Dependency = nil, Update = false, Starts_GC = false, Needs_Plot_File = false}
            },
            true
        )

        BaseStory:Call_Module_Function("Random_Planet_Starter", "Set_Starting_Planet_Count", 2)

        BaseStory:Start_GC()
    end
end