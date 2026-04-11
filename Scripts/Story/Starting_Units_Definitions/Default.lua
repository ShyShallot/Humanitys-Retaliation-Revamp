Spawn_Settings = {
    Global_Multiplier = 1.75,     -- Max Combat Power multiplier
    Spawn_Variations = 5,         -- How many variations do we want to generate
    Factions = {
        UNSC = {
            Station = {
                Default = {
                    Power = {
                        Space = 10000,
                        Ground = 300
                    },
                    Structures = { "UNSC_CAMP", "R_GROUND_BARRACKS", "R_GROUND_LIGHT_VEHICLE_FACTORY" },
                    Space_Units = {
                        ["UNSC_BUCKLER"] = {
                            Weight = 50,
                            Limit = -1
                        },
                        ["UNSC_SINGLE_CHARON"] = {
                            Weight = 50,
                            Limit = -1
                        },
						["UNSC_MUSASHI"] = {
                            Weight = 3,
                            Limit = -1
                        },
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                },
                Low = {
                    Power = {
                        Space = 15000,
                        Ground = 600
                    },
                    Structures = { "UNSC_BASE", "R_GROUND_BARRACKS", "R_GROUND_LIGHT_VEHICLE_FACTORY", "R_GROUND_HEAVY_VEHICLE_FACTORY" },
                    Space_Units = {
                        ["UNSC_BUCKLER"] = {
                            Weight = 30,
                            Limit = -1
                        },
                        ["UNSC_SINGLE_CHARON"] = {
                            Weight = 30,
                            Limit = -1
                        },
						["UNSC_MUSASHI"] = {
                            Weight = 3,
                            Limit = -1
                        },
                        ["UNSC_PHOENIX"] = {
                            Weight = 1,
                            Limit = -1
                        }
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                },
                Medium = {
                    Power = {
                        Space = 25000,
                        Ground = 1200,
                    },
                    Structures = { "UNSC_FORT", "R_GROUND_BARRACKS", "R_GROUND_LIGHT_VEHICLE_FACTORY", "R_GROUND_HEAVY_VEHICLE_FACTORY", "COMMUNICATIONS_ARRAY_R" },
                    Space_Units = {
                        ["UNSC_BUCKLER"] = {
                            Weight = 30,
                            Limit = -1
                        },
                        ["UNSC_SINGLE_CHARON"] = {
                            Weight = 30,
                            Limit = -1
                        },
						["UNSC_MUSASHI"] = {
                            Weight = 3,
                            Limit = -1
                        },
                        ["UNSC_PHOENIX"] = {
                            Weight = 1,
                            Limit = -1
                        },
                        ["UNSC_EPOCH"] = {
                            Weight = 1,
                            Limit = -1
                        }
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                },
                High = {
                    Power = {
                        Space = 45000,
                        Ground = 300,
                    },
                    Structures = { "UNSC_FORT" },
                    Space_Units = {
                        ["UNSC_BUCKLER"] = {
                            Weight = 30,
                            Limit = -1
                        },
                        ["UNSC_SINGLE_CHARON"] = {
                            Weight = 30,
                            Limit = -1
                        },
						["UNSC_MUSASHI"] = {
                            Weight = 3,
                            Limit = -1
                        },
                        ["UNSC_PHOENIX"] = {
                            Weight = 1,
                            Limit = -1
                        },
                        ["UNSC_EPOCH"] = {
                            Weight = 1,
                            Limit = -1
                        }
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                },
                Ultra = {
                    Power = {
                        Space = 45000,
                        Ground = 300,
                    },
                    Structures = { "UNSC_FORT" },
                    Space_Units = {
                        ["UNSC_BUCKLER"] = {
                            Weight = 30,
                            Limit = -1
                        },
                        ["UNSC_SINGLE_CHARON"] = {
                            Weight = 30,
                            Limit = -1
                        },
						["UNSC_MUSASHI"] = {
                            Weight = 3,
                            Limit = -1
                        },
                        ["UNSC_PHOENIX"] = {
                            Weight = 1,
                            Limit = -1
                        },
                        ["UNSC_EPOCH"] = {
                            Weight = 1,
                            Limit = -1
                        }
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    }
                }
            },
            Heroes = {
                "UNSC_SOF",
            },
            Special_Units = {},
            Planets = {},
            Mapping = {},
        },
        COVN = {
            Station = {
                Default = {
                    Power = {
                        Space = 25000,
                        Ground = 600,
                    },
                    Structures = { "E_GROUND_BARRACKS", "E_GROUND_LIGHT_VEHICLE_FACTORY" },
                    Space_Units = {
                        ["CRS_SQUADRON"] = {
                            Weight = 100,
                            Limit = 10
                        },
						["COVN_SDV"] = {
                            Weight = 50,
                            Limit = 8
                        },
						["COVN_RCS"] = {
                            Weight = 3,
                            Limit = 6
                        }
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    },
                },
                Low = {
                    Power = {
                        Space = 30500,
                        Ground = 600,
                    },
                    Structures = { "E_GROUND_BARRACKS", "E_GROUND_LIGHT_VEHICLE_FACTORY" },
                    Space_Units = {
                        ["COVN_SDV"] = {
                            Weight = 50,
                            Limit = 8
                        },
                        ["CRS_SQUADRON"] = {
                            Weight = 50,
                            Limit = 12
                        },
						["COVN_RCS"] = {
                            Weight = 3,
                            Limit = 10
                        }
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    },
                },
                Medium = {
                    Power = {
                        Space = 60000,
                        Ground = 600,
                    },
                    Structures = { "E_GROUND_BARRACKS", "E_GROUND_LIGHT_VEHICLE_FACTORY", "E_GROUND_HEAVY_VEHICLE_FACTORY" },
                    Space_Units = {
                        ["COVN_SDV"] = {
                            Weight = 65,
                            Limit = 18
                        },
                        ["CRS_SQUADRON"] = {
                            Weight = 50,
                            Limit = 14
                        },
                        ["COVN_RCS"] = {
                            Weight = 3,
                            Limit = 16
                        },
						
                        ["COVN_CCS"] = {
                            Weight = 5,
                            Limit = 20
                        },
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    }
                },
                High = {
                    Power = {
                        Space = 120500,
                        Ground = 600,
                    },
                    Structures = { "E_GROUND_BARRACKS", "E_GROUND_LIGHT_VEHICLE_FACTORY", "E_GROUND_HEAVY_VEHICLE_FACTORY", "E_GROUND_ADVANCED_VEHICLE_FACTORY", "COVENANT_ASSEMBLY_FORGE" },
                    Space_Units = {
                        ["COVN_SDV"] = {
                            Weight = 25,
                            Limit = 10
                        },
                        ["CRS_SQUADRON"] = {
                            Weight = 30,
                            Limit = 20
                        },
                        ["COVN_RCS"] = {
                            Weight = 15,
                            Limit = 20
                        },
                        ["COVN_CCS"] = {
                            Weight = 10,
                            Limit = 30
                        },
                        ["COVN_DDS"] = {
                            Weight = 3,
                            Limit = 6
                        },
                        ["COVN_ORS"] = {
                            Weight = 3,
                            Limit = 12
                        },
						["COVN_CPV"] = {
                            Weight = 3,
                            Limit = 10
                        },
                        ["COVN_CAS"] = {
                            Weight = 1,
                            Limit = 3
                        },
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    }
                },
                Ultra = {
                    Power = {
                        Space = 185000,
                        Ground = 600,
                    },
                    Structures = { "E_GROUND_BARRACKS", "E_GROUND_LIGHT_VEHICLE_FACTORY", "E_GROUND_HEAVY_VEHICLE_FACTORY", "E_GROUND_ADVANCED_VEHICLE_FACTORY", "COVENANT_ASSEMBLY_FORGE" },
                    Space_Units = {
                         ["COVN_SDV"] = {
                            Weight = 25,
                            Limit = 10
                        },
                        ["CRS_SQUADRON"] = {
                            Weight = 30,
                            Limit = 20
                        },
                        ["COVN_RCS"] = {
                            Weight = 15,
                            Limit = 20
                        },
                        ["COVN_CCS"] = {
                            Weight = 10,
                            Limit = 30
                        },
                        ["COVN_DDS"] = {
                            Weight = 3,
                            Limit = 6
                        },
                        ["COVN_ORS"] = {
                            Weight = 3,
                            Limit = 12
                        },
						["COVN_CPV"] = {
                            Weight = 3,
                            Limit = 10
                        },
                        ["COVN_CAS"] = {
                            Weight = 1,
                            Limit = 3
                        },
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    }
                }
            },
            Heroes = {
                "COVN_PIOUS",
                "COVN_MACCABEUS",
            },
            Special_Units = {                                                                                             -- could work for structures as well
                { Count = 1, Unit = "COVN_CSO", Filter = { Type = "Station", Value = { false, false, false, false, true, true } } } -- the Value Table is the Acceptable Station Levels,0,1,2,3,4,5,if it is true it will spawn at that level,in this usage,it will only spawn at level 4 and 5
                --{Count = 1,Unit = "COVN_CSO",Filter = {Type = "Power",Value = false}} -- Would Spawn 1 CSO on the strongest planet calculated via space unit strength
                --{Count = 1,Unit = "COVN_CSO"} -- Spawns a CSO on a random controlled planet
            },
            Planets = {},
            Mapping = {},
        },
        Swords = {
            Station = {
                Default = {
                    Power = {
                        Space = 10000,
                        Ground = 600,
                    },
                    Structures = {},
                    Space_Units = {
                        ["SWORDS_CRS"] = {
                            Weight = 50,
                            Limit = 20
                        },
                        ["SWORDS_SDV"] = {
                            Weight = 25,
                            Limit = -1
                        },
                        ["SWORDS_CCS"] = {
                            Weight = 4,
                            Limit = 10
                        },
                        ["SWORDS_CAS"] = {
                            Weight = 1,
                            Limit = 1
                        },
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    },
                },
                Low = {
                    Power = {
                        Space = 25500,
                        Ground = 600,
                    },
                    Structures = {},
                    Space_Units = {
                        ["SWORDS_CRS"] = {
                            Weight = 50,
                            Limit = 20
                        },
                        ["SWORDS_SDV"] = {
                            Weight = 25,
                            Limit = -1
                        },
                        ["SWORDS_CCS"] = {
                            Weight = 4,
                            Limit = 10
                        },
                        ["SWORDS_CAS"] = {
                            Weight = 1,
                            Limit = 1
                        },
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    },
                },
                Medium = {
                    Power = {
                        Space = 45000,
                        Ground = 600,
                    },
                    Structures = {},
                    Space_Units = {
                        ["SWORDS_CRS"] = {
                            Weight = 50,
                            Limit = 20
                        },
                        ["SWORDS_SDV"] = {
                            Weight = 25,
                            Limit = -1
                        },
                        ["SWORDS_CCS"] = {
                            Weight = 4,
                            Limit = 10
                        },
                        ["SWORDS_CAS"] = {
                            Weight = 1,
                            Limit = 1
                        },
                    },
                    Ground_Units = {
                        ["COVN_DEPLOYABLE_TACTICAL_HALL"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 20,
                            Limit = 2
                        },
                        ["COVN_DEPLOYABLE_ADVANCED_HALL"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["COVN_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        }
                    },
                }
            },
            Planets = {},
            Mapping = {},
        },
        Terror = {
            Station = {
                Default = {
                    Power = {
                        Space = 10000,
                        Ground = 600,
                    },
                    Structures = {"UNSC_FARM","R_GROUND_BARRACKS", "R_GROUND_LIGHT_VEHICLE_FACTORY", "UNSC_TITANIUM_MINE"},
                    Space_Units = {
                        ["TERROR_BUCKLER"] = {
                            Weight = 40,
                            Limit = -1
                        },
                        ["TERROR_CHARON"] = {
                            Weight = 40,
                            Limit = -1
                        },
						["TERROR_MUSASHI"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["TERROR_PHOENIX"] = {
                            Weight = 2,
                            Limit = -1
                        },
						["TERROR_EPOCH"] = {
                            Weight = 1,
                            Limit = 1
                        },
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                },
                Low = {
                    Power = {
                        Space = 20000,
                        Ground = 900,
                    },
                    Structures = {"UNSC_FARM","R_GROUND_BARRACKS", "R_GROUND_LIGHT_VEHICLE_FACTORY", "UNSC_TITANIUM_MINE"},
                    Space_Units = {
                        ["TERROR_BUCKLER"] = {
                            Weight = 40,
                            Limit = -1
                        },
                        ["TERROR_CHARON"] = {
                            Weight = 40,
                            Limit = -1
                        },
						["TERROR_MUSASHI"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["TERROR_PHOENIX"] = {
                            Weight = 2,
                            Limit = -1
                        },
						["TERROR_EPOCH"] = {
                            Weight = 1,
                            Limit = 1
                        },
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                },
                Medium = {
                    Power = {
                        Space = 30000,
                        Ground = 1200,
                    },
                    Structures = {"UNSC_FARM","R_GROUND_BARRACKS", "R_GROUND_LIGHT_VEHICLE_FACTORY", "UNSC_TITANIUM_MINE"},
                    Space_Units = {
                        ["TERROR_BUCKLER"] = {
                            Weight = 40,
                            Limit = -1
                        },
                        ["TERROR_CHARON"] = {
                            Weight = 40,
                            Limit = -1
                        },
						["TERROR_MUSASHI"] = {
                            Weight = 10,
                            Limit = 1
                        },
                        ["TERROR_PHOENIX"] = {
                            Weight = 2,
                            Limit = -1
                        },
						["TERROR_EPOCH"] = {
                            Weight = 1,
                            Limit = 1
                        },
                    },
                    Ground_Units = {
                        ["UNSC_DEPLOYABLE_TACTICAL_BARRACKS"] = {
                            Weight = 60,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_ADVANCED_BARRACKS"] = {
                            Weight = 15,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_VEHICLE_FOUNDRY"] = {
                            Weight = 10,
                            Limit = 2
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_VEHICLE_FOUNDRY"] = {
                            Weight = 5,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_LIGHT_AIR_COMMAND"] = {
                            Weight = 3,
                            Limit = 1
                        },
                        ["UNSC_DEPLOYABLE_HEAVY_BOMBER_COMMAND"] = {
                            Weight = 2,
                            Limit = 1
                        },
                    },
                }
            },
            Planets = {},
            Mapping = {},
        }
    }
}

return Spawn_Settings