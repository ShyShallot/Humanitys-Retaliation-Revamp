require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("PGBase")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Universal_Story_Start = Global_Story
    }

    Spawn_Settings = {
        Category_Mapping = { -- Spawn Chances for each type of cateogry, the category is determined via the globalUnitTable.lua
            ["Fighter"] = 0.75,
            ["Corvette"] = 0.55,
            ["Frigate"] = 0.45,
            ["Capital"] = 0.4,
            ["Super"] = 0.35,
            ["Default"] = 0.5
        },
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
                    Units = {"PELICAN_SQUADRON", "Late_Longsword_Squadron", "MAKO_SQUADRON", "STALWART_SQUADRON", "BASELARD_SQUADRON", "UNSC_PHOENIX"}
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

    Global_Unit_Table = nil

    Spawn_Settings.UNSC.Mapping = {}

    Spawn_Settings.UNSC.Mapping[0] = Spawn_Settings.UNSC.Station.Default -- The Index defined is the Space Station Level of the planet
    Spawn_Settings.UNSC.Mapping[1] = Spawn_Settings.UNSC.Station.Low 
    Spawn_Settings.UNSC.Mapping[2] = Spawn_Settings.UNSC.Station.Low -- for example the Level 2 Space Station will use the same template as a level 1 space station
    Spawn_Settings.UNSC.Mapping[3] = Spawn_Settings.UNSC.Station.Medium
    Spawn_Settings.UNSC.Mapping[4] = Spawn_Settings.UNSC.Station.High
    Spawn_Settings.UNSC.Mapping[5] = Spawn_Settings.UNSC.Station.Ultra

    Spawn_Settings.COVN.Mapping = {}

    Spawn_Settings.COVN.Mapping[0] = Spawn_Settings.COVN.Station.Default
    Spawn_Settings.COVN.Mapping[1] = Spawn_Settings.COVN.Station.Low
    Spawn_Settings.COVN.Mapping[2] = Spawn_Settings.COVN.Station.Low
    Spawn_Settings.COVN.Mapping[3] = Spawn_Settings.COVN.Station.Medium
    Spawn_Settings.COVN.Mapping[4] = Spawn_Settings.COVN.Station.High
    Spawn_Settings.COVN.Mapping[5] = Spawn_Settings.COVN.Station.Ultra

    Spawn_Settings.Swords.Mapping = {}

    Spawn_Settings.Swords.Mapping[0] = Spawn_Settings.Swords.Station.Default
    Spawn_Settings.Swords.Mapping[1] = Spawn_Settings.Swords.Station.Low
    Spawn_Settings.Swords.Mapping[2] = Spawn_Settings.Swords.Station.Low
    Spawn_Settings.Swords.Mapping[3] = Spawn_Settings.Swords.Station.Medium -- Minor factions dont have space station levels higher than 3

    Spawn_Settings.Terror.Mapping = {}

    Spawn_Settings.Terror.Mapping[0] = Spawn_Settings.Terror.Station.Default
    Spawn_Settings.Terror.Mapping[1] = Spawn_Settings.Terror.Station.Low
    Spawn_Settings.Terror.Mapping[2] = Spawn_Settings.Terror.Station.Low
    Spawn_Settings.Terror.Mapping[3] = Spawn_Settings.Terror.Station.Medium

end

-- Yes this code is similar to AOTR, i used it as a base for the most part and how things are done are based off of aotr, 
--i thank them for the original idea

function Story_Mode_Service()

end

function Global_Story(message)
    if  message == OnEnter then 

        Global_Unit_Table = require("globalUnitTable")

        Spawn_Settings.UNSC.Faction = Find_Player("Rebel")

        Spawn_Settings.COVN.Faction = Find_Player("Empire")

        Spawn_Settings.Swords.Faction = Find_Player("Swords")

        Spawn_Settings.Terror.Faction = Find_Player("TERRORISTS")

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

                    while Planet_Power < Settings.Power do

                        DebugMessage("%s -- Planet Power: %s, Max Power: %s", tostring(Script), tostring(Planet_Power), tostring(Settings.Power))

                        for _, unit in pairs(Settings.Units) do
                            local Unit_Entry = Get_Unit_Entry(unit)

                            local Unit_Type = Find_Object_Type(unit)

                            DebugMessage("%s -- Current Unit: %s, Unit Entry: %s, Type: %s", tostring(Script), tostring(unit), tostring(Unit_Entry), tostring(Unit_Type))

                            if Unit_Entry ~= nil and Unit_Type ~= nil then
                                local Unit_Category = Unit_Entry.Category

                                local Spawn_Chance = Spawn_Settings.Category_Mapping[Unit_Category]

                                if Spawn_Chance == nil then
                                    Spawn_Chance = Spawn_Settings.Category_Mapping["Default"]
                                end

                                local Unit_Power = Unit_Type.Get_Combat_Rating()

                                DebugMessage("%s -- Unit Category: %s, Spawn Chance: %s %%, Unit Power: %s", tostring(Script), tostring(Unit_Category), tostring(Spawn_Chance), tostring(Unit_Power))

                                if Spawn_Chance ~= nil then
                                    if Return_Chance(Spawn_Chance) then

                                        DebugMessage("%s -- Spawned a %s, at %s", tostring(Script), tostring(unit), tostring(planet))

                                        Spawn_Unit(Unit_Type, planet, planet.Get_Owner())

                                        Planet_Power = Planet_Power + Unit_Power
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        for faction, entry in pairs(Spawn_Settings) do -- Hero Spawn
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

    for faction, entry in pairs(Spawn_Settings) do

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