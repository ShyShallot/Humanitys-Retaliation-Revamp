Great_Schism = {
    Has_Triggered = false,

    Planet_List = {"EARTH"},

    Banished = nil,

    Covenant = nil,

    Planet_Loss_Percentage = 0.5,

    Schism_Event_Trigger = "Trigger_Great_Schism",

    Schism_Event_Trigger_Dialog = "Trigger_Great_Schism_Dialog",

    Planet_Table = nil

}

function Great_Schism:Init() 
    self.Banished = Find_Player("SWORDS")

    self.Covenant = Find_Player("EMPIRE")

    self.Planet_Table = require("globalPlanetTable")
end

function Great_Schism:Check()

    if self.Has_Triggered then
        return
    end

    if self.Banished == nil then
        self.Banished = Find_Player("SWORDS")
        return
    end

    if self.Covenant == nil then
        self.Covenant = Find_Player("EMPIRE")
        return
    end

    for _, Planet_Name in pairs(self.Planet_List) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            if Planet.Get_Owner() == self.Covenant then
                self:Trigger()
                break
            end
        end
    end
end

function Great_Schism:Trigger()
    self.Has_Triggered = true

    local Planets_To_Lose = 0

    local Covenant_Planets = {}

    for _, Planet_Name in pairs(self.Planet_Table:Return_All_Keys()) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            if Planet.Get_Owner() == self.Covenant then
                table.insert(Covenant_Planets, Planet)
            end
        end
    end

    Planets_To_Lose = tonumber(Dirty_Floor(tableLength(Covenant_Planets) * self.Planet_Loss_Percentage))

    local Planets_Lost = 0

    local Unit_Location_Cache = self:Generate_Unit_Location_Cache()

    local Units_To_Spawn = self:Precache_Banished_Units(Covenant_Planets)

    DebugMessage("%s -- Triggering Great Schism, Covenant will lose %s Planets out of %s Total Planets", tostring(Script), tostring(Planets_To_Lose), tostring(tableLength(Covenant_Planets)))

    while Planets_Lost < Planets_To_Lose do
        local Random_Planet = Random_From_List(Covenant_Planets)

        if TestValid(Random_Planet) then

            self:Delete_Units_At_Planet(Random_Planet, Unit_Location_Cache)

            local Spawn_Entry = Units_To_Spawn[Random_Planet]

            DebugMessage("%s -- Units To Spawn: %s", tostring(Script), tostring(Spawn_Entry))

            if Spawn_Entry ~= nil then

                DebugMessage("%s -- Init Spawning Units on %s", tostring(Script), tostring(Random_Planet))

                Random_Planet.Change_Owner(self.Banished)

                Spawn_Unit(Spawn_Entry.Station, Random_Planet, self.Banished)

                for Unit_Name, Amount in pairs(Spawn_Entry.Units) do
                    local Selected_Amount = EvenMoreRandom(Amount[1], Amount[2])

                    local Spawned = 0

                    local Unit_Type = Find_Object_Type(Unit_Name)

                    if Unit_Type ~= nil then

                        while Spawned < Selected_Amount do
                            local Spawned_Unit = Spawn_Unit(Unit_Type, Random_Planet, self.Banished)

                            if Spawned_Unit ~= nil then
                                Spawned_Unit[1].Prevent_AI_Usage(false)
                            end

                            Spawned = Spawned + 1

                        end
                    end
                end

                for index, check_planet in pairs(Covenant_Planets) do
                    if check_planet == Random_Planet then
                        table.remove(Covenant_Planets, index)
                    end
                end
            end
        end

        Planets_Lost = Planets_Lost + 1
    end

    Story_Event(self.Schism_Event_Trigger)

    if self.Covenant.Is_Human() then
        Story_Event(self.Schism_Event_Trigger_Dialog)
    end
end

function Great_Schism:Calculate_Units(Space_Station_Level)

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
            ["SWORDS_CRS"] = {2,5},
            ["SWORDS_CCS"] = {1,4},
            ["SWORDS_SDV"] = {4,8},
            ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {3,5},
			["COVN_DEPLOYABLE_ADVANCED_HALL"] = {1,3},
			["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {1,2},
			["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {1,1}
        },
        [2] = {
            ["SWORDS_CRS"] = {5,10},
            ["SWORDS_CCS"] = {4,8},
            ["SWORDS_SDV"] = {6,12},
            ["SWORDS_CAS"] = {1,4},
            ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {3,5},
			["COVN_DEPLOYABLE_ADVANCED_HALL"] = {1,3},
			["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {1,2},
			["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {1,1}
        },
        [3] = {
            ["SWORDS_CRS"] = {7,12},
            ["SWORDS_CCS"] = {6,10},
            ["SWORDS_SDV"] = {8,14},
            ["SWORDS_CAS"] = {3,4},
            ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {3,5},
			["COVN_DEPLOYABLE_ADVANCED_HALL"] = {1,3},
			["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {1,2},
			["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {1,1}
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

    local Station_To_Spawn = "SWORDS_STARBASE_" .. tostring(Converted_Station_Level)
    
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

function Great_Schism:Generate_Unit_Location_Cache()
    local Units = Find_All_Objects_Of_Type(self.Covenant, "Fighter | Bomber | Transport | Corvette | Frigate | Capital | Super | Structure | Infantry | Vehicle | SpaceStructure | LandHero | SpaceHero")

    local Unit_Location_Table = {}

    for _, Unit in pairs(Units) do
        if TestValid(Unit) then
            
            --DebugMessage("%s -- Found Unit: %s Owned by the Covenant", tostring(Script), tostring(Unit))

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

function Great_Schism:Delete_Units_At_Planet(Planet, Unit_List)

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

function Great_Schism:Precache_Banished_Units(Covenant_Planet_List)
    local Cache_Table = {}
    
    for _, Planet in pairs(Covenant_Planet_List) do
        if TestValid(Planet) then
            local Starbase_Level = Planet.Get_Starbase_Level()

            DebugMessage("%s -- Starbase Level for Planet %s: %s", tostring(Script), tostring(Planet), tostring(Starbase_Level))

            Cache_Table[Planet] = self:Calculate_Units(Starbase_Level)
        end
    end

    return Cache_Table
end

return Great_Schism