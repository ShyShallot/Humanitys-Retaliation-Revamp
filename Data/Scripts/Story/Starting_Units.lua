-- Script Written by ShyShallot

---@class Spawn_Unit_Table
---@field Weight number
---@field Limit number

---@class Station_Power_Entry
---@field Space number
---@field Ground number

---@class Station_Spawn_Entry
---@field Power Station_Power_Entry
---@field Structures string[]
---@field Space_Units table<string, Spawn_Unit_Table>
---@field Ground_Units table<string, Spawn_Unit_Table>
---@field Spawn_Layout table

---@class Faction_Spawn_Entry
---@field Station table<string, Station_Spawn_Entry>
---@field Heroes? string[]
---@field Special_Units? table
---@field Planets PlanetObject[]
---@field Mapping table[]
---@field Faction PlayerWrapper

---@class Spawn_Setting
---@field Global_Multiplier number
---@field Spawn_Variations number 
---@field Factions table<string, Faction_Spawn_Entry>



---@class Starting_Units_Handler
Starting_Units_Handler = {

    Spawn_Settings_Map = {
        ["SANDBOX_HALO_EVOLVED_UNSC"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_EVOLVED_INNIES"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_EVOLVED_COVENANT"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_EVOLVED_SWORDS"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_RANDOM_SINGLE_UNSC"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_RANDOM_SINGLE_COVN"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_RANDOM_DOUBLE_UNSC"] = "Starting_Units_Definitions/Default",
        ["SANDBOX_HALO_RANDOM_DOUBLE_COVN"] = "Starting_Units_Definitions/Default",
    },

    Global_Unit_Table = nil,

    Global_Planet_Table = nil,

    Finished = false,

    Banned_Structures = {},

    Unit_Type_Cache = {},

    Unit_Power_Cache = {},
}

function Starting_Units_Handler:Start(Map_Name, skip, player_only)

    if type(Map_Name) ~= "string" then
        return
    end

    if skip then
        self.Finished = true

        return
    end

    if player_only ~= true then
        player_only = false
    end

    DebugMessage("%s -- Map Name: %s", tostring(Script), tostring(Map_Name))

    local Settings_File = self.Spawn_Settings_Map[Map_Name]

    DebugMessage("%s -- Settings File: %s", tostring(Script), tostring(Settings_File))

    ---@type Spawn_Setting|nil
    local Spawn_Settings = require(Settings_File)

    if Spawn_Settings == nil then
        return
    end

    DebugMessage("%s -- Starting Random Unit Spawn",tostring(Script))

    Spawn_Settings.Factions.UNSC.Mapping[0] = Spawn_Settings.Factions.UNSC.Station.Default -- The Index defined is the Space Station Level of the planet
    Spawn_Settings.Factions.UNSC.Mapping[1] = Spawn_Settings.Factions.UNSC.Station.Low
    Spawn_Settings.Factions.UNSC.Mapping[2] = Spawn_Settings.Factions.UNSC.Station.Low -- for example the Level 2 Space Station will use the same template as a level 1 space station
    Spawn_Settings.Factions.UNSC.Mapping[3] = Spawn_Settings.Factions.UNSC.Station.Medium
    Spawn_Settings.Factions.UNSC.Mapping[4] = Spawn_Settings.Factions.UNSC.Station.High
    Spawn_Settings.Factions.UNSC.Mapping[5] = Spawn_Settings.Factions.UNSC.Station.Ultra

    Spawn_Settings.Factions.COVN.Mapping[0] = Spawn_Settings.Factions.COVN.Station.Default
    Spawn_Settings.Factions.COVN.Mapping[1] = Spawn_Settings.Factions.COVN.Station.Low
    Spawn_Settings.Factions.COVN.Mapping[2] = Spawn_Settings.Factions.COVN.Station.Low
    Spawn_Settings.Factions.COVN.Mapping[3] = Spawn_Settings.Factions.COVN.Station.Medium
    Spawn_Settings.Factions.COVN.Mapping[4] = Spawn_Settings.Factions.COVN.Station.High
    Spawn_Settings.Factions.COVN.Mapping[5] = Spawn_Settings.Factions.COVN.Station.Ultra

    Spawn_Settings.Factions.Swords.Mapping[0] = Spawn_Settings.Factions.Swords.Station.Default
    Spawn_Settings.Factions.Swords.Mapping[1] = Spawn_Settings.Factions.Swords.Station.Low
    Spawn_Settings.Factions.Swords.Mapping[2] = Spawn_Settings.Factions.Swords.Station.Low
    Spawn_Settings.Factions.Swords.Mapping[3] = Spawn_Settings.Factions.Swords.Station.Medium -- Minor factions dont have space station levels higher than 3

    Spawn_Settings.Factions.Terror.Mapping[0] = Spawn_Settings.Factions.Terror.Station.Default
    Spawn_Settings.Factions.Terror.Mapping[1] = Spawn_Settings.Factions.Terror.Station.Low
    Spawn_Settings.Factions.Terror.Mapping[2] = Spawn_Settings.Factions.Terror.Station.Low
    Spawn_Settings.Factions.Terror.Mapping[3] = Spawn_Settings.Factions.Terror.Station.Medium

    self.Global_Unit_Table = require("globalUnitTable")

    self.Global_Planet_Table = require("globalPlanetTable")

    Spawn_Settings.Factions.UNSC.Faction = Find_Player("Rebel")

    Spawn_Settings.Factions.COVN.Faction = Find_Player("Empire")

    Spawn_Settings.Factions.Swords.Faction = Find_Player("Swords")

    Spawn_Settings.Factions.Terror.Faction = Find_Player("TERRORISTS")

    for Faction, Entry in pairs(Spawn_Settings.Factions) do

        for _, Station in pairs(Entry.Station) do

            local Space_Distribution = DiscreteDistribution.Create()

            local Unit_Limits = {}

            if Station.Space_Units then
                for unit, entry in pairs(Station.Space_Units) do

                    local weight = entry.Weight or 50

                    Unit_Limits[unit] = entry.Limit or -1

                    Space_Distribution.Insert(unit,weight)

                    self:Get_Unit_Type(unit)
                end
            end

            Station.Spawn_Layout = {}

            Station.Spawn_Layout.Space = {}

            local Total_Space_Variations = 0

            while Total_Space_Variations < Spawn_Settings.Spawn_Variations do
                Station.Spawn_Layout.Space[Total_Space_Variations + 1] = self:Calculate_Spawn_Variation(Spawn_Settings, Station, Space_Distribution, Unit_Limits)

                DebugMessage("%s -- New Space Spawn Variation: %s", tostring(Script), tostring(Station.Spawn_Layout.Space[Total_Space_Variations + 1]))

                Total_Space_Variations = Total_Space_Variations + 1
            end

            local Ground_Distribution = DiscreteDistribution.Create()

            if Station.Ground_Units then
                for unit, entry in pairs(Station.Ground_Units) do

                    local weight = entry.Weight or 50

                    Unit_Limits[unit] = entry.Limit or -1

                    Ground_Distribution.Insert(unit,weight)

                    self:Get_Unit_Type(unit)
                end
            end

            Station.Spawn_Layout.Ground = {}

            local Total_Ground_Variations = 0

            while Total_Ground_Variations < Spawn_Settings.Spawn_Variations do
                Station.Spawn_Layout.Ground[Total_Ground_Variations + 1] = self:Calculate_Spawn_Variation(Spawn_Settings, Station, Ground_Distribution, Unit_Limits, true)

                DebugMessage("%s -- New Ground Spawn Variation: %s", tostring(Script), tostring(Station.Spawn_Layout.Ground[Total_Ground_Variations + 1]))

                Total_Ground_Variations = Total_Ground_Variations + 1
            end

        end
    end

    for _,planet_name in pairs(self.Global_Planet_Table:Return_All_Keys()) do

        local planet = FindPlanet(planet_name)

        --DebugMessage("%s -- Starbase Level: %s",tostring(Script),tostring(planet.Get_Starbase_Level()))

        local Spawn_Entry = self:Get_Spawn_Entry(planet, Spawn_Settings)

        --DebugMessage("%s -- Spawn Entry for Planet %s: %s",tostring(Script),tostring(planet),tostring(Spawn_Entry))

        if Spawn_Entry ~= nil then

            local Starbase_Level = planet.Get_Starbase_Level()

            local Settings = Spawn_Entry.Mapping[Starbase_Level]

            if Settings == nil then
                Settings = Spawn_Entry.Station.Default
            end

            --DebugMessage("%s -- Starbase Level: %s,Settings: %s",tostring(Script),tostring(Starbase_Level),tostring(Settings))

            if Settings ~= nil then

                for _,structure in pairs(Settings.Structures) do

                    if type(structure) == "table" then

                        if self.Banned_Structures[structure.Name] == nil then

                            for i=1,structure.Amount,1 do

                                self:Spawn_Structure(structure.Name,planet)

                            end
                        end
                    else
                        if self.Banned_Structures[structure] == nil then
                            self:Spawn_Structure(structure,planet)
                        end
                    end

                end

                if Settings.Spawn_Layout ~= nil then
                
                    local is_valid = true

                    if player_only and not planet.Get_Owner().Is_Human() then
                        is_valid = false
                    end

                    if Settings.Spawn_Layout.Space ~= nil and Settings.Spawn_Layout.Ground ~= nil and is_valid then
                        local Space_Variation = EvenMoreRandom(1, tableLength(Settings.Spawn_Layout.Space))
                        local Ground_Variation = EvenMoreRandom(1, tableLength(Settings.Spawn_Layout.Ground))

                        self:Spawn_From_List(Settings.Spawn_Layout.Space[Space_Variation], planet)
                        self:Spawn_From_List(Settings.Spawn_Layout.Ground[Ground_Variation], planet)
                    end
                end
 
            end
        end
    end

    for faction,entry in pairs(Spawn_Settings.Factions) do -- Hero Spawn

        local planet_list = entry.Planets

        if planet_list ~= nil and table.getn(planet_list) > 0 then

            if entry.Heroes ~= nil then
                for _,hero in pairs(entry.Heroes) do

                    local hero_type = self:Get_Unit_Type(hero)

                    if hero_type ~= nil then

                        local planet = Random_From_List(planet_list)

                        if TestValid(planet) then
                            Spawn_Unit(hero_type,planet,entry.Faction)
                        end
                    end
                end
            end

            if entry.Special_Units ~= nil then

                for _,special_unit in pairs(entry.Special_Units) do
                    self:Special_Unit_Spawn_Filter(special_unit,planet_list,entry.Faction)
                end
            end
        end

        local All_Spawned_Units = Find_All_Objects_Of_Type(entry.Faction)

        for _, unit in pairs(All_Spawned_Units) do
            if TestValid(unit) then
                unit.Prevent_AI_Usage(false)
            end
        end
    end

    self.Finished = true
end

function Starting_Units_Handler:Calculate_Spawn_Variation(Spawn_Settings, Settings, Mapping, Unit_Limits, Is_Ground)

    if Mapping == nil then
        return {}
    end

    local Current_Power = 0

    local attempts = 0

    local Spawned_Units = {
        Total = 0,
        Units = {}
    }

    local Spawn_List = Settings.Space_Units

    local Max_Power = tonumber(Dirty_Floor(Settings.Power.Space * Spawn_Settings.Global_Multiplier))

    if Is_Ground == true then
        Spawn_List = Settings.Ground_Units

        Max_Power = tonumber(Dirty_Floor(Settings.Power.Ground * Spawn_Settings.Global_Multiplier))
    end

    if type(Max_Power) ~= "number" then
        return
    end

    if Spawn_List == nil then
        return {}
    end

    local Unit_Count = {}

    for Unit, _ in pairs(Spawn_List) do
        Unit_Count[Unit] = 0
    end

    while Current_Power < Max_Power and attempts < 50 do

        if Spawned_Units.Total >= 10 and Is_Ground then
            attempts = 10000
            break
        end

        local Unit = Mapping.Sample()

        local Unit_Entry = self:Get_Unit_Entry(Unit)

        if Unit_Entry ~= nil then

            local Is_Valid_Spawn = true

            if Unit_Limits[Unit] == 0 then
                Is_Valid_Spawn = false
            end

            if Spawned_Units.Units[Unit] ~= nil then
                if Unit_Limits[Unit] > 0 and Spawned_Units.Units[Unit] >= Unit_Limits[Unit] then
                    Is_Valid_Spawn = false
                end
            end

            if Is_Valid_Spawn then

                local Unit_Power = self:Get_Combat_Power(Unit)

                Unit_Count[Unit] = Unit_Count[Unit] + 1

                if Spawned_Units.Units[Unit] == nil then
                    Spawned_Units.Units[Unit] = 0
                end

                Spawned_Units.Total = Spawned_Units.Total + 1

                Spawned_Units.Units[Unit] = Spawned_Units.Units[Unit] + 1

                Current_Power = Current_Power + Unit_Power

            end

        end

        attempts = attempts + 1
    end

    return Unit_Count
end

function Starting_Units_Handler:Spawn_Structure(structure,planet)

    if structure == nil then
        return
    end

    if not TestValid(planet) then
        return
    end

    local structure_type = self:Get_Unit_Type(structure)

    if structure_type ~= nil then

        --DebugMessage("%s -- Spawning Structure: %s",tostring(Script),tostring(structure))

        Spawn_Unit(structure_type,planet,planet.Get_Owner())
    end
end

function Starting_Units_Handler:Get_Spawn_Entry(planet, Spawn_Settings)

    if not TestValid(planet) then
        return nil
    end

    local Planet_Owner = planet.Get_Owner()

    --DebugMessage("%s -- Planet: %s,Owner: %s",tostring(Script),tostring(planet),tostring(Planet_Owner.Get_Faction_Name()))

    for faction,entry in pairs(Spawn_Settings.Factions) do

        --DebugMessage("%s -- Entry Faction: %s",tostring(Script),tostring(entry.Faction))

        if entry.Faction == Planet_Owner then

            table.insert(entry.Planets,planet)

            return entry
        end
    end

    return nil
end

function Starting_Units_Handler:Get_Unit_Entry(unit_name)

    if unit_name == nil then
        return nil
    end

    if self.Global_Unit_Table == nil then
        return nil
    end

    return self.Global_Unit_Table[unit_name]
end

function Starting_Units_Handler:Is_Finished()
    return self.Finished
end

function Starting_Units_Handler:Add_Banned_Structures(structures)

    if type(structures) == "string" then -- Allow the passing of a single structure,then format it into a table
        local temp = structures

        structures = {temp}
    end

    if type(structures) ~= "table" then
        return
    end

    for _,structure in pairs(structures) do
        self.Banned_Structures[structure] = true
    end
end

function Starting_Units_Handler:Special_Unit_Spawn_Filter(special_entry,planet_list,faction)
    if special_entry == nil then
        return nil
    end

    DebugMessage("%s -- Attempting Special Unit Spawn for %s",tostring(Script),tostring(special_entry.Unit))

    if special_entry.Filter == nil or special_entry.Filter.Type == "None" then
        DebugMessage("%s -- Special Unit has No Filter",tostring(Script))
        self:Special_Unit_Spawn(special_entry,planet_list,faction)
        return
    end

    if special_entry.Filter.Type == "Station" and (type(special_entry.Filter.Value) == "number" or type(special_entry.Filter.Value) == "table") then
        local Filter_Value_Type = type(special_entry.Filter.Value)

        local filtered_planet_table = {}

        if Filter_Value_Type == "number" then
            DebugMessage("%s -- Special Unit Filter: Station,Type Level %s",tostring(Script),tostring(special_entry.Filter.Value))
            if special_entry.Filter.Value > 0 and special_entry.Filter.Value < 6 then
                for _,planet in pairs(planet_list) do
                    if TestValid(planet) then
                        DebugMessage("%s -- %s Station Level: %s,Comparing to: %s",tostring(Script),tostring(planet),tostring(planet.Get_Starbase_Level()),tostring(special_entry.Filter.Value))
                        if planet.Get_Starbase_Level() == special_entry.Filter.Value then
                            DebugMessage("%s -- Adding %s to Filtered List",tostring(Script),tostring(planet))
                            table.insert(filtered_planet_table,planet)
                        end
                    end
                end
            end
        elseif Filter_Value_Type == "table" then
            DebugMessage("%s -- Special Unit Filter: Station,Type Range",tostring(Script))
            PrintTable(special_entry.Filter.Value)
            for _,planet in pairs(planet_list) do
                if TestValid(planet) then
                    local planet_station_level = planet.Get_Starbase_Level()
                    DebugMessage("%s -- Planet %s Station Level: %s,Is in Filter: %s",tostring(Script),tostring(planet),tostring(planet_station_level),tostring(special_entry.Filter.Value[planet_station_level + 1]))
                    if special_entry.Filter.Value[planet_station_level + 1] == true then
                        DebugMessage("%s -- Adding %s to Filtered List",tostring(Script),tostring(planet))
                        table.insert(filtered_planet_table,planet)
                    end
                end
            end
        end

        DebugMessage("%s -- Final Filtered Table",tostring(Script))
        PrintTable(filtered_planet_table)

        self:Special_Unit_Spawn(special_entry,filtered_planet_table,faction)

        return
    end

    if special_entry.Filter.Type == "Power" then
        --DebugMessage("%s -- Special Unit Filter: Power",tostring(Script))
        local filtered_planet_table = {}
        if special_entry.Filter.Value  then -- if true,we are looking for the weakest planet,if false we are looking for the strongest
            --DebugMessage("%s -- Looking for Weakest Planet",tostring(Script))
            local weakest_power = 1000000000
            local weakest_planet = nil

            for _,planet in pairs(planet_list) do
                local power = EvaluatePerception("Planet_Force_Strength",planet.Get_Owner(),planet) -- in terms of space power,ground is not considered

                if power < weakest_power then
                    weakest_power = power
                    weakest_planet = planet
                end
            end

            --DebugMessage("%s -- Found Weakest Planet: %s" ,tostring(Script),tostring(weakest_planet))

            if TestValid(weakest_planet) then
                self:Special_Unit_Spawn(special_entry,{weakest_planet},faction)
            end
        else
            --DebugMessage("%s -- Looking for Strongest Planet",tostring(Script))
            local strongest_power = 0
            local strongest_planet = nil

            for _,planet in pairs(planet_list) do
                local power = EvaluatePerception("Planet_Force_Strength",planet.Get_Owner(),planet) -- in terms of space power,ground is not considered

                if power > strongest_power then
                    strongest_power = power
                    strongest_planet = planet
                end
            end

            --DebugMessage("%s -- Found Strongest Planet: %s",tostring(Script),tostring(strongest_planet))

            if TestValid(strongest_planet) then
                self:Special_Unit_Spawn(special_entry,{strongest_planet},faction)
            end
        end
    end

end

function Starting_Units_Handler:Special_Unit_Spawn(special_entry,planet_list,faction)

    if special_entry == nil then
        return
    end

    if special_entry.Unit == nil then
        return
    end

    if special_entry.Count < 1 then
        return
    end

    if tableLength(planet_list) < 1 then
        return
    end

    if faction == nil then
        return
    end

    local Unit_Type = self:Get_Unit_Type(special_entry.Unit)

    --DebugMessage("%s -- Spawning %s %s for %s",tostring(Script),tostring(special_entry.Count),tostring(special_entry.Unit),tostring(faction.Get_Faction_Name()))

    --DebugMessage("%s -- Found Unit Type: %s",tostring(Script),tostring(Unit_Type))

    if Unit_Type ~= nil and special_entry.Count > 0 then
        local spawned = 0

        while spawned < special_entry.Count do
            local planet = Random_From_List(planet_list)

            --DebugMessage("%s -- Selected %s,Spawn Count: %s for %s",tostring(Script),tostring(planet),tostring(spawned + 1),tostring(special_entry.Unit))

            if TestValid(planet) then
                --DebugMessage("%s -- Planet Was valid,spawning",tostring(Script))
                Spawn_Unit(Unit_Type,planet,faction)
            end

            spawned = spawned + 1
        end
    end
end

function Starting_Units_Handler:Get_Unit_Type(unit_name)

    if unit_name == nil then
        return nil
    end

    local cached = self.Unit_Type_Cache[unit_name]

    if cached ~= nil then
        return cached
    end

    local unit_type = Find_Object_Type(unit_name)
    
    self.Unit_Type_Cache[unit_name] = unit_type

    return unit_type
end

function Starting_Units_Handler:Get_Combat_Power(unit_name)

    if unit_name == nil then
        return 0
    end

    local cached = self.Unit_Power_Cache[unit_name]

    if cached ~= nil then
        return cached
    end

    local unit_type = self:Get_Unit_Type(unit_name)

    if unit_type == nil then
        return 0
    end

    local rating = unit_type.Get_Combat_Rating()

    self.Unit_Power_Cache[unit_name] = rating

    return rating
end

function Starting_Units_Handler:Spawn_From_List(Spawn_List, Planet)

    DebugMessage("%s -- Spawning List %s on Planet: %s", tostring(Script), tostring(Spawn_List),tostring(Planet))

    PrintTable(Spawn_List)

    if Spawn_List == nil then
        return
    end

    if not TestValid(Planet) then
        return
    end

    local Owner = Planet.Get_Owner()

    for Unit, Amount in pairs(Spawn_List) do

        local Unit_Type = self:Get_Unit_Type(Unit)

        if type(Unit) == "string" and type(Amount) == "number" and Unit_Type ~= nil then
            for i=Amount, 1, -1 do
                Spawn_Unit(Unit_Type, Planet, Owner)
            end
        end
    end
end

function Starting_Units_Handler:Set_Spawn_Variations(Spawn_Settings, Spawn_Variations_Count)
    if type(Spawn_Variations_Count) ~= "number" then
        return
    end

    if Spawn_Variations_Count < 1 then
        Spawn_Variations_Count = 1
    end

    if Spawn_Variations_Count > 20 then
        Spawn_Variations_Count = 20
    end
    
    Spawn_Settings.Spawn_Variations = Spawn_Variations_Count
end

return Starting_Units_Handler