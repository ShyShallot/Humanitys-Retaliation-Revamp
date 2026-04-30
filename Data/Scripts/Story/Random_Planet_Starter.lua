-- Script Written by ShyShallot

Random_Start = {
    Total_Major_Starting_Planets = 1,

    Spawn_List = {
        {Name = "Rebel", Control_Percentage = 0.35}, -- Control Percentage is out of 100%, however because 1 of these factions will be human, only 3/4 of them will contribute to the 100%
        {Name = "Empire", Control_Percentage = 0.35},
        {Name = "Swords", Control_Percentage = 0.25},
        {Name = "Terrorists", Control_Percentage = 0.25},
    },

    Starbases = {
        REBEL = {
            Random = {"Rebel_Star_Base_1","Rebel_Star_Base_2","Rebel_Star_Base_3","Rebel_Star_Base_4","Rebel_Star_Base_5"},
            Starting = "Rebel_Star_Base_5",
        },
        EMPIRE = {
            Random = {"Empire_Star_Base_1", "Empire_Star_Base_2", "Empire_Star_Base_3", "Empire_Star_Base_4", "Empire_Star_Base_5"},
            Starting = "Empire_Star_Base_5",
        },
        SWORDS = {
            Random = {"SWORDS_STARBASE_1", "SWORDS_STARBASE_2", "SWORDS_STARBASE_3"},
            Starting = "SWORDS_STARBASE_3"
        },
        TERRORISTS = {
            Random = {"Terrorists_Star_Base_1", "Terrorists_Star_Base_2", "Terrorists_Star_Base_3"},
            Starting = "Terrorists_Star_Base_3",
        },
    },

    Starting_Units = {
        REBEL = "UNSC_HALCYON",
        EMPIRE = "COVN_CCS",
        SWORDS = "SWORDS_CCS",
        TERRORISTS = "TERROR_HALCYON"
    },

    Planet_List = {},

    Neutral = nil,

    Human = nil,

    Finished = false
}

function Random_Start:Clear_Starting_Planets()

    for _, Faction_Entry in pairs(self.Spawn_List) do
        local Faction = Find_Player(Faction_Entry.Name)

        if TestValid(Faction) then
            local Unit_To_Find = self.Starting_Units[string.upper(Faction.Get_Faction_Name())]

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
    end
end

function Random_Start:Start()

    if self.Finished then
        return
    end

    local Planets = Planet_Table:Return_All_Keys()

    for _, Planet_Name in pairs(Planets) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            table.insert(self.Planet_List, Planet)
        end
    end

    self.Neutral = Find_Player("Neutral")

    self:Clear_Starting_Planets()

    self.Human = Find_Human_Player()

    self:Human_Random_Start()

    for _, Faction_Info in pairs(self.Spawn_List) do
        local Player = Find_Player(Faction_Info.Name)

        if TestValid(Player) then
            if not Player.Is_Human() then
                self:Fill_Random_Start(Player, Faction_Info.Control_Percentage)
            end
        end
    end

    self.Finished = true
end

function Random_Start:Is_Finished()
    return self.Finished
end

function Random_Start:Set_Starting_Planet_Count(Count)
    if type(Count) ~= "number" then
        Count = 1
    end

    self.Total_Major_Starting_Planets = Count
end

function Random_Start:Human_Random_Start()
    if not TestValid(self.Human) then
        return
    end

    local Human_Planets = 0

    local attempts = 0

    while Human_Planets < self.Total_Major_Starting_Planets and attempts < 10 do

        local Random_Planet = Random_From_List(self.Planet_List)

        local attempts_y = 0

        local Valid_Planet = false

        while not Valid_Planet and attempts_y < 10 do

            if TestValid(Random_Planet) then
                if Random_Planet.Get_Owner() == self.Neutral then
                    Valid_Planet = true
                    break
                end
            end

            Random_Planet = Random_From_List(self.Planet_List)

            attempts_y = attempts_y + 1
        end

        if TestValid(Random_Planet) then
            Random_Planet.Change_Owner(self.Human)

            self:Spawn_Space_Station(Random_Planet, self.Human, true)

            Human_Planets = Human_Planets + 1
        end

        attempts = attempts + 1
    end
end

function Random_Start:Fill_Random_Start(Player, Control_Percentage)

    if not TestValid(Player) then
        return
    end

    if type(Control_Percentage) ~= "number" then
        return
    end

    local New_Planet_List = {}

    for _, Planet in pairs(self.Planet_List) do
        if TestValid(Planet) then
            if Planet.Get_Owner() == self.Neutral then
                table.insert(New_Planet_List, Planet)
            end
        end
    end

    local Planets_To_Control = tonumber(Dirty_Floor(tableLength(New_Planet_List) * Control_Percentage))

    if Planets_To_Control > 0 then
        local Controlled_Planets = 0

        local attempts = 0

        while Controlled_Planets < Planets_To_Control and attempts < 50 do
            local Random_Planet = Random_From_List(New_Planet_List)

            local Is_Valid_Spawn = false

            local attempts_y = 0

            while not Is_Valid_Spawn and attempts_y < 10 do
                if TestValid(Random_Planet) then
                    if Random_Planet.Get_Owner() == self.Neutral then
                        Is_Valid_Spawn = true
                        break
                    end
                end

                Random_Planet = Random_From_List(New_Planet_List)

                attempts_y = attempts_y + 1
            end

            if TestValid(Random_Planet) then
                Random_Planet.Change_Owner(Player)

                self:Spawn_Space_Station(Random_Planet, Player)

                Controlled_Planets = Controlled_Planets + 1
            end

            attempts = attempts + 1
        end
    end
end

function Random_Start:Spawn_Space_Station(Planet, Player, Is_Starting)
    if not TestValid(Planet) then
        return
    end

    if not TestValid(Player) then
        return 
    end

    local Station_Entry = self.Starbases[string.upper(Player.Get_Faction_Name())]

    if Station_Entry == nil then
        return
    end

    if Is_Starting then
        local Station = Station_Entry.Starting

        if Station ~= nil then
            local Station_Type = Find_Object_Type(Station)

            if Station_Type ~= nil then
                Spawn_Unit(Station_Type, Planet, Player)
            end
        end
    else
        local Random_Starbases = Station_Entry.Random

        if Random_Starbases ~= nil then
            local Random_Starbase = Random_From_List(Random_Starbases)

            if Random_Starbase ~= nil then
                local Random_Starbase_Type = Find_Object_Type(Random_Starbase)

                if Random_Starbase_Type ~= nil then
                    Spawn_Unit(Random_Starbase_Type, Planet, Player)
                end
            end
        end
    end
end


return Random_Start