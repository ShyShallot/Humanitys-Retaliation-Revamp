-- Script Written by ShyShallot

Random_Start = {
    Total_Major_Starting_Planets = 1,

    Minor_Faction_Control_Percentage = 0.4, -- this is per minor faction, so each minor faction controls 40% at first, and with 2 minor factions that is 80% of the map starts with minor factions

    Spawn_List = {
        {Name = "Rebel", Major = true},
        {Name = "Empire", Major = true},
        {Name = "Swords", Major = false},
        {Name = "Terrorists", Major = false},
    },

    Starting_Structures = {
        REBEL = {
            Ground = {"UNSC_CAPITAL"},
            Space = {},
            Station = {
                Level = 5,
                Name = "Rebel_Star_Base_"
            },
        },
        EMPIRE = {
            Ground = {"COVN_CAPITAL"},
            Space = {},
            Station = {
                Level = 5,
                Name = "Empire_Star_Base_"
            },
        },
        SWORDS = {
            Ground = {},
            Space = {},
            Station = {
                Name = "SWORDS_STARBASE_",
                Range = {1,2}
            }
        },
        TERRORISTS = {
            Ground = {},
            Space = {},
            Station = {
                Name = "Terrorists_Star_Base_",
                Range = {1,3}
            }
        }
    },

    Starting_Units = {
        REBEL = "UNSC_HALCYON",
        EMPIRE = "COVN_CCS",
        SWORDS = "SWORDS_CCS",
        TERRORISTS = "TERROR_HALCYON"
    },

    Planet_List = {},

    Neutral = nil,

    Finished = false
}

function Random_Start:Clear_Starting_Planets(faction)

    if not TestValid(faction) then
        return
    end

    local Unit_To_Find = self.Starting_Units[faction.Get_Faction_Name()]

    if Unit_To_Find ~= nil then
        local Unit = Find_First_Object(Unit_To_Find)

        if TestValid(Unit) then
            local Planet = Unit.Get_Planet_Location()

            if TestValid(Planet) then
                Unit.Despawn()
                Planet.Change_Owner(self.Neutral)
            end
        end
    end
end

function Random_Start:Pick_Faction_Start_Major(Faction_Name)

    local faction = Find_Player(Faction_Name)

    if not TestValid(faction) then return end

    self:Clear_Starting_Planets(faction)

    local Selected_Planets = 0

    local attempts = 0

    while Selected_Planets < self.Total_Major_Starting_Planets and attempts < 15 do

        local Starting_Planet = Random_From_List(self.Planet_List)

        if TestValid(Starting_Planet) then

            if Starting_Planet.Get_Owner() == self.Neutral then

                Starting_Planet.Change_Owner(faction)

                local Structs = self.Starting_Structures[faction.Get_Faction_Name()]

                if Structs ~= nil then

                    local Station_Info = Structs.Station

                    if Station_Info.Name ~= nil then

                        if type(Station_Info.Level) == "number" then
                            local Station_To_Spawn = Station_Info.Name .. Station_Info.Level

                            Spawn_Unit(Find_Object_Type(Station_To_Spawn), Starting_Planet, faction)
                        end
                    end

                    for _, struct in pairs(Structs.Ground) do
                        Spawn_Unit(Find_Object_Type(struct), Starting_Planet, faction)
                    end

                    for _, struct in pairs(Structs.Space) do
                        Spawn_Unit(Find_Object_Type(struct), Starting_Planet, faction)
                    end
                end

                Selected_Planets = Selected_Planets + 1
            end
        end

        attempts = attempts + 1
    end
end

function Random_Start:Minor_Faction_Fill(Faction_Name)

    local faction = Find_Player(Faction_Name)

    if not TestValid(faction) then return end

    self:Clear_Starting_Planets(faction)

    local Planets_To_Control = tonumber(Dirty_Floor(tableLength(self.Planet_List) * self.Minor_Faction_Control_Percentage))

    local Controlled_Planets = 0 

    local attempts = 0

    while Controlled_Planets < Planets_To_Control and attempts < 60 do

        local Starting_Planet = Random_From_List(self.Planet_List)

        if TestValid(Starting_Planet) then

            if Starting_Planet.Get_Owner() == self.Neutral then

                Starting_Planet.Change_Owner(faction)
                

                local Structs = self.Starting_Structures[faction.Get_Faction_Name()]

                if Structs ~= nil then

                    local Station_Info = Structs.Station

                    if Station_Info.Name ~= nil then
                        local Station_Level = EvenMoreRandom(Station_Info.Range[1],Station_Info.Range[2])

                        if type(Station_Level) == "number" then
                            local Station_To_Spawn = Station_Info.Name .. Station_Level

                            Spawn_Unit(Find_Object_Type(Station_To_Spawn), Starting_Planet, faction)
                        end
                    end

                    for _, struct in pairs(Structs.Ground) do
                        Spawn_Unit(Find_Object_Type(struct), Starting_Planet, faction)
                    end

                    for _, struct in pairs(Structs.Space) do
                        Spawn_Unit(Find_Object_Type(struct), Starting_Planet, faction)
                    end
                end

                Controlled_Planets = Controlled_Planets + 1
            end
        end

        attempts = attempts + 1
    end
end

function Random_Start:Start()

    local Planets = FindPlanet.Get_All_Planets()

    local invalid_planets = {"Compromised", "Strained", "Resolute", "Ascendant"}

    for _, planet in pairs(Planets) do
        local planet_name = planet.Get_Type().Get_Name()

        local valid = true

        for _, invalid in pairs(invalid_planets) do
            if string.upper(invalid) == string.upper(planet_name) then
                valid = false

                break
            end
        end

        if valid then
            table.insert(self.Planet_List, planet)
        end
    end

    self.Neutral = Find_Player("Neutral")

    for _, Faction_Info in pairs(self.Spawn_List) do
        if Faction_Info.Major then
            self:Pick_Faction_Start_Major(Faction_Info.Name)
        else
            self:Minor_Faction_Fill(Faction_Info.Name)
        end
    end

    self.Finished = true
end

function Random_Start:Set_Starting_Planet_Count(count)
    self.Total_Major_Starting_Planets = count
end

function Random_Start:Is_Finished()
    return self.Finished
end

function Random_Start:Set_Major_Faction_Starting_Station_Level(faction, level)

    if faction == nil then
        return
    end

    if type(level) ~= "number" then
        return
    end

    if level < 1 or level > 5 then 
        return
    end

    if TestValid(faction) then
        local Faction_Name = faction.Get_Faction_Name()

        if Faction_Name ~= nil then
            local Faction_Info = self.Starting_Structures[Faction_Name]

            if Faction_Info ~= nil then

                if Faction_Info.Station.Level ~= nil then
                    Faction_Info.Station.Level = level
                end
            end
        end
    end
end

function Random_Start:Set_Minor_Faction_Starting_Station_Range(faction, low, high)

    if faction == nil then
        return
    end

    if type(low) ~= "number" and type(high) ~= "number" then
        return
    end

    if low < 1 then
        return
    end

    if high > 5 then
        return
    end

    if low > high then
        local temp = high

        high = low

        low = temp
    end

    if TestValid(faction) then
        local Faction_Name = faction.Get_Faction_Name()

        if Faction_Name ~= nil then
            local Faction_Info = self.Starting_Structures[Faction_Name]

            if Faction_Info ~= nil then

                if Faction_Info.Station.Range ~= nil then
                    Faction_Info.Station.Range = {low, high}
                end
            end
        end
    end
end

return Random_Start