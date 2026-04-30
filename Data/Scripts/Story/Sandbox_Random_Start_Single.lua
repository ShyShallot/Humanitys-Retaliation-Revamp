require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("globalPlanetTable")

local BaseStory = require("Sandbox_Base_Story")

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
            }, true
        )
        

        BaseStory:Call_Module_Function("Starting_Units", "Set_Spawn_Variations", 2)

        BaseStory:Start_GC() -- We set BaseStory to Manual Start so we can set the amount of starting planets for the player, thus we have to manually call Start_GC
    end
end