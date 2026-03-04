require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")

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

        BaseStory:Initialize(nil, "HaloFiles\\Campaigns\\StoryMissions\\Setup_Generic.xml")
    end
end