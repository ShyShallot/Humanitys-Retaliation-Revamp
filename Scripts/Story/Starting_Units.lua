-- Script Written by ShyShallot
Starting_Units_Handler = {
    Spawn_Settings = {
        Category_Mapping = nil, -- this is filled in later with a weighted table in Global_Story OnEnter
        Global_Multiplier = 1.75, -- Max Combat Power multiplier
        Factions = { 
            UNSC = {
                Station = {
                    Default = {
                        Power = 10000,
                        Structures = {},
                        Units = {"Rebel_Infantry_Squad", "Rebel_Tank_Buster_Squad", "Rebel_Pod_Walker_Company", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "UNSC_SINGLE_BUCKLER"}
                    },
                    Low = {
                        Power = 15000,
                        Structures = {},
                        Units = {"Rebel_Infantry_Squad", "Rebel_Tank_Buster_Squad", "Rebel_Pod_Walker_Company", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "UNSC_SINGLE_BUCKLER"}
                    },
                    Medium = {
                        Power = 45000,
                        Structures = {},
                        Units = {"Rebel_Infantry_Squad", "Rebel_Tank_Buster_Squad", "Rebel_Pod_Walker_Company", "UNSC_EPOCH", "UNSC_PHOENIX"}
                    },
                    High = {
                        Power = 45000,
                        Structures = {},
                        Units = {"MAKO_SQUADRON", "GLADIUS_SQUADRON", "UNSC_SINGLE_BUCKLER", "UNSC_EPOCH", "UNSC_PHOENIX"}
                    },
                    Ultra = {
                        Power = 45000,
                        Structures = {},
                        Units = {"MAKO_SQUADRON", "GLADIUS_SQUADRON", "UNSC_SINGLE_BUCKLER", "UNSC_EPOCH", "UNSC_PHOENIX"}
                    }
                },
                Heroes = {
                    "UNSC_SOF", 
                    "UNSC_IAC",
                    "UNSC_ROMAN_BLUE"
                },
                Special_Units = {},
                Planets = {},
                Mapping = {},
            },
            COVN = {
                Station = {
                    Default = {
                        Power = 25000,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "CRS_SQUADRON"}
                    },
                    Low = {
                        Power = 30500,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "SDV_SQUADRON", "CRS_SQUADRON"}
                    },
                    Medium = {
                        Power = 60000,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "SDV_SQUADRON", "CRS_SQUADRON", "COVN_RCS"}
                    },
                    High = {
                        Power = 120500,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "COVN_RCS", "COVN_CCS", "COVN_DDS", "COVN_ORS", "COVN_CAS"}
                    },
                    Ultra = {
                        Power = 185000,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "SDV_SQUADRON", "CRS_SQUADRON", "COVN_RCS", "COVN_CCS", "COVN_DDS", "COVN_ORS", "COVN_CAS"}
                    }
                },
                Heroes = {
                    "COVN_PIOUS",
					"COVN_MACCABEUS",
                },
                Special_Units = { -- could work for structures as well
                    {Count = 1, Unit = "COVN_CSO", Filter = {Type = "Station", Value = {false, false, false, false, true, true}}} -- the Value Table is the Acceptable Station Levels, 0, 1, 2, 3, 4, 5, if it is true it will spawn at that level, in this usage, it will only spawn at level 4 and 5
                    --{Count = 1, Unit = "COVN_CSO", Filter = {Type = "Power", Value = false}} -- Would Spawn 1 CSO on the strongest planet calculated via space unit strength
                    --{Count = 1, Unit = "COVN_CSO"} -- Spawns a CSO on a random controlled planet
                },
                Planets = {},
                Mapping = {},
            },
            Swords = {
                Station = {
                    Default = {
                        Power = 20000,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "SWORDS_CRS", "SWORDS_CCS", "SWORDS_CAS"}
                    },
                    Low = {
                        Power = 55500,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "SWORDS_SDV","SWORDS_CRS", "SWORDS_CCS", "SWORDS_CAS"}
                    },
                    Medium = {
                        Power = 65000,
                        Structures = {},
                        Units = {"Imperial_Stormtrooper_Squad", "SWORDS_SDV", "SWORDS_CRS", "SWORDS_CCS", "SWORDS_CAS"}
                    }
                },
                Planets = {},
                Mapping = {},
            },
            Terror = {
                Station = {
                    Default = {
                        Power = 9000,
                        Structures = {},
                        Units = {"Rebel_Infantry_Squad", "TERROR_MAKO_SQUADRON", "TERROR_GLADIUS_SQUADRON", "TERROR_PHOENIX"}
                    },
                    Low = {
                        Power = 15000,
                        Structures = {},
                        Units = {"Rebel_Infantry_Squad", "TERROR_MAKO_SQUADRON", "TERROR_GLADIUS_SQUADRON", "TERROR_PHOENIX"}
                    },
                    Medium = {
                        Power = 25000,
                        Structures = {},
                        Units = {"Rebel_Infantry_Squad", "TERROR_MAKO_SQUADRON", "TERROR_GLADIUS_SQUADRON", "TERROR_PHOENIX"}
                    }
                },
                Planets = {},
                Mapping = {},
            }
        }
    },

    Global_Unit_Table = nil,

    Finished = false,

    Banned_Structures = {}
}

function Starting_Units_Handler:Start()

    DebugMessage("%s -- Starting Random Unit Spawn", tostring(Script))

    self.Spawn_Settings.Factions.UNSC.Mapping[0] = self.Spawn_Settings.Factions.UNSC.Station.Default -- The Index defined is the Space Station Level of the planet
    self.Spawn_Settings.Factions.UNSC.Mapping[1] = self.Spawn_Settings.Factions.UNSC.Station.Low 
    self.Spawn_Settings.Factions.UNSC.Mapping[2] = self.Spawn_Settings.Factions.UNSC.Station.Low -- for example the Level 2 Space Station will use the same template as a level 1 space station
    self.Spawn_Settings.Factions.UNSC.Mapping[3] = self.Spawn_Settings.Factions.UNSC.Station.Medium
    self.Spawn_Settings.Factions.UNSC.Mapping[4] = self.Spawn_Settings.Factions.UNSC.Station.High
    self.Spawn_Settings.Factions.UNSC.Mapping[5] = self.Spawn_Settings.Factions.UNSC.Station.Ultra

    self.Spawn_Settings.Factions.COVN.Mapping[0] = self.Spawn_Settings.Factions.COVN.Station.Default
    self.Spawn_Settings.Factions.COVN.Mapping[1] = self.Spawn_Settings.Factions.COVN.Station.Low
    self.Spawn_Settings.Factions.COVN.Mapping[2] = self.Spawn_Settings.Factions.COVN.Station.Low
    self.Spawn_Settings.Factions.COVN.Mapping[3] = self.Spawn_Settings.Factions.COVN.Station.Medium
    self.Spawn_Settings.Factions.COVN.Mapping[4] = self.Spawn_Settings.Factions.COVN.Station.High
    self.Spawn_Settings.Factions.COVN.Mapping[5] = self.Spawn_Settings.Factions.COVN.Station.Ultra

    self.Spawn_Settings.Factions.Swords.Mapping[0] = self.Spawn_Settings.Factions.Swords.Station.Default
    self.Spawn_Settings.Factions.Swords.Mapping[1] = self.Spawn_Settings.Factions.Swords.Station.Low
    self.Spawn_Settings.Factions.Swords.Mapping[2] = self.Spawn_Settings.Factions.Swords.Station.Low
    self.Spawn_Settings.Factions.Swords.Mapping[3] = self.Spawn_Settings.Factions.Swords.Station.Medium -- Minor factions dont have space station levels higher than 3

    self.Spawn_Settings.Factions.Terror.Mapping[0] = self.Spawn_Settings.Factions.Terror.Station.Default
    self.Spawn_Settings.Factions.Terror.Mapping[1] = self.Spawn_Settings.Factions.Terror.Station.Low
    self.Spawn_Settings.Factions.Terror.Mapping[2] = self.Spawn_Settings.Factions.Terror.Station.Low
    self.Spawn_Settings.Factions.Terror.Mapping[3] = self.Spawn_Settings.Factions.Terror.Station.Medium

    self.Global_Unit_Table = require("globalUnitTable")

    self.Spawn_Settings.Category_Mapping = DiscreteDistribution.Create() -- Higher Number, higher chance of being selected
	
	self.Spawn_Settings.Category_Mapping.Insert("Infantry", 4)

    self.Spawn_Settings.Category_Mapping.Insert("Vehicle", 3)

    self.Spawn_Settings.Category_Mapping.Insert("Fighter", 35)

    self.Spawn_Settings.Category_Mapping.Insert("Corvette", 30)
    
    self.Spawn_Settings.Category_Mapping.Insert("Frigate", 30)

    self.Spawn_Settings.Category_Mapping.Insert("Capital", 5)

    self.Spawn_Settings.Category_Mapping.Insert("Super", 2)

    self.Spawn_Settings.Factions.UNSC.Faction = Find_Player("Rebel")

    self.Spawn_Settings.Factions.COVN.Faction = Find_Player("Empire")

    self.Spawn_Settings.Factions.Swords.Faction = Find_Player("Swords")

    self.Spawn_Settings.Factions.Terror.Faction = Find_Player("TERRORISTS")

    local planets = FindPlanet.Get_All_Planets()

    for _, planet in pairs(planets) do

        --DebugMessage("%s -- Starbase Level: %s", tostring(Script), tostring(planet.Get_Starbase_Level()))

        local Spawn_Entry = self:Get_Spawn_Entry(planet)

        --DebugMessage("%s -- Spawn Entry for Planet %s: %s", tostring(Script), tostring(planet), tostring(Spawn_Entry))

        if Spawn_Entry ~= nil then

            local Starbase_Level = planet.Get_Starbase_Level()

            local Settings = Spawn_Entry.Mapping[Starbase_Level]

            if Settings == nil then
                Settings = Spawn_Entry.Station.Default
            end

            --DebugMessage("%s -- Starbase Level: %s, Settings: %s", tostring(Script), tostring(Starbase_Level), tostring(Settings))

            if Settings ~= nil then

                local Planet_Power = 0

                for _, structure in pairs(Settings.Structures) do

                    if type(structure) == "table" then

                        if self.Banned_Structures[structure.Name] == nil then

                            for i=1, structure.Amount, 1 do

                                self:Spawn_Structure(structure.Name, planet)

                            end
                        end
                    else
                        if self.Banned_Structures[structure] == nil then 
                            self:Spawn_Structure(structure, planet)
                        end
                    end
                    
                end

                local attempts = 0

                while Planet_Power < tonumber(Dirty_Floor((Settings.Power * self.Spawn_Settings.Global_Multiplier))) and attempts < 50 do

                    --DebugMessage("%s -- Planet Power: %s, Max Power: %s", tostring(Script), tostring(Planet_Power), tostring(Settings.Power))

                    local Category = self.Spawn_Settings.Category_Mapping.Sample()

                    --DebugMessage("%s -- Selected Category: %s", tostring(Script), tostring(Category))

                    for _, unit in pairs(Settings.Units) do

                        local Unit_Entry = self:Get_Unit_Entry(unit)

                        local Unit_Type = Find_Object_Type(unit)

                        --DebugMessage("%s -- Current Unit: %s, Unit Entry: %s, Type: %s", tostring(Script), tostring(unit), tostring(Unit_Entry), tostring(Unit_Type))

                        if Unit_Entry ~= nil and Unit_Type ~= nil then

                            local Unit_Category = Unit_Entry.Category

                            --DebugMessage("%s -- Spawn Chance: %s, Unit Count: %s, Base Chance: %s, Per Unit Chance Drop: %s", tostring(Script), tostring(Spawn_Chance), tostring(Unit_Count), tostring(Spawn_Chance_Settings.Chance), tostring(Spawn_Chance_Settings.Per_Unit_Chance_Drop))
                            
                            local Unit_Power = Unit_Type.Get_Combat_Rating()
                            
                            --DebugMessage("%s -- Unit Category: %s, Spawn Chance: %s %%, Unit Power: %s", tostring(Script), tostring(Unit_Category), tostring(Spawn_Chance), tostring(Unit_Power))
                            
                            if Unit_Category == Category then

                                --DebugMessage("%s -- Spawned a %s, at %s", tostring(Script), tostring(unit), tostring(planet))

                                local spawned_unit = Spawn_Unit(Unit_Type, planet, planet.Get_Owner())

                                if spawned_unit ~= nil then
                                    for _, unit in pairs(spawned_unit) do
                                        unit.Prevent_AI_Usage(false)
                                    end
                                end
                                
                                Planet_Power = Planet_Power + Unit_Power
                            end
                        end
                    end

                    attempts = attempts + 1
                end
            end
        end
    end

    for faction, entry in pairs(self.Spawn_Settings.Factions) do -- Hero Spawn

        local planet_list = entry.Planets

        if planet_list ~= nil and table.getn(planet_list) > 0 then
            
            if entry.Heroes ~= nil then
                for _, hero in pairs(entry.Heroes) do

                    local hero_type = Find_Object_Type(hero)

                    if hero_type ~= nil then

                        local planet = Random_From_List(planet_list)

                        if TestValid(planet) then
                            Spawn_Unit(hero_type, planet, entry.Faction)
                        end
                    end
                end 
            end

            if entry.Special_Units ~= nil then

                for _, special_unit in pairs(entry.Special_Units) do
                    self:Special_Unit_Spawn_Filter(special_unit, planet_list, entry.Faction)
                end
            end
        end
    end

    self.Finished = true
end

function Starting_Units_Handler:Spawn_Structure(structure, planet)

    local structure_type = Find_Object_Type(structure)

    if structure_type ~= nil then

        --DebugMessage("%s -- Spawning Structure: %s", tostring(Script), tostring(structure))

        Spawn_Unit(structure_type, planet, planet.Get_Owner())
    end
end

function Starting_Units_Handler:Get_Spawn_Entry(planet)

    if not TestValid(planet) then
        return nil
    end

    local Planet_Owner = planet.Get_Owner()

    --DebugMessage("%s -- Planet: %s, Owner: %s", tostring(Script), tostring(planet), tostring(Planet_Owner.Get_Faction_Name()))

    for faction, entry in pairs(self.Spawn_Settings.Factions) do

        --DebugMessage("%s -- Entry Faction: %s", tostring(Script), tostring(entry.Faction))

        if entry.Faction == Planet_Owner then

            table.insert(entry.Planets, planet)

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

    for unit, entry in pairs(self.Global_Unit_Table) do
        if unit_name == unit then
            return entry
        end
    end
    
    return nil
end

function Starting_Units_Handler:Is_Finished()
    return self.Finished
end

function Starting_Units_Handler:Add_Banned_Structures(structures)
    
    if type(structures) == "string" then -- Allow the passing of a single structure, then format it into a table
        local temp = structures

        structures = {temp}
    end

    if type(structures) ~= "table" then
        return
    end

    for _, structure in pairs(structures) do
        self.Banned_Structures[structure] = true
    end
end

function Starting_Units_Handler:Special_Unit_Spawn_Filter(special_entry, planet_list, faction)
    if special_entry == nil then
        return nil
    end

    DebugMessage("%s -- Attempting Special Unit Spawn for %s", tostring(Script), tostring(special_entry.Unit))

    if special_entry.Filter == nil or special_entry.Filter.Type == "None" then
        DebugMessage("%s -- Special Unit has No Filter", tostring(Script))
        self:Special_Unit_Spawn(special_entry, planet_list, faction)
        return
    end

    if special_entry.Filter.Type == "Station" and (type(special_entry.Filter.Value) == "number" or type(special_entry.Filter.Value) == "table") then
        local Filter_Value_Type = type(special_entry.Filter.Value)

        local filtered_planet_table = {}

        if Filter_Value_Type == "number" then
            DebugMessage("%s -- Special Unit Filter: Station, Type Level %s", tostring(Script), tostring(special_entry.Filter.Value))
            if special_entry.Filter.Value > 0 and special_entry.Filter.Value < 6 then
                for _, planet in pairs(planet_list) do 
                    if TestValid(planet) then
                        DebugMessage("%s -- %s Station Level: %s, Comparing to: %s", tostring(Script), tostring(planet), tostring(planet.Get_Starbase_Level()), tostring(special_entry.Filter.Value))
                        if planet.Get_Starbase_Level() == special_entry.Filter.Value then
                            DebugMessage("%s -- Adding %s to Filtered List", tostring(Script), tostring(planet))
                            table.insert(filtered_planet_table, planet)
                        end
                    end
                end
            end
        elseif Filter_Value_Type == "table" then
            DebugMessage("%s -- Special Unit Filter: Station, Type Range", tostring(Script))
            PrintTable(special_entry.Filter.Value)
            for _, planet in pairs(planet_list) do 
                if TestValid(planet) then
                    local planet_station_level = planet.Get_Starbase_Level()
                    DebugMessage("%s -- Planet %s Station Level: %s, Is in Filter: %s", tostring(Script), tostring(planet), tostring(planet_station_level), tostring(special_entry.Filter.Value[planet_station_level + 1]))
                    if special_entry.Filter.Value[planet_station_level + 1] == true then
                        DebugMessage("%s -- Adding %s to Filtered List", tostring(Script), tostring(planet))
                        table.insert(filtered_planet_table, planet)
                    end
                end
            end
        end

        DebugMessage("%s -- Final Filtered Table", tostring(Script))
        PrintTable(filtered_planet_table)

        self:Special_Unit_Spawn(special_entry, filtered_planet_table, faction)

        return
    end

    if special_entry.Filter.Type == "Power" then
        DebugMessage("%s -- Special Unit Filter: Power", tostring(Script))
        local filtered_planet_table = {}
        if special_entry.Filter.Value  then -- if true, we are looking for the weakest planet, if false we are looking for the strongest
            DebugMessage("%s -- Looking for Weakest Planet", tostring(Script))
            local weakest_power = 1000000000
            local weakest_planet = nil

            for _, planet in pairs(planet_list) do
                local power = EvaluatePerception("Planet_Force_Strength", planet.Get_Owner(), planet) -- in terms of space power, ground is not considered

                if power < weakest_power then
                    weakest_power = power
                    weakest_planet = planet
                end
            end

            DebugMessage("%s -- Found Weakest Planet: %s" ,tostring(Script), tostring(weakest_planet))

            if TestValid(weakest_planet) then
                self:Special_Unit_Spawn(special_entry, {weakest_planet}, faction)
            end
        else
            DebugMessage("%s -- Looking for Strongest Planet", tostring(Script))
            local strongest_power = 0
            local strongest_planet = nil

            for _, planet in pairs(planet_list) do
                local power = EvaluatePerception("Planet_Force_Strength", planet.Get_Owner(), planet) -- in terms of space power, ground is not considered

                if power > strongest_power then
                    strongest_power = power
                    strongest_planet = planet
                end
            end

            DebugMessage("%s -- Found Strongest Planet: %s", tostring(Script), tostring(strongest_planet))

            if TestValid(strongest_planet) then
                self:Special_Unit_Spawn(special_entry, {strongest_planet}, faction)
            end
        end
    end

end

function Starting_Units_Handler:Special_Unit_Spawn(special_entry, planet_list, faction)

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

    local Unit_Type = Find_Object_Type(special_entry.Unit)

    DebugMessage("%s -- Spawning %s %s for %s", tostring(Script), tostring(special_entry.Count), tostring(special_entry.Unit), tostring(faction.Get_Faction_Name()))

    DebugMessage("%s -- Found Unit Type: %s", tostring(Script), tostring(Unit_Type))

    if Unit_Type ~= nil and special_entry.Count > 0 then
        local spawned = 0

        while spawned < special_entry.Count do
            local planet = Random_From_List(planet_list)

            DebugMessage("%s -- Selected %s, Spawn Count: %s for %s", tostring(Script), tostring(planet), tostring(spawned + 1), tostring(special_entry.Unit))

            if TestValid(planet) then
                DebugMessage("%s -- Planet Was valid, spawning", tostring(Script))
                Spawn_Unit(Unit_Type, planet, faction)
            end

            spawned = spawned + 1
        end
    end
end

return Starting_Units_Handler