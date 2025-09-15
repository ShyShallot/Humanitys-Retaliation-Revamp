require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Init_Random = Global_Story
    }

end

-- Yes this code is similar to AOTR, i used it as a base for the most part and how things are done are based off of aotr, 
--i thank them for the original idea

function Story_Mode_Service()

end

function Global_Story(message)
    if  message == OnEnter then 
        local Random_Planet_Starter = require("Random_Planet_Starter")

        local Starting_Units = require("Starting_Units")

        Random_Planet_Starter:Set_Starting_Planet_Count(2)

        Random_Planet_Starter:Start()

        if Random_Planet_Starter:Is_Finished() then
            Starting_Units:Start()

            if Starting_Units:Is_Finished() then
                Story_Event("Spawning_Done")
            end
        end
    end
end