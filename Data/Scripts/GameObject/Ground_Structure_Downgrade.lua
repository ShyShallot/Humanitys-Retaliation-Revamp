require("PGStateMachine")

function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);

    Unit_Table = require("globalUnitTable")
end

function State_Init(message)
	if message == OnEnter then

		local Location = Object.Get_Planet_Location()

        if not TestValid(Location)then
            ScriptExit()
        end

        local Owner = Object.Get_Owner()

        if not TestValid(Owner) then 
            ScriptExit() 
        end

        local Building_Name = string.gsub(Object.Get_Type().Get_Name(),"DOWNGRADE_","")

        local Unit_Entry = Unit_Table[Building_Name]

        if Unit_Entry == nil then
            ScriptExit()
        end
        
        if Unit_Entry.Upgrades ~= nil then
            local Prev_Building = Find_Object_Type(Unit_Entry.Upgrades, Location)

            if Prev_Building ~= nil then
                Spawn_Unit(Prev_Building, Location, Owner)

                local Current_Building = Find_Building(Building_Name, Location)

                if TestValid(Current_Building) then
                    Current_Building.Despawn()
                end
            end
        end

        Object.Despawn()

        ScriptExit()
	end
end

function Find_Building(Name, location)

    if not TestValid(location) then
        return nil
    end

    if Name == nil then
        return nil
    end

    local Type = Find_Object_Type(Name)

    local Found_Building = nil

    if Type ~= nil then
        local All_Buildings = Find_All_Objects_Of_Type(Type)

        for _, Building in ipairs(All_Buildings) do
            if Building.Get_Planet_Location() == location then
                Found_Building = Building
            end
        end
    end

    return Found_Building
end

