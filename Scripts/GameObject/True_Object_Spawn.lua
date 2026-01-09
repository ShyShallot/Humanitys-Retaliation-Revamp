require("PGStateMachine")

function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);

end

function State_Init(message)
	if message == OnEnter then

		local True_Unit_Table = require("True_Unit_Table")

        local True_Entry = True_Unit_Table:Get_Entry(Object.Get_Type().Get_Name())

        if True_Entry ~= nil then

            local True_Object = Find_Object_Type(True_Entry.Spawns)

            if True_Object ~= nil then
                Spawn_Unit(True_Object, Object, Object.Get_Owner())

                Object.Despawn()
            end
        end
	end
end