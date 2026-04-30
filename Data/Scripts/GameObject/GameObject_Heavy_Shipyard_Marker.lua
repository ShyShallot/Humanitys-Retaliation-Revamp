require("PGStateMachine")
function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);

    Shipyard_Upgrade = "RS_Heavy_Shipyard_Upgrade"

    Shipyard_Marker = "Rebel_Skirmish_Heavy_Shipyard"

    Shipyard = "UNSC_Heavy_Shipyard_Skirmish"

end

function State_Init(message)
    if message == OnUpdate then
        local Upgrade_Object = Find_First_Object(Shipyard_Upgrade)
        
        local Marker_Object = Find_First_Object(Shipyard_Marker)

        if TestValid(Upgrade_Object) then
            if TestValid(Marker_Object) then

                local Shipyard_Type = Find_Object_Type(Shipyard)

                local Rebel = Find_Player("REBEL")
                Spawn_Unit(Shipyard_Type, Marker_Object, Rebel)

                ScriptExit()
            end
        end
	end
end