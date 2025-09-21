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
            Object.Despawn()
            ScriptExit()
        end

        local Owner = Object.Get_Owner()

        if not TestValid(Owner) then 
            Object.Despawn()
            ScriptExit() 
        end

        local Unit_Entry = Unit_Table[Object.Get_Type().Get_Name()]

        if Unit_Entry == nil then
            Object.Despawn()
            ScriptExit()
        end

        if Check_For_Highest_Level(Unit_Entry, Location) then
            Owner.Give_Money(Object.Get_Type().Get_Build_Cost())
            Object.Despawn()
            Game_Message("HALO_TEXT_CANT_UPGRADE")
            ScriptExit()
        end

        if Unit_Entry.Upgrades ~= nil then
            local Prev_Building = Find_Building(Unit_Entry.Upgrades, Location)

            if TestValid(Prev_Building) then
                Prev_Building.Despawn()
            end
        end

        if Unit_Entry.Spawns ~= nil then
            DebugMessage("%s -- Structure %s Spawns Another: %s", tostring(Script), tostring(Object.Get_Type().Get_Name()), tostring(Unit_Entry.Spawns))
            local Spawn_Type = Find_Object_Type(Unit_Entry.Spawns)

            if Spawn_Type ~= nil then
                Spawn_Unit(Spawn_Type, Location, Owner)
                Object.Despawn()
            else
                Object.Despawn()
            end
        end

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

function Check_For_Highest_Level(Entry, Location)
    if Entry == nil then
        return false
    end

    if Location == nil then
        return false
    end

    local Found = false

    local Its = 0

    while not Found or Its < 10 do
        if Entry.Next ~= nil then
            local Next_Building = Find_Building(Entry.Next, Location)

            if TestValid(Next_Building) then
                Found = true
            else
                if Unit_Table[Entry.Next] ~= nil then
                    Entry = Unit_Table[Entry.Next]
                end
            end
        else
            break
        end

        Its = Its + 1
    end

    return Found
end

