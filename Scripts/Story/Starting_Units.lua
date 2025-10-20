-- Script Written by ShyShallot
Starting_Units_Handler = {
    Spawn_Settings = {
        Category_Mapping = nil, -- this is filled in later with a weighted table in Global_Story OnEnter
        Global_Multiplier = 1.75, -- Max Combat Power multiplier
        Factions = { 
            UNSC = {
                Station = {
                    Default = {
                        Power = 8000,
                        Structures = {"UNSC_CAMP"},
                        Units = {"PELICAN_SQUADRON", "SHORTSWORD_SQUADRON", "LATE_LONGSWORD_SQUADRON", "BASELARD_SQUADRON", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "BUCKLER_SQUADRON"}
                    },
                    Low = {
                        Power = 18000,
                        Structures = {"UNSC_CAMP"},
                        Units = {"PELICAN_SQUADRON", "SHORTSWORD_SQUADRON", "LATE_LONGSWORD_SQUADRON", "BASELARD_SQUADRON", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "BUCKLER_SQUADRON"}
                    },
                    Medium = {
                        Power = 45000,
                        Structures = {"UNSC_BASE", "UNSC_BASIC_BARRACKS"},
                        Units = {"PELICAN_SQUADRON", "SHORTSWORD_SQUADRON", "LATE_LONGSWORD_SQUADRON", "BASELARD_SQUADRON", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "BUCKLER_SQUADRON", "UNSC_EPOCH", "UNSC_PHOENIX"}
                    },
                    High = {
                        Power = 45000,
                        Structures = {"UNSC_BASE", "UNSC_BASIC_BARRACKS", "UNSC_BASIC_FACTORY"},
                        Units = {"PELICAN_SQUADRON", "SHORTSWORD_SQUADRON", "LATE_LONGSWORD_SQUADRON", "BASELARD_SQUADRON", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "BUCKLER_SQUADRON", "UNSC_EPOCH", "UNSC_PHOENIX"}
                    },
                    Ultra = {
                        Power = 45000,
                        Structures = {"UNSC_FORT", "UNSC_BASIC_BARRACKS", "UNSC_BASIC_FACTORY"},
                        Units = {"PELICAN_SQUADRON", "SHORTSWORD_SQUADRON", "LATE_LONGSWORD_SQUADRON", "BASELARD_SQUADRON", "MAKO_SQUADRON", "GLADIUS_SQUADRON", "BUCKLER_SQUADRON", "UNSC_EPOCH", "UNSC_PHOENIX"}
                    }
                },
                Heroes = {
                    "UNSC_SOF", 
                    "UNSC_IAC",
                    "UNSC_ROMAN_BLUE"
                },
                Planets = {},
                Mapping = {},
            },
            COVN = {
                Station = {
                    Default = {
                        Power = 25000,
                        Structures = {"COVN_CAMP"},
                        Units = {"CRS_SQUADRON"}
                    },
                    Low = {
                        Power = 30500,
                        Structures = {"COVN_CAMP"},
                        Units = {"SDV_SQUADRON", "CRS_SQUADRON"}
                    },
                    Medium = {
                        Power = 60000,
                        Structures = {"COVN_BASE", "COVN_BASIC_BARRACKS"},
                        Units = {"COVN_RCS"}
                    },
                    High = {
                        Power = 20500,
                        Structures = {"COVN_BASE", "COVN_BASIC_BARRACKS", "COVN_BASIC_FACTORY"},
                        Units = {"COVN_RCS", "COVN_CCS", "COVN_DDS", "COVN_ORS", "COVN_CAS"}
                    },
                    Ultra = {
                        Power = 85000,
                        Structures = {"COVN_FORT", "COVN_BASIC_BARRACKS", "COVN_BASIC_FACTORY"},
                        Units = {"SDV_SQUADRON", "CRS_SQUADRON", "COVN_RCS", "COVN_CCS", "COVN_DDS", "COVN_ORS", "COVN_CAS"}
                    }
                },
                Heroes = {
                    "COVN_PIOUS",
					"COVN_MACCABEUS",
					"COVN_CSO"
                },
                Planets = {},
                Mapping = {},
            },
            Swords = {
                Station = {
                    Default = {
                        Power = 1000,
                        Structures = {},
                        Units = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron"}
                    },
                    Low = {
                        Power = 23500,
                        Structures = {},
                        Units = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron", "SWORDS_SDV"}
                    },
                    Medium = {
                        Power = 40000,
                        Structures = {},
                        Units = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron", "SWORDS_SDV", "SWORDS_CRS", "SWORDS_CCS"}
                    }
                },
                Planets = {},
                Mapping = {},
            },
            Terror = {
                Station = {
                    Default = {
                        Power = 1000,
                        Structures = {},
                        Units = {"TERROR_Baselard_Squadron", "TERROR_SHORTSWORD_Squadron"}
                    },
                    Low = {
                        Power = 3500,
                        Structures = {},
                        Units = {"TERROR_Baselard_Squadron", "TERROR_SHORTSWORD_Squadron", "TERROR_MAKO", "TERROR_GLADIUS"}
                    },
                    Medium = {
                        Power = 10000,
                        Structures = {},
                        Units = {"TERROR_Baselard_Squadron", "TERROR_SHORTSWORD_Squadron", "TERROR_MAKO", "TERROR_GLADIUS", "TERROR_CHARON", "TERROR_STALWART"}
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

        if planet_list ~= nil and table.getn(planet_list) > 0 and entry.Heroes ~= nil then
            
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

return Starting_Units_Handler