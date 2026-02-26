Great_Schism = {
    Has_Triggered = false,

    Planet_List = {"EARTH"},

    Banished = nil,

    Covenant = nil,

    Planet_Loss_Percentage = 0.5,

    Schism_Event_Trigger = "Trigger_Great_Schism",

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

    while Planets_Lost < Planets_To_Lose do
        local Random_Planet = Random_From_List(Covenant_Planets)

        if TestValid(Random_Planet) then

            local Units_To_Spawn = self:Calculate_Units(Random_Planet.Get_Starbase_Level())

            if Units_To_Spawn ~= nil then

                Random_Planet.Change_Owner(self.Banished)

                Spawn_Unit(Units_To_Spawn.Station, self.Banished, Random_Planet)

                for Unit_Name, Amount in pairs(Units_To_Spawn.Units) do
                    local Selected_Amount = EvenMoreRandom(Amount[1], Amount[2])

                    local Spawned = 0

                    local Unit_Type = Find_Object_Type(Unit_Name)

                    if Unit_Type ~= nil then

                        while Spawned < Selected_Amount do
                            local Spawned_Unit = Spawn_Unit(Unit_Type, self.Banished, Random_Planet)

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
end

function Great_Schism:Calculate_Units(Space_Station_Level)

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
            ["Imperial_Stormtrooper_Squad"] = {5,5}
        },
        [2] = {
            ["SWORDS_CRS"] = {5,10},
            ["SWORDS_CCS"] = {4,8},
            ["SWORDS_SDV"] = {6,12},
            ["SWORDS_CAS"] = {1,4}
            ["Imperial_Stormtrooper_Squad"] = {5,8}
        },
        [3] = {
            ["SWORDS_CRS"] = {7,12},
            ["SWORDS_CCS"] = {6,10},
            ["SWORDS_SDV"] = {8,14},
            ["SWORDS_CAS"] = {3,4}
            ["Imperial_Stormtrooper_Squad"] = {8,10}
        }
    }

    local Converted_Station_Level = Station_Table[Space_Station_Level]

    if Converted_Station_Level == nil then
        Converted_Station_Level = 1
    end

    local Selected_Unit_Table = Unit_Table[Converted_Station_Level]

    if Selected_Unit_Table == nil then
        return
    end

    local Station_To_Spawn = "SWORDS_STARBASE_" .. tostring(Converted_Station_Level)
    
    local Station_Type = Find_Object_Type(Station_To_Spawn)
    
    if Station_Type == nil then
        return
    end

    local Units = {
        Station = Station_Type,
        Units = Selected_Unit_Table
    }

    return Units
end

return Great_Schism