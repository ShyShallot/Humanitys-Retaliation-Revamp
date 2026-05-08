require("PGStateMachine")
require("Squadrons_Defs")
require("HALOFunctions")

function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);

end

function State_Init(message)
	if message == OnEnter then
        local Object_Name = Object.Get_Type().Get_Name()

        local Squadron_Def = Squadrons_Library:Get_Squad(Object_Name)

        Squadrons_Library:Spawn_Squadron(Object, Squadron_Def)

        ScriptExit()
	end
end
