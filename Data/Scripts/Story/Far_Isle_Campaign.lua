Far_Isle_Campaign = {
    Has_Triggered = false,

    Capture_List = {"Far_Isle"},

    Planet_Loss_List = {"Meridian", "Arcadia", "Aleria", "Gao", "Harmony"},

    Terrorists = nil,

    UNSC = nil,

    Planet_Loss_Percentage = 0.65,

    Schism_Event_Trigger = "Trigger_Far_Isle_Campaign",

    Schism_Event_Trigger_Dialog = "Trigger_Far_Isle_Campaign_Dialog",

    Planet_Table = nil,

    Unit_Spawn_Multiplier = 2.5,
}

function Far_Isle_Campaign:Init() 
    self.Terrorists = Find_Player("Terrorists")

    self.UNSC = Find_Player("Rebel")

    self.Planet_Table = require("globalPlanetTable")
end

function Far_Isle_Campaign:Check()

    if self.Has_Triggered then
        return
    end

    if self.Terrorists == nil then
        self.Terrorists = Find_Player("Terrorists")
        return
    end

    if self.UNSC == nil then
        self.UNSC = Find_Player("Rebel")
        return
    end

    local All_Planets_Captured = 0

    local Total_Planets_Needed = tableLength(self.Capture_List)

    for _, Planet_Name in pairs(self.Capture_List) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            if Planet.Get_Owner() == self.UNSC then
                All_Planets_Captured = All_Planets_Captured + 1
            end
        end
    end

    if All_Planets_Captured == Total_Planets_Needed then
        self:Trigger()
    end
end

function Far_Isle_Campaign:Trigger()
    self.Has_Triggered = true

    local Unit_Location_Cache = self:Generate_Unit_Location_Cache()

    for _, Planet_Name in pairs(self.Planet_Loss_List) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then

            if Planet.Get_Owner() == self.UNSC then

                local Units_To_Spawn = self:Calculate_Units(Planet.Get_Starbase_Level())

                self:Delete_Units_At_Planet(Planet, Unit_Location_Cache)

                DebugMessage("%s -- Units To Spawn: %s", tostring(Script), tostring(Units_To_Spawn))

                if Units_To_Spawn ~= nil then

                    DebugMessage("%s -- Init Spawning Units on %s", tostring(Script), tostring(Planet))

                    Planet.Change_Owner(self.Terrorists)

                    Spawn_Unit(Units_To_Spawn.Station, Planet, self.Terrorists)

                    for Unit_Name, Amount in pairs(Units_To_Spawn.Units) do
                        local Selected_Amount = EvenMoreRandom(Amount[1], Amount[2])

                        Selected_Amount = tonumber(tostring(Selected_Amount * self.Unit_Spawn_Multiplier))

                        if type(Selected_Amount) ~= "number" then
                            Selected_Amount = EvenMoreRandom(Amount[1], Amount[2])
                        end

                        local Spawned = 0

                        local Unit_Type = Find_Object_Type(Unit_Name)

                        if Unit_Type ~= nil then

                            while Spawned < Selected_Amount do
                                local Spawned_Unit = Spawn_Unit(Unit_Type, Planet, self.Terrorists)

                                if Spawned_Unit ~= nil then
                                    Spawned_Unit[1].Prevent_AI_Usage(false)
                                end

                                Spawned = Spawned + 1

                            end
                        end
                    end
                end
            end

        end

    end

    Story_Event(self.Schism_Event_Trigger)

    if self.UNSC.Is_Human() then
        Story_Event(self.Schism_Event_Trigger_Dialog)
    end
end

function Far_Isle_Campaign:Calculate_Units(Space_Station_Level)

    DebugMessage("%s -- Calculating Units for Starbase Level: %s", tostring(Script), tostring(Space_Station_Level))

    if Space_Station_Level == nil then
        Space_Station_Level = 0
    end

    local Station_Table = {
        [0] = 1,
        [1] = 1,
        [2] = 2,
        [3] = 2,
        [4] = 3,
        [5] = 3,
    }

    local Unit_Table = {
        [1] = {
            ["TERROR_BUCKLER"] = {2,5},
            ["TERROR_PHOENIX"] = {1,4},
            ["TERROR_CHARON"] = {4,8},
			["TERROR_MUSASHI"] = {4,8},
            ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {1,5},
			["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {1,3},
			["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {1,2},
			["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {1,1},
        },
        [2] = {
            ["TERROR_CHARON"] = {5,10},
            ["TERROR_BUCKLER"] = {6,12},
            ["TERROR_PHOENIX"] = {1,4},
			["TERROR_MUSASHI"] = {2,4},
            ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {1,5},
			["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {1,3},
			["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {1,2},
			["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {1,1},
        },
        [3] = {
            ["TERROR_CHARON"] = {7,12},
            ["TERROR_BUCKLER"] = {8,14},
            ["TERROR_PHOENIX"] = {3,4},
			["TERROR_MUSASHI"] = {4,10},
            ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {1,5},
			["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {1,3},
			["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {1,2},
			["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {1,1},
        }
    }

    local Converted_Station_Level = Station_Table[Space_Station_Level]
    

    if Converted_Station_Level == nil then
        Converted_Station_Level = 1
    end

    DebugMessage("%s -- Converted Station Level: %s from %s", tostring(Script), tostring(Converted_Station_Level), tostring(Space_Station_Level))

    local Selected_Unit_Table = Unit_Table[Converted_Station_Level]
    
    DebugMessage("%s -- Selected Unit Tabke: %s", tostring(Script), tostring(Selected_Unit_Table))

    PrintTable(Selected_Unit_Table)

    if Selected_Unit_Table == nil then
        return
    end

    local Station_To_Spawn = "Terrorists_Star_Base_" .. tostring(Converted_Station_Level)
    
    local Station_Type = Find_Object_Type(Station_To_Spawn)

    DebugMessage("%s -- New Starbase Type: %s, Level: %s", tostring(Script), tostring(Station_Type), tostring(Station_To_Spawn))
    
    if Station_Type == nil then
        return
    end

    local Units = {
        Station = Station_Type,
        Units = Selected_Unit_Table
    }

    DebugMessage("%s -- Final Units Table", tostring(Script))

    PrintTable(Units)

    return Units
end

function Far_Isle_Campaign:Generate_Unit_Location_Cache()
    local Units = Find_All_Objects_Of_Type(self.UNSC, "Fighter | Bomber | Transport | Corvette | Frigate | Capital | Super | Structure | Infantry | Vehicle | SpaceStructure | LandHero | SpaceHero")

    local Unit_Location_Table = {}

    for _, Unit in pairs(Units) do
        if TestValid(Unit) then
            
            --DebugMessage("%s -- Found Unit: %s Owned by the UNSC", tostring(Script), tostring(Unit))

            local Planet = Unit.Get_Planet_Location()

            if TestValid(Planet) then

                if Unit_Location_Table[Planet] == nil then
                    Unit_Location_Table[Planet] = {}
                end

                --DebugMessage("%s -- Adding %s to the Cache under %s", tostring(Script), tostring(Unit), tostring(Planet))

                table.insert(Unit_Location_Table[Planet], Unit)
            end
        end
    end

    return Unit_Location_Table
end

function Far_Isle_Campaign:Delete_Units_At_Planet(Planet, Unit_List)

    --DebugMessage("%s -- Deleting all Units on Planet: %s", tostring(Script), tostring(Planet))

    if not TestValid(Planet) then
        return
    end

    if Unit_List[Planet] ~= nil then
        for _, Unit in pairs(Unit_List[Planet]) do
            if TestValid(Unit) then
                --DebugMessage("%s -- Despawning Unit: %s", tostring(Script), tostring(Unit))
                Unit.Despawn()
            end
        end
    end
end

function Far_Isle_Campaign:Precache_Terrorists_Units(UNSC_Planet_List)
    local Cache_Table = {}
    
    for _, Planet in pairs(UNSC_Planet_List) do
        if TestValid(Planet) then
            local Starbase_Level = Planet.Get_Starbase_Level()

            DebugMessage("%s -- Starbase Level for Planet %s: %s", tostring(Script), tostring(Planet), tostring(Starbase_Level))

            Cache_Table[Planet] = self:Calculate_Units(Starbase_Level)
        end
    end

    return Cache_Table
end

return Far_Isle_Campaign