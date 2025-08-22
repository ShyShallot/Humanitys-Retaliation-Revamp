require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("PGBase")
require("PGStoryMode")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Universal_Story_Start = Global_Story
    }

    Spawn_Settings = {
        Category_Mapping = nil,
        Global_Multiplier = 1.75, -- Max Combat Power multiplier 
        Factions = { 
            UNSC = {
                Station = {
                    Default = {
                        Power = 4000,
                        Structures = {},
                        Units = {"PELICAN_SQUADRON", "Late_Longsword_Squadron", "MAKO_SQUADRON"}
                    },
                    Low = {
                        Power = 9000,
                        Structures = {},
                        Units = {"PELICAN_SQUADRON", "Late_Longsword_Squadron", "MAKO_SQUADRON", "STALWART_SQUADRON", "BASELARD_SQUADRON"}
                    },
                    Medium = {
                        Power = 14500,
                        Structures = {"R_Ground_Barracks"},
                        Units = {"PELICAN_SQUADRON", "Late_Longsword_Squadron", "MAKO_SQUADRON", "STALWART_SQUADRON", "BASELARD_SQUADRON"}
                    },
                    High = {
                        Power = 25000,
                        Structures = {"R_Ground_Barracks"},
                        Units = {"PELICAN_SQUADRON", "Late_Longsword_Squadron", "MAKO_SQUADRON", "STALWART_SQUADRON", "BASELARD_SQUADRON", "UNSC_PHOENIX"}
                    },
                    Ultra = {
                        Power = 35000,
                        Structures = {"R_Ground_Barracks"},
                        Units = {"PELICAN_SQUADRON", "Late_Longsword_Squadron", "MAKO_SQUADRON", "STALWART_SQUADRON", "BASELARD_SQUADRON", "UNSC_PHOENIX", "UNSC_HALCYON"}
                    }
                },
                Heroes = {
                    "UNSC_SOF", 
                    "UNSC_IAC",
                    "UNSC_ROMAN_BLUE"
                },
                Planets = {}
            },
            COVN = {
                Station = {
                    Default = {
                        Power = 6000,
                        Structures = {},
                        Units = {"COVN_SDV"}
                    },
                    Low = {
                        Power = 9500,
                        Structures = {},
                        Units = {"COVN_SDV", "COVN_CRS"}
                    },
                    Medium = {
                        Power = 18000,
                        Structures = {"E_Ground_Barracks"},
                        Units = {"COVN_SDV", "COVN_CRS"}
                    },
                    High = {
                        Power = 30500,
                        Structures = {"E_Ground_Barracks"},
                        Units = {"COVN_SDV", "COVN_CRS", "COVN_RCS", "COVN_DDS"}
                    },
                    Ultra = {
                        Power = 45000,
                        Structures = {"E_Ground_Barracks"},
                        Units = {"COVN_SDV", "COVN_CRS", "COVN_RCS", "COVN_DDS", "COVN_CAS"}
                    }
                },
                Heroes = {
                    "COVN_ARDO"
                },
                Planets = {}
            },
            Swords = {
                Station = {
                    Default = {
                        Power = 1000,
                        Structures = {},
                        Units = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron"}
                    },
                    Low = {
                        Power = 3500,
                        Structures = {},
                        Units = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron", "SWORDS_SDV"}
                    },
                    Medium = {
                        Power = 10000,
                        Structures = {},
                        Units = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron", "SWORDS_SDV", "SWORDS_CRS", "SWORDS_CCS"}
                    }
                },
                Planets = {}
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
                        Units = {"TERROR_Baselard_Squadron", "TERROR_SHORTSWORD_Squadron", "TERROR_MAKO", "TERROR_GLADIUS", "TERROR_HALCYON", "TERROR_CHARON", "TERROR_STALWART"}
                    }
                },
                Planets = {}
            }
        }
    }

    Global_Unit_Table = nil

    Spawn_Settings.Factions.UNSC.Mapping = {}

    Spawn_Settings.Factions.UNSC.Mapping[0] = Spawn_Settings.Factions.UNSC.Station.Default -- The Index defined is the Space Station Level of the planet
    Spawn_Settings.Factions.UNSC.Mapping[1] = Spawn_Settings.Factions.UNSC.Station.Low 
    Spawn_Settings.Factions.UNSC.Mapping[2] = Spawn_Settings.Factions.UNSC.Station.Low -- for example the Level 2 Space Station will use the same template as a level 1 space station
    Spawn_Settings.Factions.UNSC.Mapping[3] = Spawn_Settings.Factions.UNSC.Station.Medium
    Spawn_Settings.Factions.UNSC.Mapping[4] = Spawn_Settings.Factions.UNSC.Station.High
    Spawn_Settings.Factions.UNSC.Mapping[5] = Spawn_Settings.Factions.UNSC.Station.Ultra

    Spawn_Settings.Factions.COVN.Mapping = {}

    Spawn_Settings.Factions.COVN.Mapping[0] = Spawn_Settings.Factions.COVN.Station.Default
    Spawn_Settings.Factions.COVN.Mapping[1] = Spawn_Settings.Factions.COVN.Station.Low
    Spawn_Settings.Factions.COVN.Mapping[2] = Spawn_Settings.Factions.COVN.Station.Low
    Spawn_Settings.Factions.COVN.Mapping[3] = Spawn_Settings.Factions.COVN.Station.Medium
    Spawn_Settings.Factions.COVN.Mapping[4] = Spawn_Settings.Factions.COVN.Station.High
    Spawn_Settings.Factions.COVN.Mapping[5] = Spawn_Settings.Factions.COVN.Station.Ultra

    Spawn_Settings.Factions.Swords.Mapping = {}

    Spawn_Settings.Factions.Swords.Mapping[0] = Spawn_Settings.Factions.Swords.Station.Default
    Spawn_Settings.Factions.Swords.Mapping[1] = Spawn_Settings.Factions.Swords.Station.Low
    Spawn_Settings.Factions.Swords.Mapping[2] = Spawn_Settings.Factions.Swords.Station.Low
    Spawn_Settings.Factions.Swords.Mapping[3] = Spawn_Settings.Factions.Swords.Station.Medium -- Minor factions dont have space station levels higher than 3

    Spawn_Settings.Factions.Terror.Mapping = {}

    Spawn_Settings.Factions.Terror.Mapping[0] = Spawn_Settings.Factions.Terror.Station.Default
    Spawn_Settings.Factions.Terror.Mapping[1] = Spawn_Settings.Factions.Terror.Station.Low
    Spawn_Settings.Factions.Terror.Mapping[2] = Spawn_Settings.Factions.Terror.Station.Low
    Spawn_Settings.Factions.Terror.Mapping[3] = Spawn_Settings.Factions.Terror.Station.Medium

end

function Global_Story(message)
    if  message == OnEnter then 

        Global_Unit_Table = require("globalUnitTable")

        Spawn_Settings.Category_Mapping = DiscreteDistribution.Create() -- Higher Number, higher chance of being selected

        Spawn_Settings.Category_Mapping.Insert("Fighter", 45)

        Spawn_Settings.Category_Mapping.Insert("Corvette", 50)
        
        Spawn_Settings.Category_Mapping.Insert("Frigate", 60)

        Spawn_Settings.Category_Mapping.Insert("Capital", 22)

        Spawn_Settings.Category_Mapping.Insert("Super", 10)

        Spawn_Settings.Factions.UNSC.Faction = Find_Player("Rebel")

        Spawn_Settings.Factions.COVN.Faction = Find_Player("Empire")

        Spawn_Settings.Factions.Swords.Faction = Find_Player("Swords")

        Spawn_Settings.Factions.Terror.Faction = Find_Player("TERRORISTS")

        planets = FindPlanet.Get_All_Planets()

        for _, planet in pairs(planets) do
            --DebugMessage("%s -- Starbase Level: %s", tostring(Script), tostring(planet.Get_Starbase_Level()))

            local Spawn_Entry = Get_Spawn_Entry(planet)

            DebugMessage("%s -- Spawn Entry for Planet %s: %s", tostring(Script), tostring(planet), tostring(Spawn_Entry))

            if Spawn_Entry ~= nil then
                local Starbase_Level = planet.Get_Starbase_Level()

                local Settings = Spawn_Entry.Mapping[Starbase_Level]

                if Settings == nil then
                    Settings = Spawn_Entry.Station.Default
                end

                DebugMessage("%s -- Starbase Level: %s, Settings: %s", tostring(Script), tostring(Starbase_Level), tostring(Settings))

                if Settings ~= nil then
                    local Planet_Power = 0

                    for _, structure in pairs(Settings.Structures) do
                        local structure_type = Find_Object_Type(structure)

                        if structure_type ~= nil then

                            DebugMessage("%s -- Spawning Structure: %s", tostring(Script), tostring(structure))

                            Spawn_Unit(structure_type, planet, planet.Get_Owner())
                        end
                    end

                    while Planet_Power < tonumber(Dirty_Floor((Settings.Power * Spawn_Settings.Global_Multiplier))) do

                        --DebugMessage("%s -- Planet Power: %s, Max Power: %s", tostring(Script), tostring(Planet_Power), tostring(Settings.Power))

                        local Category = Spawn_Settings.Category_Mapping.Sample()

                        DebugMessage("%s -- Selected Category: %s", tostring(Script), tostring(Category))

                        for _, unit in pairs(Settings.Units) do
                            local Unit_Entry = Get_Unit_Entry(unit)

                            local Unit_Type = Find_Object_Type(unit)

                            --DebugMessage("%s -- Current Unit: %s, Unit Entry: %s, Type: %s", tostring(Script), tostring(unit), tostring(Unit_Entry), tostring(Unit_Type))

                            if Unit_Entry ~= nil and Unit_Type ~= nil then

                                local Unit_Category = Unit_Entry.Category

                                --DebugMessage("%s -- Spawn Chance: %s, Unit Count: %s, Base Chance: %s, Per Unit Chance Drop: %s", tostring(Script), tostring(Spawn_Chance), tostring(Unit_Count), tostring(Spawn_Chance_Settings.Chance), tostring(Spawn_Chance_Settings.Per_Unit_Chance_Drop))

                                local Unit_Power = Unit_Type.Get_Combat_Rating()

                                --DebugMessage("%s -- Unit Category: %s, Spawn Chance: %s %%, Unit Power: %s", tostring(Script), tostring(Unit_Category), tostring(Spawn_Chance), tostring(Unit_Power))

                                if Unit_Category == Category then

                                    --DebugMessage("%s -- Spawned a %s, at %s", tostring(Script), tostring(unit), tostring(planet))

                                    Spawn_Unit(Unit_Type, planet, planet.Get_Owner())

                                    Planet_Power = Planet_Power + Unit_Power

                                end
                            end
                        end
                    end
                end
            end
        end

        for faction, entry in pairs(Spawn_Settings.Factions) do -- Hero Spawn
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
    end
end

function Get_Spawn_Entry(planet)

    if not TestValid(planet) then
        return nil
    end

    local Planet_Owner = planet.Get_Owner()

    DebugMessage("%s -- Planet: %s, Owner: %s", tostring(Script), tostring(planet), tostring(Planet_Owner.Get_Faction_Name()))

    for faction, entry in pairs(Spawn_Settings.Factions) do

        DebugMessage("%s -- Entry Faction: %s", tostring(Script), tostring(entry.Faction))

        if entry.Faction == Planet_Owner then

            table.insert(entry.Planets, planet)

            return entry
        end
    end

    return nil
end

function Get_Unit_Entry(unit_name)

    if unit_name == nil then
        return nil
    end

    if Global_Unit_Table == nil then
        return nil
    end

    for unit, entry in pairs(Global_Unit_Table) do
        if unit_name == unit then
            return entry
        end
    end
    
    return nil
end