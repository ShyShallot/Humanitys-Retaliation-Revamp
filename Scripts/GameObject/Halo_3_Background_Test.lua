require("PGStateMachine")
require("PGStoryMode")

function Definitions()

	DebugMessage("%s -- In Definitions", tostring(Script))

	ServiceRate = 0.03
		
	Define_State("State_Init", State_Init);

	Menu_Status = {
		Intro = {
			Block = nil,
			Name = "Background"
		},
		Loop = {
			Block = nil,
			Name = "Background_Loop"
		}
	}


end


function State_Init(message)

	if message == OnEnter then
		Menu_Status.Intro.Block = Play_Bink_Movie(Menu_Status.Intro.Name)
    end

	if message == OnUpdate then
		if Menu_Status.Intro.Block ~= nil and Menu_Status.Intro.Block.IsFinished() then
			if Menu_Status.Loop.Block == nil or Menu_Status.Loop.Block.IsFinished() then
				Menu_Status.Loop.Block = Play_Bink_Movie(Menu_Status.Loop.Name)
			end
		end
	end
end
