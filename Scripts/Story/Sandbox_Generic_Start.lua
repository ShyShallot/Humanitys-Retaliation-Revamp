require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Init_GC = Global_Story
    }

end

function Global_Story(message)
    if  message == OnEnter then 
        local Starting_Units = require("Starting_Units")

        Starting_Units:Start()

        if Starting_Units:Is_Finished() then
            Story_Event("Spawning_Done")
        end
    end
end