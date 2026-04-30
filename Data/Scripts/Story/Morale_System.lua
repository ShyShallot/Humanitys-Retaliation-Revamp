require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PGStoryMode")
require("globalPlanetTable")
require("DynamicWeightTable")

function Definitions()

    ServiceRate = 0.75

    StoryModeEvents = 
    {
        Morale_Level_Init = Init_Morale_System,
        Morale_Lost_Battle = Lost_Battle,
        Morale_Lost_Battle_Major = Lost_Battle_Major,
        Morale_Won_Battle = Won_Battle,
        Morale_Won_Battle_Major = Won_Battle_Major,
        Morale_Construction_Event_Minor = Default_Event_Function,
        Morale_Construction_Event = Default_Event_Function,
        Morale_Construction_Event_Major = Default_Event_Function,
        Morale_Negative_Construction_Event = Default_Event_Function,
        Morale_Negative_Construction_Event_Minor = Default_Event_Function,
        Morale_Hero_Rescued = Default_Event_Function,
        Hero_Lost = Default_Event_Function,
        Hero_Killed = Default_Event_Function,
        Great_Schism_Event = Great_Schism,
        Far_Isle_Event = Far_Isle_Event,
        Flush = Flush,
        Morale_Update = Morale_System_Update,
    }

    ---@class PlanetMoraleEntry
    ---@field Object PlanetObject|nil
    ---@field Owner PlayerWrapper|nil
    ---@field Last_Owner PlayerWrapper|nil
    ---@field Morale number
    ---@field Last_Morale number
    ---@field When_Morale_Last_Changed number

    ---@class MoraleEvent
    ---@field Name string
    ---@field Value number
    ---@field Subtract boolean
    ---@field String string
    ---@field KD_Influence? boolean 
    ---@field Hidden? boolean Deprecated
    ---@field Last_Event_Happened? number Seconds since even happened
    ---@field Benefits_Enemy? boolean Event Loses Morale for faction experiencing it, but other factions gain morale from it

    ---@class MoraleEventTable
    ---@field Events table<string, MoraleEvent>
    ---@field Recent MoraleEvent[]|Random_Event[]
    Morale_Event_Table = {
        Events = {
            ["Morale_Lost_Battle"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS_NAME", Value = 2, Subtract = true, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS"},
            ["Morale_Lost_Battle_Major"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS_STREAK_NAME", Value = 7, Subtract = true, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_LOSS_STREAK"},
            ["Morale_Won_Battle"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN_NAME", Value = 1, Subtract = false, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN"},
            ["Morale_Won_Battle_Major"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN_STREAK_NAME", Value = 3, Subtract = false, KD_Influence = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_BATTLE_WIN_STREAK"},
            ["Morale_Construction_Event_Minor"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MINOR_NAME", Value = 1, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MINOR"},
            ["Morale_Construction_Event"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_NAME", Value = 2, Subtract = false,String = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION"},
            ["Morale_Construction_Event_Major"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MAJOR_NAME", Value = 3, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_CONSTRUCTION_MAJOR"},
            ["Hero_Lost"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_LOST_NAME", Value = 8, Subtract = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_LOST"},
            ["Hero_Killed"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_KILLED_NAME", Value = 3, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_KILLED"},
            ["Great_Schism_Event"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_GREAT_SCHISM_NAME", Value = 25, Subtract = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_GREAT_SCHISM", Hidden = true, Benefits_Enemy = true},
            ["Far_Isle_Event"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_FAR_ISLE_NAME", Value = 25, Subtract = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_FAR_ISLE", Hidden = true, Benefits_Enemy = true},
            ["Morale_Hero_Rescued"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_RESCUED_NAME", Value = 10, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_HERO_RESCUED"},
            ["Morale_Negative_Construction_Event_Minor"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_NEGATIVE_CONSTRUCTION_MINOR_NAME", Value = 1, Subtract = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_NEGATIVE_CONSTRUCTION_MINOR"},
            ["Morale_Negative_Construction_Event"] = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_NEGATIVE_CONSTRUCTION_NAME", Value = 3, Subtract = true, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_NEGATIVE_CONSTRUCTION"},
        },
        
        Recent = {}
    }

    function Morale_Event_Table:Add_Recent(Event)
        if type(Event) ~= "table" or type(Event.Value) ~= "number" then
            Event = {Name = "TEXT_STORY_MORALE_DISPLAY_EVENT_UNKNOWN", Value = 0, Subtract = false, String = "TEXT_STORY_MORALE_DISPLAY_EVENT_UNKNOWN"}
        end

        table.insert(self.Recent, 1, Event)

        local n = tableLength(self.Recent)

        local Recent_Cap = 5

        if n > Recent_Cap then
            for i=n, Recent_Cap + 1, -1 do
                table.remove(self.Recent, i)
            end
        end
    end

    function Morale_Event_Table:Most_Recent()
        return self.Recent[1]
    end

    function Morale_Event_Table:Trigger(Event_Name)

        local Event = self.Events[Event_Name]

        if Event == nil then
            return
        end

        Event.Last_Event_Happened = GetCurrentTime.Galactic_Time()
    end

    function Morale_Event_Table:Time_Since_Event(Event_Name)
        local Event = self.Events[Event_Name]

        if Event == nil then
            return 0
        end

        if Event.Last_Event_Happened == nil then
            return 0
        end

        local Time_Since = GetCurrentTime.Galactic_Time() - Event.Last_Event_Happened

        if Time_Since < 0 then
            Time_Since = 0
        end

        return Time_Since
    end

    UNSC_Kill_Ratio_Table = {0, 5000, 12500, 20000, 25000} -- the index is the morale gain from the kill ratio at that index

    COVN_Kill_Ratio_Table = {0, 15000, 20000, 32500, 50000}

    ---@class Morale_Bonus
    ---@field Battle string
    ---@field Production string

    ---@class Morale_Level
    ---@field Range number[]
    ---@field Punishment boolean
    ---@field Name string
    ---@field Display_Name string
    ---@field Bonus Morale_Bonus
    ---@field Description string
    ---@field Color table[]

    ---@type Morale_Level[]
    Morale_Levels = {
        {Range = {0,15}, Punishment = true, Name = "Compromised", Color = {r=224,g=40,b=40}, Display_Name = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_COMPROMISED_DESCRIPTION"},
        {Range = {16,35}, Punishment = false, Name = "Strained", Color = {r=235,g=150,b=70}, Display_Name = "TEXT_STORY_MORALE_DISPLAY_STRAINED", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_STRAINED_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_STRAINED_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_STRAINED_DESCRIPTION"},
        {Range = {36,74}, Punishment = false, Name = "Stabilized", Color = {r=255,g=255,b=255}, Display_Name = "TEXT_STORY_MORALE_DISPLAY_STABILIZED", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_STABILIZED_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_STABILIZED_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_STABILIZED_DESCRIPTION"},
        {Range = {75,89}, Punishment = false, Name = "Resolute", Color = {r=131,g=199,b=147}, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_RESOLUTE_DESCRIPTION"},
        {Range = {90,100}, Punishment = false, Name = "Ascendant", Color = {r=111,g=207,b=59}, Display_Name = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT", Bonus = {Battle = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT_BATTLE_BONUS", Production = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT_PRODUCTION_BONUS"}, Description = "TEXT_STORY_MORALE_DISPLAY_ASCENDANT_DESCRIPTION"},
    }

    Modifiers = {
        EMPIRE = {
            ["Normal"] = {
                Morale_Gain_Multiplier = 0.75, --- Does not affect Morale loss, only applies when gaining morale
                Random_Morale_Gain_Loss = {1,2}, --- The Range at which we +/- to the random event morale 
                Yearly_Planetary_Morale_Loss = -15, -- when player is in low morale, how much morale does a planet lose every year out of 100, so 100/10 = 10 years to planet loss
                Battle_Win_Streak_Requirement = 8, --- How many battles do we have to win in a row to count for the battle win streak
                Negative_Random_Event_Weight_Multiplier = 1.05, --- Multiplies negative random morale event weight by this number rounded down
                Random_Events_Morale_Level_Multiplier = {
                    ["Compromised"] = {
                        Positive = 1.5,
                        Negative = 0.5
                    },
                    ["Strained"] = {
                        Positive = 1.25,
                        Negative = 0.75,
                    },
                    ["Stabilized"] = {
                        Positive = 1,
                        Negative = 1,
                    },
                    ["Resolute"] = {
                        Positive = .75,
                        Negative = 1.25
                    },
                    ["Ascendant"] = {
                        Positive = 0.5,
                        Negative = 1.5,
                    }
                }

            },
            ["Hard"] = {
                Morale_Gain_Multiplier = 0.5,
                Random_Morale_Gain_Loss = {1,1},
                Yearly_Planetary_Morale_Loss = -20,
                Battle_Win_Streak_Requirement = 12,
                Negative_Random_Event_Weight_Multiplier = 1.1,
                Random_Events_Morale_Level_Multiplier = {
                    ["Compromised"] = {
                        Positive = 1.5,
                        Negative = 0.5
                    },
                    ["Strained"] = {
                        Positive = 1.25,
                        Negative = 0.75,
                    },
                    ["Stabilized"] = {
                        Positive = 1,
                        Negative = 1,
                    },
                    ["Resolute"] = {
                        Positive = .75,
                        Negative = 1.25
                    },
                    ["Ascendant"] = {
                        Positive = 0.5,
                        Negative = 1.5,
                    }
                }
            }
        },
        Default = {
            ["Default"] = {
                Morale_Gain_Multiplier = 1,
                Random_Morale_Gain_Loss = {0,2},
                Yearly_Planetary_Morale_Loss = -10,
                Battle_Win_Streak_Requirement = 6,
                Negative_Random_Event_Weight_Multiplier = 1,
                Random_Events_Morale_Level_Multiplier = {
                    ["Compromised"] = {
                        Positive = 1.5,
                        Negative = 0.5
                    },
                    ["Strained"] = {
                        Positive = 1.25,
                        Negative = 0.75,
                    },
                    ["Stabilized"] = {
                        Positive = 1,
                        Negative = 1,
                    },
                    ["Resolute"] = {
                        Positive = .75,
                        Negative = 1.25
                    },
                    ["Ascendant"] = {
                        Positive = 0.5,
                        Negative = 1.5,
                    }
                }
            },
            ["Easy"] = {
                Morale_Gain_Multiplier = 1,
                Random_Morale_Gain_Loss = {0,2},
                Yearly_Planetary_Morale_Loss = -10,
                Battle_Win_Streak_Requirement = 6,
                Negative_Random_Event_Weight_Multiplier = 1,
                Random_Events_Morale_Level_Multiplier = {
                    ["Compromised"] = {
                        Positive = 1.5,
                        Negative = 0.5
                    },
                    ["Strained"] = {
                        Positive = 1.25,
                        Negative = 0.75,
                    },
                    ["Stabilized"] = {
                        Positive = 1,
                        Negative = 1,
                    },
                    ["Resolute"] = {
                        Positive = .75,
                        Negative = 1.25
                    },
                    ["Ascendant"] = {
                        Positive = 0.5,
                        Negative = 1.5,
                    }
                }
            },
            ["Normal"] = {
                Morale_Gain_Multiplier = 1,
                Random_Morale_Gain_Loss = {0,2},
                Yearly_Planetary_Morale_Loss = -10,
                Battle_Win_Streak_Requirement = 6,
                Negative_Random_Event_Weight_Multiplier = 1,
                Random_Events_Morale_Level_Multiplier = {
                    ["Compromised"] = {
                        Positive = 1.5,
                        Negative = 0.5
                    },
                    ["Strained"] = {
                        Positive = 1.25,
                        Negative = 0.75,
                    },
                    ["Stabilized"] = {
                        Positive = 1,
                        Negative = 1,
                    },
                    ["Resolute"] = {
                        Positive = .75,
                        Negative = 1.25
                    },
                    ["Ascendant"] = {
                        Positive = 0.5,
                        Negative = 1.5,
                    }
                }
            },
            ["Hard"] = {
                Morale_Gain_Multiplier = 1,
                Random_Morale_Gain_Loss = {0,2},
                Yearly_Planetary_Morale_Loss = -10,
                Battle_Win_Streak_Requirement = 6,
                Negative_Random_Event_Weight_Multiplier = 1,
                Random_Events_Morale_Level_Multiplier = {
                    ["Compromised"] = {
                        Positive = 1.5,
                        Negative = 0.5
                    },
                    ["Strained"] = {
                        Positive = 1.25,
                        Negative = 0.75,
                    },
                    ["Stabilized"] = {
                        Positive = 1,
                        Negative = 1,
                    },
                    ["Resolute"] = {
                        Positive = .75,
                        Negative = 1.25
                    },
                    ["Ascendant"] = {
                        Positive = 0.5,
                        Negative = 1.5,
                    }
                }
            }
        }
    }

    function Modifiers:Get_Modifiers(Faction)
        if Global_Values.Difficulty == nil then
            return self.Default["Default"]
        end

        if Faction == nil or Faction.Get_Faction_Name == nil then
            return self.Default[Global_Values.Difficulty]
        end

        local Faction_Name = string.upper(Faction.Get_Faction_Name())

        if self[Faction_Name] == nil then
            return self.Default[Global_Values.Difficulty]
        end

        if self[Faction_Name][Global_Values.Difficulty] == nil then
            return self.Default[Global_Values.Difficulty]
        end

        return self[Faction_Name][Global_Values.Difficulty]
    end

    Global_Values = {
        ---@type PlayerWrapper
        Player = nil,
        ---@type PlayerWrapper
        Enemy = nil,
        ---@type string
        Difficulty = nil,
        ---@type StoryPlot
        Plot = nil,
        ---@type StoryEvent
        Display_Event = nil,
        Can_Lose_Only_Planet = false,
        ---@type PlanetObject[]
        Planets = {},
        Starting_Year = 2490,
        Current_Year = 2490,
        Total_Auto_Resolves = 0,
        Easter_Egg_Triggered = false,
        Auto_Resolve_Trigger = 117,
    }

    Morale_Value_Status = {
        Current = 100,
        Last = 100,
        ---@type PlanetObject|nil
        Targeted_Planet = nil,
        Last_Morale_Gain = 0,
        Last_Morale_Loss = 0,
    }

    function Morale_Value_Status:Modify_Morale(Amount, Negative)

        if type(Amount) ~= "number" then
            return
        end

        Amount = abs(Amount)

        if Negative ~= true then
            Negative = false
        end

        if Negative then
            self:Morale_Loss()
            Amount = Amount * -1
        else
            self:Morale_Gain()
        end

        DebugMessage("%s -- Modifying Morale by: %s, Is Bad: %s, Current Morale: %s", tostring(Script), tostring(Amount), tostring(Negative), tostring(self.Current))

        self.Last = self.Current

        local New_Morale = self.Current + Amount

        if New_Morale < 0 then
            New_Morale = 0
        end

        if New_Morale > 100 then
            New_Morale = 100
        end

        self.Current = New_Morale
    end

    function Morale_Value_Status:Morale_Gain()
        self.Last_Morale_Gain = GetCurrentTime.Galactic_Time()
    end

    function Morale_Value_Status:Morale_Loss()
        self.Last_Morale_Loss = GetCurrentTime.Galactic_Time()
    end

    function Morale_Value_Status:Time_Since_Morale_Gain()
        local Time_Since = GetCurrentTime.Galactic_Time() - self.Last_Morale_Gain

        if Time_Since < 0 then
            Time_Since = 0
        end

        return Time_Since
    end

    Battle_Info = {
        Win_Streak = 0,
        Loss_Streak = 0
    }

    function Battle_Info:Increase_Win_Streak() 
        self.Win_Streak = self.Win_Streak + 1

        if type(self.Win_Streak) ~= "number" then
            self.Win_Streak = 0
        end

        self.Loss_Streak = 0
    end

    function Battle_Info:Increase_Loss_Streak()
        self.Loss_Streak = self.Loss_Streak + 1

        if type(self.Loss_Streak) ~= "number" then
            self.Loss_Streak = 0
        end

        self.Win_Streak = 0
    end

    morale_string = {
        Target_Planet = "TEXT_STORY_MORALE_DISPLAY_TARGET_PLANET_INFO",
        Recent_Event = {
            Bad = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_BAD",
            Good = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_GOOD",
            None = "TEXT_STORY_MORALE_DISPLAY_RECENT_EVENT_NONE"
        },
        Win_Streak = "TEXT_STORY_MORALE_DISPLAY_WIN_STREAK",
        Loss_Streak = "TEXT_STORY_MORALE_DISPLAY_LOSS_STREAK",
        Bonuses = "TEXT_STORY_MORALE_DISPLAY_BONUSES",
    }

    Planetary_Pathing_Table = nil

    ---@alias Planet_Morale_Table table<string, PlanetMoraleEntry>
    Planet_Morale_Table = nil
    
    ---@class Random_Event
    ---@field Base_Morale number
    ---@field Negative boolean
    ---@field Base_Weight number
    ---@field Current_Weight? number This is created on init and updated on every cycle
    ---@field Display_Name string
    ---@field String string

    ---@class Random_Events
    ---@field Distribution_Table DynamicWeightTable|nil
    ---@field Possible_Events table<string, Random_Event>
    ---@field Next_Random_Event number
    ---@field Last_Random_Event number
    Random_Events = {
        Distribution_Table = nil,
        Possible_Events = {
            ["Milita_Crackdown"] = {Base_Morale = 3, Negative = false, Base_Weight = 60, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_MILITA_CRACKDOWN_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_MILITA_CRACKDOWN"},
            ["Milita_Advance"] = {Base_Morale = 4, Negative = true, Base_Weight = 45, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_MILITA_ADVANCE_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_MILITA_ADVANCE"},

            ["Colony_Breakdown"] = {Base_Morale = 3, Negative = true, Base_Weight = 35, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_COLONY_BREAKDOWN_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_COLONY_BREAKDOWN"},
            ["Colony_Evacuation"] = {Base_Morale = 4, Negative = true, Base_Weight = 30, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_COLONY_EVACUATION_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_COLONY_EVACUATION"},
            ["Colony_Celebration"] = {Base_Morale = 3, Negative = false, Base_Weight = 55, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_COLONY_CELEBRATION_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_COLONY_CELEBRATION"},

            ["Wartime_Scientific_Advancement"] = {Base_Morale = 5, Negative = false, Base_Weight = 35, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_WARTIME_SCIENTIFIC_ADVANCEMENT_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_WARTIME_SCIENTIFIC_ADVANCEMENT"},
            ["Wartime_Fears"] = {Base_Morale = 2, Negative = true, Base_Weight = 55, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_WARTIME_FEARS_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_WARTIME_FEARS"},

            ["Settlement_Created"] = {Base_Morale = 3, Negative = false, Base_Weight = 60, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_SETTLEMENT_CREATED_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_SETTLEMENT_CREATED"},
            ["Settlement_Grew"] = {Base_Morale = 2, Negative = false, Base_Weight = 65, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_SETTLEMENT_GREW_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_SETTLEMENT_GREW"},
            ["Settlement_Abandonded"] = {Base_Morale = 3, Negative = true, Base_Weight = 35, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_SETTLEMENT_ABANDONDED_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_SETTLEMENT_ABANDONDED"},

            ["Wartime_Propaganda"] = {Base_Morale = 4, Negative = false, Base_Weight = 55, Display_Name = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_WARTIME_PROPAGANDA_NAME", String = "TEXT_STORY_MORALE_DISPLAY_RANDOM_EVENT_WARTIME_PROPAGANDA"}
        },
        Random_Chances = {
            Current_Chance = 0.002,
            Chance_Increase_Per_Tick = 0.001,
            Chance_Cap = 0.5,
            Last_Happened = 0,
        }
    }

    function Random_Events:Update_Random_Event_Weight(Key, Weight)
        if type(Key) ~= "string" then
            return
        end

        if type(Weight) ~= "number" then
            return
        end

        if Weight < 0 then
            Weight = 0
        end

        if Weight > 100 then
            Weight = 100
        end

        Weight = tonumber(Dirty_Floor(Weight))

        if type(Weight) ~= "number" then
            return
        end

        local Entry = self.Possible_Events[Key]

        if not Entry then
            return
        end

        self.Possible_Events[Key].Current_Weight = Weight
    end

    function Random_Events.Random_Chances:Increase_Chance()
        self.Current_Chance = self.Current_Chance + self.Chance_Increase_Per_Tick

        DebugMessage("%s -- Increasing Current Chance to: %s, By Adding: %s", tostring(Script), tostring(self.Current_Chance), tostring(self.Chance_Increase_Per_Tick))

        if self.Current_Chance > self.Chance_Cap then
            self.Current_Chance = self.Chance_Cap
        end
    end

    function Random_Events.Random_Chances:Should_Random_Event_Happen()
        local roll = (EvenMoreRandom(1,100) / 100)

        if roll <= 0.01 then
            roll = 0.005
        end

        DebugMessage("%s -- Checking for Random Event. Current Chance: %s, Roll: %s, Random Event Last Happened: %s, Current Time: %s", tostring(Script), tostring(self.Current_Chance), tostring(roll), tostring(self.Last_Happened), tostring(GetCurrentTime.Galactic_Time()))

        if roll <= self.Current_Chance and GetCurrentTime.Galactic_Time() >= self.Last_Happened + 5 then
            DebugMessage("%s -- Triggering Random Event", tostring(Script))
            self.Current_Chance = 0.0005
            self.Last_Happened = GetCurrentTime.Galactic_Time()
            return true
        end

        self:Increase_Chance()

        return false
    end

    ---@alias Random_Events_Filter "All" | "Positive" | "Negative" | "Positive | Negative"

    ---@param filter Random_Events_Filter
    ---@return string[], string[]?
    function Random_Events:Return_Events(filter)
        if type(filter) ~= "string" then
            return {}
        end

        local return_negative = filter == "Negative"

        local return_positive = filter == "Positive"

        local return_seperate = filter == "Positive | Negative"

        local return_all = filter == "All"

        local events = {
            Positive = {},
            Negative = {}
        }

        for Key, Event in pairs(self.Possible_Events) do

            if Event.Negative then
               table.insert(events.Negative,Key)
            else
                table.insert(events.Positive, Key)
            end
        end

        local combined_events = Fast_Join(events.Positive, events.Negative)

        if return_all then
            return combined_events
        end

        if return_negative then
            return events.Negative
        end

        if return_positive then
            return events.Positive
        end

        if return_seperate then
            return events.Positive, events.Negative
        end

        return {}
    end

    Misc_Morale_Income = {
        Net = 0,
        Last_Updated = 1,
        Tax = {
            Enabled = false,
            Portion_Was_Tax = 0,
        }
    }

end

function Init_Morale_System(message)
    if message == OnEnter then

        Global_Values.Player = Find_Human_Player()

        Global_Values.Plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Morale_System.xml")

        if StringCompare(Global_Values.Player.Get_Faction_Name(), "Rebel") or StringCompare(Global_Values.Player.Get_Faction_Name(), "Terrorists") then
            Story_Event("Morale_Display_UNSC")

            Global_Values.Display_Event = Global_Values.Plot.Get_Event("Morale_Display_UNSC")

            morale_string.Level = "TEXT_STORY_MORALE_DISPLAY_BODY_UNSC_VALUES"

            Misc_Morale_Income.Tax.Enabled = true
        else
            Story_Event("Morale_Display_COVN")

            morale_string.Level = "TEXT_STORY_MORALE_DISPLAY_BODY_COVN_VALUES"

            Global_Values.Display_Event = Global_Values.Plot.Get_Event("Morale_Display_COVN")
        end

        GlobalValue.Set("Morale_Active", 1)

        if StringCompare(Global_Values.Player.Get_Faction_Name(), "Empire") then
            Global_Values.Enemy = Find_Player("REBEL")
        else
            Global_Values.Enemy = Find_Player("EMPIRE")
        end

        --DebugMessage("%s -- Enemy Player: %s", tostring(Script), tostring(enemy))

        if TestValid(Global_Values.Enemy) then
            Global_Values.Difficulty = Global_Values.Enemy.Get_Difficulty()
        end

        --DebugMessage("%s -- Current Difficulty: %s", tostring(Script), tostring(Difficulty))

        local New_Starting_Morale_Value = 100

        if StringCompare(Global_Values.Difficulty, "Normal") then

            New_Starting_Morale_Value = EvenMoreRandom(40,60)
            --New_Starting_Morale_Value = 74

        elseif StringCompare(Global_Values.Difficulty, "Hard") then

            New_Starting_Morale_Value = EvenMoreRandom(18,30)

            Global_Values.Can_Lose_Only_Planet = true
        end
        
        Morale_Value_Status.Current = New_Starting_Morale_Value

        Morale_Value_Status.Last = New_Starting_Morale_Value

        local planets = Planet_Table:Return_All_Keys()

        for i,planet_name in pairs(planets) do

            local planet = FindPlanet(planet_name)

            if TestValid(planet) then
                table.insert(Global_Values.Planets, planet)
            end
        end

        Planetary_Pathing_Table = Build_Neighbor_Table()

        Planet_Morale_Table = Build_Morale_Table()

        Random_Events.Distribution_Table = DynamicWeightTable.New()

        for Random_Event_Name, Random_Event in pairs(Random_Events.Possible_Events) do

            local Diff_Modifiers = Modifiers:Get_Modifiers(Global_Values.Player)

            local Weight = Random_Event.Base_Weight

            if Random_Event.Negative then
                Weight = tonumber(Dirty_Floor(Diff_Modifiers.Negative_Random_Event_Weight_Multiplier * Random_Event.Base_Weight))

                if type(Weight) ~= "number" then
                    Weight = Random_Event.Base_Weight
                end
            end

            Random_Events:Update_Random_Event_Weight(Random_Event_Name, Weight)

            Random_Events.Distribution_Table:Insert(Random_Event_Name,Weight)
        end

        Set_Next_State("Flush")
    end
end

function Morale_System_Update(message)
    if message == OnUpdate then

        --DebugMessage("%s -- Current Game Mode: %s", tostring(Script), tostring(Get_Game_Mode()))

        --DebugMessage("%s -- Time: %s, Galactic Time: %s, Frame: %s", tostring(Script), tostring(GetCurrentTime()), tostring(GetCurrentTime.Galactic_Time()), tostring(GetCurrentTime.Frame()))

        --DebugMessage("%s -- Win Streak: %s, Loss Streak: %s", tostring(Script), tostring(win_streak), tostring(loss_streak))

        --DebugMessage("%s -- Current Morale Level: %s", tostring(Script), tostring(global_morale_level))

        if Global_Values.Total_Auto_Resolves == Global_Values.Auto_Resolve_Trigger and not Easter_Egg_Triggered then
            Play_Bink_Movie("Not_An_Easter_Egg")

            Easter_Egg_Triggered = true
        end

        Reset_Morale_Entries()

        if Morale_Value_Status.Current > 100 then
            Morale_Value_Status.Current = 100
        elseif Morale_Value_Status.Current < 0 then
            Morale_Value_Status.Current = 0
        end

        local Current_Morale_Entry = Get_Morale_Level()

        local Current_Morale_Status = nil

        if Current_Morale_Entry ~= nil then

            Current_Morale_Status = Current_Morale_Entry.Name

            morale_string.Battle_Bonus = Current_Morale_Entry.Bonus.Battle

            morale_string.Production_Bonus = Current_Morale_Entry.Bonus.Production

            morale_string.Description = Current_Morale_Entry.Description

            --DebugMessage("%s -- Morale Display Strings: %s, %s, %s, %s", tostring(Script), tostring(Current_Morale_Status.Name), tostring(Current_Morale_Status.Bonus.Battle), tostring(status.Bonus.Production), tostring(status.Description))

            Handle_Planet_Production(Current_Morale_Entry)

            Handle_Misc_Income()

        else
            return
        end

        Random_Morale_Swing()

        Dynamic_Year_Header()
        
        if GlobalValue.Get("Morale_Status") ~= Current_Morale_Status and GlobalValue.Get("Morale_Status") ~= nil then
            Story_Event("Morale_Level_Changed_" .. string.upper(Current_Morale_Entry.Name))

            GUI_Component_Flash("b_story_arc_g", false, 4, 3)
            
            --Show_Screen_Text("TEXT_STORY_MORALE_DISPLAY_ALERT_" .. string.upper(Current_Morale_Entry.Name), nil, 10, {r=255,b=0,g=0}, true)

            Display_Handler:Add_Body("TEXT_STORY_MORALE_DISPLAY_ALERT_" .. string.upper(Current_Morale_Entry.Name), 8, true, {r=235,g=189,b=52}, nil)

            Display_Handler:Update_Header("TEXT_STORY_MORALE_DISPLAY_TEXT_CURRENT_NAME_"..string.upper(GlobalValue.Get("Morale_Status")), "TEXT_STORY_MORALE_DISPLAY_TEXT_CURRENT_NAME_".. string.upper(Current_Morale_Entry.Name), Current_Morale_Entry.Color)
        
            Handle_Random_Event_Weights(Current_Morale_Status)
        end

        Display_Handler:Add_Header("TEXT_STORY_MORALE_DISPLAY_TEXT_CURRENT_NAME_".. string.upper(Current_Morale_Entry.Name), Current_Morale_Entry.Color)
        Display_Handler:Add_Header("TEXT_STORY_MORALE_DISPLAY_TEXT_CURRENT_LEVEL","white",Find_Object_Type(tostring(abs(Morale_Value_Status.Current))))

        GlobalValue.Set("Morale_Status", Current_Morale_Status)

        --DebugMessage("%s -- Current Morale Status: %s", tostring(Script), tostring(Current_Morale_Status))

        if Global_Values.Display_Event ~= nil and Current_Morale_Status ~= nil then

            Global_Values.Display_Event.Clear_Dialog_Text()

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, nil, true, true)

            Add_Display_Text(morale_string.Level, Current_Morale_Entry.Display_Name, tostring(Morale_Value_Status.Current))
            Add_Display_Text(morale_string.Description, nil, nil, false, true)

            Add_Display_Text(morale_string.Battle_Bonus)
            Add_Display_Text(morale_string.Production_Bonus, false, false, false, false)

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, nil, true, true)

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MISC_SOURCES_TITLE", nil, nil, false, true)

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MISC_SOURCES", tostring(Misc_Morale_Income.Last_Updated))

            if Misc_Morale_Income.Net < 0 then
                Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MISC_SOURCES_NET_BAD", tostring(abs(Misc_Morale_Income.Net)))
            else
                Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MISC_SOURCES_NET_GOOD", tostring(abs(Misc_Morale_Income.Net)))
            end

            if Misc_Morale_Income.Tax.Enabled then
                Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MISC_SOURCES_TAXES", tostring(Misc_Morale_Income.Tax.Portion_Was_Tax))
            end

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, nil, true, true)

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_PLANETRY_MORALE", nil, nil, false, true)
            

            local Is_On_Last_Planet = Is_Player_On_Last_Planet()

            local Activate_Low_Morale = false

            if Current_Morale_Entry ~= nil and Current_Morale_Entry.Punishment then
                if (not Is_On_Last_Planet) or Global_Values.Can_Lose_Only_Planet then
                    Activate_Low_Morale = true
                end
            end

            if Activate_Low_Morale then
                Low_Planet_Morale()

                Display_Handler:Add_Header("TEXT_STORY_MORALE_DISPLAY_TEXT_REBELLING_PLANETS", "red")

                if Morale_Value_Status.Targeted_Planet ~= nil then
                    local targeted_planet_entry = Get_Planet_Morale(Morale_Value_Status.Targeted_Planet)

                    if targeted_planet_entry ~= nil then
                        Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_TARGET_PLANET_TITLE")

                        Add_Display_Text(morale_string.Target_Planet, Planet_Table:Get_Planet_String(Morale_Value_Status.Targeted_Planet), tostring(targeted_planet_entry.Morale))
                    end
                end
            else
                Display_Handler:Remove_Header("TEXT_STORY_MORALE_DISPLAY_TEXT_REBELLING_PLANETS")
                Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_TARGET_PLANET_NONE")
                High_Planet_Morale()
            end

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, nil, true, true)

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_RECENT_EVENTS", nil, nil, false, true)

            if tableLength(Morale_Event_Table.Recent) > 0 then

                for _, Event in ipairs(Morale_Event_Table.Recent) do

                local Recent_Event_String = morale_string.Recent_Event.Good

                if Event.Subtract or Event.Negative then
                    Recent_Event_String = morale_string.Recent_Event.Bad
                end

                Add_Display_Text(Recent_Event_String, Event.Name, Event.Value)

                end
            else
                Add_Display_Text(morale_string.Recent_Event.None)
            end

            if Battle_Info.Win_Streak > 0 then
                Add_Display_Text(morale_string.Win_Streak, tostring(Battle_Info.Win_Streak), nil, true)
            end

            if Battle_Info.Loss_Streak > 0 then
                Add_Display_Text(morale_string.Loss_Streak, tostring(Battle_Info.Loss_Streak))
            end

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, nil, true, true)

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_MORALE_LEVELS", nil, nil, false, true)


            for _, entry in ipairs(Morale_Levels) do

                if entry.Name == Current_Morale_Status then
                    Add_Display_Text(entry.Display_Name .. "_RANGE_CURRENT", tostring(entry.Range[1]), tostring(entry.Range[2]))
                else
                    Add_Display_Text(entry.Display_Name .. "_RANGE", tostring(entry.Range[1]), tostring(entry.Range[2]))
                end
            end

            Add_Display_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, nil, true, true)

            DebugMessage("%s -- End of Main Event Display", tostring(Script))

            Display_Handler:Process()
        end
    end
end

function Add_Display_Text(String, Var_1, Var_2, Add_Spacer_Pre, Add_Spacer_Pro)
    if type(String) ~= "string" then
        return
    end

    if Add_Spacer_Pre then
        Global_Values.Display_Event.Add_Dialog_Text(" ")
    end

    if not Var_1 and not Var_2 then
        Global_Values.Display_Event.Add_Dialog_Text(String)
    end

    if Var_1 and not Var_2 then
        Global_Values.Display_Event.Add_Dialog_Text(String, tostring(Var_1))
    end

    if Var_1 and Var_2 then
        Global_Values.Display_Event.Add_Dialog_Text(String, tostring(Var_1), tostring(Var_2))
    end

    if Add_Spacer_Pro then
        Global_Values.Display_Event.Add_Dialog_Text(" ")
    end
end

function Random_Morale_Swing()

    if Random_Events.Random_Chances:Should_Random_Event_Happen() then

        local Random_Event = Random_Events.Distribution_Table:Sample()

        DebugMessage("%s -- Picking Event: %s", tostring(Script), tostring(Random_Event))

        if Random_Event ~= nil then
            local Random_Event_Entry = Random_Events.Possible_Events[Random_Event]
            

            if Random_Event_Entry ~= nil then

                local Player_Modifiers = Modifiers:Get_Modifiers(Global_Values.Player)

                if Player_Modifiers ~= nil then

                    local Random_Value_Min = Random_Event_Entry.Base_Morale - Player_Modifiers.Random_Morale_Gain_Loss[1]

                    if Random_Value_Min < 0 then
                        Random_Value_Min = 0
                    end

                    local Random_Value_Max = Random_Event_Entry.Base_Morale + Player_Modifiers.Random_Morale_Gain_Loss[2]

                    local Random_Value = EvenMoreRandom(Random_Value_Min, Random_Value_Max)

                    Modify_Morale({Name = Random_Event_Entry.Display_Name, Value = Random_Value, Subtract = Random_Event_Entry.Negative, String = Random_Event_Entry.String})
                end
            end
        end
    end
end

function Handle_Planet_Production(Current_Morale_Entry)

    if Current_Morale_Entry == nil or type(Current_Morale_Entry) ~= "table" or tableLength(Current_Morale_Entry) == 0 then
        return
    end

    local Neutral = Find_Player("NEUTRAL")

    if not TestValid(Neutral) then
        return
    end

    for _, entry in ipairs(Morale_Levels) do
        
        local level_planet = FindPlanet(entry.Name)

        if TestValid(level_planet) then

            --DebugMessage("%s -- Entry: %s, Current Morale: %s, Planet Owner: %s", tostring(Script), tostring(entry.Name), tostring(Current_Morale_Entry.Name), tostring(level_planet.Get_Owner()))

            if entry.Name == Current_Morale_Entry.Name then

                if level_planet.Get_Owner() ~= Global_Values.Player then
                    level_planet.Change_Owner(Global_Values.Player)
                end
            else
                if level_planet.Get_Owner() ~= Neutral then
                    level_planet.Change_Owner(Neutral)
                end
            end
        end
    end
end

function Handle_Misc_Income()

    if Get_Current_Week() <= Misc_Morale_Income.Last_Updated then
        return
    end

    local Positive_Structures = Find_All_Objects_Of_Type(Global_Values.Player, "YearlyMoraleGain")

    local Negative_Structures = Find_All_Objects_Of_Type(Global_Values.Player, "YearlyMoraleLoss")

    local Taxed_Structures = Find_All_Objects_Of_Type(Global_Values.Player, "TaxingBuilding")

    local Positive_Count = tableLength(Positive_Structures)

    local Negative_Count = tableLength(Negative_Structures)

    local Taxed_Structures_Count = tableLength(Taxed_Structures)

    Misc_Morale_Income.Tax.Portion_Was_Tax = Taxed_Structures_Count

    Misc_Morale_Income.Last_Updated = Get_Current_Week()

    local Morale_Change = Positive_Count - Negative_Count

    local Is_Total_Loss = Morale_Change < 0

    local color = "green"

    local Screen_String = "TEXT_STORY_MORALE_DISPLAY_EVENT_MISC_INCOME_GOOD"

    if Morale_Change == 0 then
        color = "white"

        Screen_String = "TEXT_STORY_MORALE_DISPLAY_EVENT_MISC_INCOME_MEH"
    end

    if Is_Total_Loss then
        color = "red"

        Screen_String = "TEXT_STORY_MORALE_DISPLAY_EVENT_MISC_INCOME_BAD"
    end

    Misc_Morale_Income.Net = Morale_Change

    Morale_Value_Status:Modify_Morale(Morale_Change, Is_Total_Loss) -- Modify_Morale already converts numbers to absolute values

    if Screen_String ~= "TEXT_STORY_MORALE_DISPLAY_EVENT_MISC_INCOME_MEH" then
        Display_Handler:Add_Body(Screen_String, 8, true, color)
    end

    --Show_Screen_Text(Screen_String, nil, 8, color, true)
end

function Handle_Random_Event_Weights(Current_Morale_Level)

    if type(Current_Morale_Level) ~= "string" then
        return
    end

    for Random_Event_Name, Event in pairs(Random_Events.Possible_Events) do
        if type(Event.Current_Weight) == "number" then

            local New_Weight = Event.Base_Weight

            local Modifiers = Modifiers:Get_Modifiers(Global_Values.Player)

            if Modifiers ~= nil then
                local Difficulty_Modifier = Modifiers.Negative_Random_Event_Weight_Multiplier

                DebugMessage("%s -- Difficulty Modifier: %s (%s)", tostring(Script), tostring(Difficulty_Modifier), tostring(Global_Values.Difficulty))

                if type(Difficulty_Modifier) == "number" then
                    New_Weight = New_Weight * Difficulty_Modifier
                end

                local Morale_Level_Modifiers = Modifiers.Random_Events_Morale_Level_Multiplier

                if Morale_Level_Modifiers[Current_Morale_Level] ~= nil then
                    local Morale_Level_Modifier = Morale_Level_Modifiers[Current_Morale_Level]

                    DebugMessage("%s -- Morale Level %s Modifiers, Positive: %s, Negative: %s", tostring(Script), tostring(Current_Morale_Level), tostring(Morale_Level_Modifier.Positive), tostring(Morale_Level_Modifier.Negative))

                    if Event.Negative then
                        New_Weight = New_Weight * Morale_Level_Modifier.Negative
                    else
                        New_Weight = New_Weight * Morale_Level_Modifier.Positive
                    end
                end
                
            end

            DebugMessage("%s -- Updating Event %s to new Weight: %s, Base Weight: %s", tostring(Script), tostring(Random_Event_Name), tostring(New_Weight), tostring(Event.Base_Weight))

            Random_Events.Distribution_Table:Update_Weight(Random_Event_Name, New_Weight)
        end
    end
end

---@return Morale_Level|nil
function Get_Morale_Level()

    for _, level in ipairs(Morale_Levels) do
        local min_val = level.Range[1]
        local max_val = level.Range[2]

        if Morale_Value_Status.Current >= min_val and Morale_Value_Status.Current <= max_val then
            return level
        end
    end

    local closest_level = nil
    local closest_distance = math.huge

    for _, level in ipairs(Morale_Levels) do
        local min_val = level.Range[1]
        local max_val = level.Range[2]

        local distance = 0
        if Morale_Value_Status.Current < min_val then
            distance = min_val - Morale_Value_Status.Current
        elseif Morale_Value_Status.Current > max_val then
            distance = Morale_Value_Status.Current - max_val
        end

        if distance < closest_distance then
            closest_distance = distance
            closest_level = level
        end
    end

    return closest_level
end

function Planet_Morale_Updater()
    for planet_name, planet_entry in pairs(Planet_Morale_Table) do
        local planet_object = planet_entry.Object

        if TestValid(planet_object) then

            local new_owner = planet_object.Get_Owner()
            if new_owner ~= nil and planet_object.Get_Owner() ~= planet_entry.Owner then
                planet_entry.Last_Owner = planet_entry.Owner
                planet_entry.Owner = planet_object.Get_Owner()

                planet_entry.Morale = 100
                planet_entry.Last_Morale = 100
                planet_entry.When_Morale_Last_Changed = Get_Current_Week()
            end
        end
    end
end

function Is_Player_On_Last_Planet()
    local Owned_Planets = 0

    for _, Planet in pairs(Global_Values.Planets) do

        if TestValid(Planet) then
            if Planet.Get_Owner() == Global_Values.Player then
                Owned_Planets = Owned_Planets + 1
            end
        end
    end

    return Owned_Planets == 1
end

function Low_Planet_Morale()

    DebugMessage("%s -- Low Morale Active", tostring(Script))

    if Morale_Value_Status.Targeted_Planet == nil or Morale_Value_Status.Targeted_Planet.Get_Owner() ~= Global_Values.Player then
        Morale_Value_Status.Targeted_Planet = Find_First_Loss_Planet()
    end
            
    if Morale_Value_Status.Targeted_Planet == nil then
        return
    end

    DebugMessage("%s -- Targeted Planet: %s", tostring(Script), tostring(Morale_Value_Status.Targeted_Planet))

    local target_planet_morale = Get_Planet_Morale(Morale_Value_Status.Targeted_Planet)

    if target_planet_morale == nil then
        return
    end

    DebugMessage("%s -- Targeted Planet Morale", tostring(Script))

    PrintTable(target_planet_morale)

    DebugMessage("%s -- %s Last Morale Update: %s, Current Week: %s", tostring(Script), tostring(Morale_Value_Status.Targeted_Planet), tostring(target_planet_morale.When_Morale_Last_Changed), tostring(Get_Current_Week()))

    if target_planet_morale.When_Morale_Last_Changed < Get_Current_Week() then

        local Modifier_Entry = Modifiers:Get_Modifiers(Global_Values.Player)

        if Modifier_Entry ~= nil then
            Modify_Planet_Morale(Morale_Value_Status.Targeted_Planet, Modifier_Entry.Yearly_Planetary_Morale_Loss)
        end       
    end

end

function High_Planet_Morale()

    --DebugMessage("%s -- High Planet Morale", tostring(Script))

    for planet_name, planet_entry in pairs(Planet_Morale_Table) do
        local planet_owner = planet_entry.Owner

        --DebugMessage("%s -- Planet Name: %s, Owner: %s", tostring(Script), tostring(planet_name), tostring(planet_owner.Get_Faction_Name()))

        if planet_owner == Global_Values.Player then
            Modify_Planet_Morale(planet_entry.Object, 5)
        end
    end
end

function Modify_Morale(event_table)

    if Global_Values.Plot == nil then
        return
    end

    if event_table == nil then
        return
    end

    if type(event_table) ~= "table" then
        DebugMessage("%s -- Morale Value is NOT a valid Table", tostring(Script))
        return
    end

    local Morale_Value = event_table.Value

    local bad = event_table.Subtract

    local color = {r=255,g=0,b=0}

    DebugMessage("%s -- Event Morale Value: %s, Subtract: %s, Event Name: %s", tostring(Script), tostring(Morale_Value), tostring(bad), tostring(event_table.Name))

    if not bad then
        DebugMessage("%s -- Applying Morale Gain Multiplier", tostring(Script))

        local Player_Modifiers_Entry = Modifiers:Get_Modifiers(Global_Values.Player)

        DebugMessage("%s -- %s Modifiers Entry: %s", tostring(Script), tostring(Global_Values.Player), tostring(Player_Modifiers_Entry))

        if Player_Modifiers_Entry ~= nil then

            Morale_Value = tonumber(Dirty_Floor(Morale_Value * Player_Modifiers_Entry.Morale_Gain_Multiplier))

            if type(Morale_Value) ~= "number" or Morale_Value < 1 then
                Morale_Value = event_table.Value
            end
        end

        color = {r=255,g=255,b=255}
    end


    Morale_Value_Status:Modify_Morale(Morale_Value, bad)

    local Fake_Morale_Type = Find_Object_Type(tostring(abs(Morale_Value)))

    DebugMessage("%s -- Number object %s for Morale Value: %s", tostring(Script), tostring(Fake_Morale_Type), Morale_Value)

    if Fake_Morale_Type ~= nil then
        Display_Handler:Add_Body(event_table.String, 15, true, color, Fake_Morale_Type)
    end

    event_table.Happened = Get_Current_Week()

    Morale_Event_Table:Add_Recent(event_table)

    Morale_Event_Table:Trigger(Get_Current_State())

end

---@param Affected_Player? PlayerWrapper|nil
---@return MoraleEvent
function Get_Morale_Influence(Affected_Player)
    local State = Get_Current_State()

    ---@type MoraleEvent|nil
    local Morale_Values = Clone_Table(Morale_Event_Table.Events[State])

    DebugMessage("%s -- Morale Value for State %s", tostring(Script), tostring(State))

    PrintTable(Morale_Values)

    if type(Morale_Values) == "table" then
        if Morale_Values.KD_Influence == true then
            local New_Morale_Value = Morale_Kill_Ratio_Influence(Morale_Values.Value, Morale_Values.Subtract)

            Morale_Values.Value = New_Morale_Value
        end

        if Morale_Values.Benefits_Enemy then
            if Global_Values.Player ~= Affected_Player then
                Morale_Values.Subtract = false
            end
        end

        return Morale_Values
    else
        return {Value = 0, Subtract = false, Name = "No Entry"}
    end
end

function Morale_Kill_Ratio_Influence(Base_Morale, is_loss)

    if is_loss ~= true then
        is_loss = false
    end

    if type(Base_Morale) ~= "number" then
        return 0
    end

    local Kill_Ratio = GlobalValue.Get("Morale_Kill_Ratio") -- We switched to Points, 1 kill is 100 points, 1 death is -50 points, but too much effort to change variable names

    DebugMessage("%s -- Kill Ratio: %s", tostring(Script), tostring(Kill_Ratio))

    if Kill_Ratio == nil then
        Global_Values.Total_Auto_Resolves = Global_Values.Total_Auto_Resolves + 1
        return Base_Morale
    end

    if Kill_Ratio <= 0 then -- if this is true we didnt get the proper kill ratio
        Global_Values.Total_Auto_Resolves = Global_Values.Total_Auto_Resolves + 1
        return Base_Morale
    end

    local Nearest_Kill_Ratio_Morale_Gain = 0

    local Kill_Ratio_Table = UNSC_Kill_Ratio_Table

    if Global_Values.Player == Find_Player("EMPIRE") then
        Kill_Ratio_Table = COVN_Kill_Ratio_Table
    end

    for morale_gain, ratio in pairs(Kill_Ratio_Table) do
        if Kill_Ratio >= ratio then
            Nearest_Kill_Ratio_Morale_Gain = morale_gain
        end
    end

    DebugMessage("%s -- Morale Gain for KD %s: %s", tostring(Script), tostring(Kill_Ratio), tostring(Nearest_Kill_Ratio_Morale_Gain))

    local Final_Morale_Gain = Nearest_Kill_Ratio_Morale_Gain

    local Max_Morale_Gain = tableLength(Kill_Ratio_Table)

    if is_loss then
        Final_Morale_Gain = Max_Morale_Gain - Nearest_Kill_Ratio_Morale_Gain
    end
    
    if Final_Morale_Gain > Max_Morale_Gain then
        Final_Morale_Gain = Max_Morale_Gain
    elseif Final_Morale_Gain < 0 then
        Final_Morale_Gain = 0
    end

    DebugMessage("%s -- Final Morale Gain: %s", tostring(Script), tostring(Final_Morale_Gain))

    return Final_Morale_Gain
end

---@param text string
---@param var any|nil
---@param time_to_show number
---@param color? table
---@param teletype? boolean
function Show_Screen_Text(text, var, time_to_show, color, teletype) -- inspired by the Thrawns Revenge Team but slightly modified to fit our purpose
    
    if Global_Values.Plot == nil then
        return
    end

    local text_event = Global_Values.Plot.Get_Event("Show_Screen_Text")

    if text_event == nil then
        return
    end

    if type(text) ~= "string" then
        return
    end

    local colorstring = ""

    if color == nil then
        color = {r = 255, g = 255, b = 255}
    end
    
    if color then
        colorstring = color.r .. " " .. color.g .. " " .. color.b
    end

    local use_teletype = 0
    if teletype == true then
        use_teletype = 1
    end

    if var == nil then
        var = ""
    end

    DebugMessage("%s -- Running Screen Text for Output: %s", tostring(Script), tostring(text))

    text_event.Set_Reward_Parameter(0, text)
    text_event.Set_Reward_Parameter(1,tostring(time_to_show)) -- time in seconds
    text_event.Set_Reward_Parameter(2, var) -- parameter we dont care about
    text_event.Set_Reward_Parameter(3, "")
    text_event.Set_Reward_Parameter(4, use_teletype) -- whether or not the text is slowly typed out or is just shown
    text_event.Set_Reward_Parameter(5, colorstring) -- for color
    text_event.Set_Reward_Parameter(6, "System")
    Story_Event("SHOW_SCREEN_TEXT")
end

function Remove_Screen_Text(text)
    if Global_Values.Plot == nil then
        return
    end

    local text_event = Global_Values.Plot.Get_Event("Show_Screen_Text")

    if text_event == nil then
        return
    end

    if type(text) ~= "string" then
        return
    end

    text_event.Set_Reward_Parameter(0, text)
    text_event.Set_Reward_Parameter(3, "remove")
    Story_Event("SHOW_SCREEN_TEXT")
end

function Build_Neighbor_Table()

    local neighbor_table = {}

    for _, planet in pairs(Global_Values.Planets) do

        if TestValid(planet) then

            local planet_name = planet.Get_Type().Get_Name()

            if neighbor_table[planet_name] == nil then
                neighbor_table[planet_name] = {} 
                neighbor_table[planet_name].Object = planet
                neighbor_table[planet_name].Neighbors = {}
            end

            for _, second_planet in pairs(Global_Values.Planets) do

                if second_planet ~= planet and TestValid(second_planet) then
                    if table.getn(Find_Path(Global_Values.Player, planet, second_planet)) == 2 then
                        table.insert(neighbor_table[planet_name].Neighbors, second_planet)
                    end
                end
            end
        end
    end

    return neighbor_table
end

---@return MoraleTable
function Build_Morale_Table()
    
    ---@type MoraleTable
    local morale_table = {}

    for _, planet in pairs(Global_Values.Planets) do

        if TestValid(planet) then

            local planet_name = planet.Get_Type().Get_Name()

            morale_table[planet_name] = {}

            local planet_entry = morale_table[planet_name]

            planet_entry.Object = planet
            planet_entry.Owner = planet.Get_Owner()
            planet_entry.Last_Owner = planet.Get_Owner()
            planet_entry.Morale = 100
            planet_entry.Last_Morale = 100
            planet_entry.When_Morale_Last_Changed = 0
        end

    end
        
    return morale_table
end

function Reset_Morale_Entries()
    if Planet_Morale_Table == nil then
        return
    end

    for planet_name, entry in pairs(Planet_Morale_Table) do
        
        if TestValid(entry.Object) then
            if entry.Object.Get_Owner() ~= entry.Owner then
                entry.Morale = 100
                entry.Last_Morale = 100
                entry.When_Morale_Last_Changed = Get_Current_Week()
                entry.Last_Owner = entry.Owner
                entry.Owner = entry.Object.Get_Owner()
            end
        end
    end
end

---@param planet PlanetObject|nil
---@return PlanetMoraleEntry|nil
function Get_Planet_Morale(planet)
    if Planet_Morale_Table == nil then
        return nil
    end

    if planet == nil then
        return nil
    end

    if planet.Get_Type == nil then
        return nil
    end

    local planet_name = planet.Get_Type().Get_Name()

    local morale_entry = Planet_Morale_Table[planet_name]

    if morale_entry == nil then
        return nil
    end

    return morale_entry
end

function Modify_Planet_Morale(planet, amount)

    if amount == nil then
        return
    end

    local planet_morale = Get_Planet_Morale(planet)

    if planet_morale == nil then
        return
    end

    local New_Morale = planet_morale.Morale + amount

    if New_Morale > 100 then
        New_Morale = 100
    elseif New_Morale < 0 then
        New_Morale = 0
    end
    
    if New_Morale == 0 and planet.Get_Owner() == Global_Values.Player then

        local new_faction = nil

        if StringCompare(Global_Values.Player.Get_Faction_Name(), "Rebel") then
            new_faction = Find_Player("TERRORISTS")
        else
            new_faction = Find_Player("Swords")
        end

        if TestValid(new_faction) then
            planet.Change_Owner(new_faction)
        end

        return
    end

    planet_morale.Last_Morale = planet_morale.Morale

    planet_morale.Morale = New_Morale

    planet_morale.When_Morale_Last_Changed = Get_Current_Week()
end

function Remove_Planet_Morale(planet)

    if not TestValid(planet) then
        return
    end

    local planet_name = planet.Get_Type().Get_Name()

    Planet_Morale_Table[planet_name] = nil

end

function Find_Neighbors(planet)

    if Planetary_Pathing_Table == nil then
        return nil
    end

    if planet == nil then
        return nil
    end

    if planet.Get_Type().Get_Name == nil then
        return nil
    end

    local planet_name = planet.Get_Type().Get_Name()

    if Planetary_Pathing_Table[planet_name] == nil then
        return nil
    end

    return Planetary_Pathing_Table[planet_name].Neighbors

end

function Count_Enemy_Neighbors(planet)

    if planet == nil then
        return 0
    end

    DebugMessage("%s -- Counting Neighbors for %s", tostring(Script), tostring(planet))

    local planet_neighbors = Find_Neighbors(planet)

    PrintTable(planet_neighbors)

    local enemy_neighbors = 0

    if planet_neighbors == nil then
        return enemy_neighbors
    end

    for _, neighbor in pairs(planet_neighbors) do
        DebugMessage("%s -- Found Neighbor: %s",tostring(Script), tostring(neighbor))
        if neighbor.Get_Owner() ~= planet.Get_Owner() and neighbor.Get_Owner() ~= Find_Player("NEUTRAL") then
            DebugMessage("%s -- Neighbor is Enemy", tostring(Script))
            enemy_neighbors = enemy_neighbors + 1
        end
    end

    return enemy_neighbors
end

function Find_First_Loss_Planet()

    local player_owned_planets = {}

    for _, planet in pairs(Global_Values.Planets) do

        DebugMessage("%s -- Checking if %s is Owned by Player", tostring(Script), tostring(planet))

        if TestValid(planet) then
            if planet.Get_Owner() == Global_Values.Player then
                DebugMessage("%s -- %s is Owned by the Player", tostring(Script), tostring(planet))
                table.insert(player_owned_planets, planet)
            end
        end
    end

    local highest_enemy_neighbors = 0

    local highest_enemy_neighbors_planet = nil
    
    for _, planet in pairs(player_owned_planets) do
        local enemy_neighbors = Count_Enemy_Neighbors(planet)

        DebugMessage("%s -- Highest Enemy Neighbors %s for Planet: %s, Enemy Neighbors for Planet %s: %s", tostring(Script), tostring(highest_enemy_neighbors), tostring(highest_enemy_neighbors_planet), tostring(planet),tostring(enemy_neighbors))

        if enemy_neighbors > highest_enemy_neighbors then
            highest_enemy_neighbors = enemy_neighbors
            highest_enemy_neighbors_planet = planet
        end
    end

    DebugMessage("%s -- Planet %s has the Highest amount of Enemy Neighbors", tostring(Script), tostring(highest_enemy_neighbors_planet))

    return highest_enemy_neighbors_planet
end

function Default_Event_Function(message)
    if message == OnEnter then
        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Flush(message)
    if message == OnEnter then

        if Global_Values.Plot == nil then
            Set_Next_State("Morale_Level_Init")
        else
            Set_Next_State("Morale_Update")
        end
    end
end

function Lost_Battle(message)
    if message == OnEnter then

        Battle_Info:Increase_Loss_Streak()

        if customModulo(Battle_Info.Loss_Streak, 3) == 0 then
            Set_Next_State("Morale_Lost_Battle_Major")

            return
        end

        Modify_Morale(Get_Morale_Influence())
        
        Set_Next_State("Flush")
    end
end

function Lost_Battle_Major(message)
    if message == OnEnter then

        Modify_Morale(Get_Morale_Influence())

        DebugMessage("%s -- Player On Loss Streak", tostring(Script))

        Set_Next_State("Flush")
    end
end

function Won_Battle(message)
    if message == OnEnter then

        Battle_Info:Increase_Win_Streak()

        local Faction_Modifiers = Modifiers:Get_Modifiers(Global_Values.Player)

        if customModulo(Battle_Info.Win_Streak, Faction_Modifiers.Battle_Win_Streak_Requirement) == 0 then
            Set_Next_State("Morale_Won_Battle_Major")

            return
        end

        Modify_Morale(Get_Morale_Influence())

        Set_Next_State("Flush")
    end
end

function Won_Battle_Major(message)
    if message == OnEnter then

        Modify_Morale(Get_Morale_Influence())

        DebugMessage("%s -- Player On Win Streak", tostring(Script))

        Set_Next_State("Flush")
    end
end

function Great_Schism(message)

    if message ~= OnEnter then

        Set_Next_State("Flush")
        
        return
    end

    Modify_Morale(Get_Morale_Influence(Find_Player("EMPIRE")))

    Set_Next_State("Flush")
end

function Far_Isle_Event(message)
    if message ~= OnEnter then

        Set_Next_State("Flush")
        
        return
    end

    Modify_Morale(Get_Morale_Influence(Find_Player("REBEL")))


    Set_Next_State("Flush")
end


---@class Header
---@field Text string TEXT_ID
---@field Color table Defaults to white. Format {r=255,b=255,g=255}
---@field Var any Only Objects and Player will properly work
---@field Time number Time in seconds till text disappears
---@field Time_Added number 

---@class Body
---@field Text string TEXT_ID
---@field Color table Defaults to white. Format {r=255,b=255,g=255}
---@field Var any Only Objects and Player will properly work
---@field Time number Time in seconds till text disappears
---@field Teletype boolean Is Text typed in over time
---@field Time_Added number
---@field Shown boolean

---@class Footer
---@field Text string TEXT_ID
---@field Color table Defaults to white. Format {r=255,b=255,g=255}
---@field Var any Only Objects and Player will properly work
---@field Time number Time in seconds till text disappears
---@field Time_Added number 

---@class Display_Handler
Display_Handler = {
    ---@type Header[]
    Headers = {

    },
    ---@type Body[]
    Body = {

    },
    ---@type Footer[]
    Footer = {

    },

    COLOR_MAP = {
        red    = {r=255,g=0,b=0},
        blue   = {r=0,g=0,b=255},
        green  = {r=0,g=255,b=0},
        yellow = {r=242,g=214,b=34},
        black  = {r=0,g=0,b=0},
        pink   = {r=248,g=115,b=255},
        purple = {r=77,g=26,b=105},
        orange = {r=219,g=107,b=22},
    }
}


---@param string string
---@param color? table|string
---@param var? any
---@param time? number
function Display_Handler:Add_Header(string, color, var, time)
    if type(string) ~= "string" then
        return
    end

    if type(time) ~= "number" then
        time = -1
    end

    local is_invalid = false

    for _, sHeader in pairs(self.Headers) do
        if sHeader.Text == string then
            if sHeader.Var ~= var and var ~= nil then
                sHeader.Var = var
            end
            is_invalid = true
            break
        end
    end

    if is_invalid then
        return
    end
    

    table.insert(self.Headers, {Text = string, Color = self:Process_Color(color), Var = var, Time = time, Time_Added = GetCurrentTime.Galactic_Time()})
end

---@param old_string string
---@param new_string string
---@param new_color? table|string
---@param new_var? any
function Display_Handler:Update_Header(old_string, new_string, new_color, new_var)
    if type(old_string) ~= "string" then
        return
    end

    if type(new_string) ~= "string" then
        return
    end

    for _, Header in pairs(self.Headers) do
        if Header.Text == old_string then
            Header.Text = new_string
            Header.Color = self:Process_Color(new_color)
            Header.Var = new_var

            Remove_Screen_Text(old_string)
        end
    end
end

---@param string string
---@param color? table|string
---@param var? any
---@param time? number
function Display_Handler:Add_Footer(string, color, var, time)
    if type(string) ~= "string" then
        return
    end

    if type(time) ~= "number" then
        time = -1
    end

    local is_invalid = false

    for _, sHeader in pairs(self.Footer) do
        if sHeader.Text == string then
            is_invalid = true
            break
        end
    end

    if is_invalid then
        return
    end
    

    table.insert(self.Footer, {Text = string, Color = self:Process_Color(color), Var = var, Time = time, Time_Added = GetCurrentTime.Galactic_Time()})
end

---@param string string
---@param time number
---@param teletype? boolean
---@param color? table|string
---@param var? any
function Display_Handler:Add_Body(string, time, teletype, color, var)
    if type(string) ~= "string" then
        return
    end

    if type(time) ~= "number" then
        time = 5
    end

    if teletype ~= true then
        teletype = false
    end

    local is_invalid = false

    for _, sBody in pairs(self.Body) do
        if sBody.Text == string then
            sBody.Shown = false
            sBody.Teletype = true
            is_invalid = true
            break
        end
    end

    if is_invalid then
        return
    end

    table.insert(self.Body, {Text = string, Color = self:Process_Color(color), Var = var, Time = time, Teletype = teletype, Time_Added = GetCurrentTime.Galactic_Time(), Shown = false})
end

---@private
function Display_Handler:Remove_Text()

    DebugMessage("%s -- Clearing Text", tostring(Script))

    for _, Header in pairs(self.Headers) do
        Remove_Screen_Text(Header.Text)
    end

    --Remove_Screen_Text(" ")
    Remove_Screen_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02")
    --Remove_Screen_Text("  ")

    for _, Body in pairs(self.Body) do
        DebugMessage("%s -- Clearing: %s", tostring(Script), tostring(Body.Text))
        Remove_Screen_Text(Body.Text)
    end

    for _, Footer in pairs(self.Footer) do
        Remove_Screen_Text(Footer.Text)
    end
end

function Display_Handler:Process()

    self:Remove_Text()

    local Header_Length = tableLength(self.Headers)

    if Header_Length > 0 then
        for i=1, Header_Length do
            local Header = self.Headers[i]
            if Header ~= nil then
                local Is_Header_Valid = false

                if Header.Time > -1 then
                    if Header.Time_Added + Header.Time >= GetCurrentTime.Galactic_Time() then
                        Is_Header_Valid = true
                    end
                end

                if Header.Time == -1 then
                    Is_Header_Valid = true
                end
                
                if Is_Header_Valid then
                    Show_Screen_Text(Header.Text, Header.Var, -1, Header.Color, false)
                else
                    table.remove(self.Headers, i)
                end
            end
        end
    end

    --Show_Screen_Text(" ", nil, -1)
    Show_Screen_Text("TEXT_STORY_MORALE_DISPLAY_BODY_SEPERATOR_02", nil, -1)
    --Show_Screen_Text("  ", nil, -1)

    local Body_Index = 1

    while Body_Index <= tableLength(self.Body) do
        local Body = self.Body[Body_Index]
        if Body ~= nil then
            DebugMessage("%s -- Adding Body %s", tostring(Script), tostring(Body.Text))

            local Is_Body_Valid = false

            if Body.Time > -1 then
                DebugMessage("%s -- Body is not infinite. Current Time: %s, Time Added: %s, Lasts: %s", tostring(Script), tostring(GetCurrentTime.Galactic_Time()), tostring(Body.Time_Added), tostring(Body.Time))
                if Body.Time_Added + Body.Time > GetCurrentTime.Galactic_Time() then
                    DebugMessage("%s -- Body is Valid", tostring(Script))
                    Is_Body_Valid = true
                end
            end

            if Body.Time == -1 then
                DebugMessage("%s -- Body is Infinite", tostring(Script))
                Is_Body_Valid = true
            end

            if Is_Body_Valid then
                DebugMessage("%s -- Body is Valid", tostring(Script))
                if Body.Shown then
                    Body.Teletype = false
                else
                    Body.Shown = true
                end

                Show_Screen_Text(Body.Text, Body.Var, -1, Body.Color, Body.Teletype)

                Body_Index = Body_Index + 1
            else
                DebugMessage("%s -- Removing Body", tostring(Script))
                Remove_Screen_Text(Body.Text)
                table.remove(self.Body, Body_Index)
            end
        end
    end

    local Footer_Length = tableLength(self.Footer)

    if Footer_Length > 0 then
        for i=1, Footer_Length do
            local Footer = self.Footer[i]
            if Footer ~= nil then
                local Is_Footer_Valid = false

                if Footer.Time > -1 then
                    if Footer.Time_Added + Footer.Time >= GetCurrentTime.Galactic_Time() then
                        Is_Footer_Valid = true
                    end
                end

                if Footer.Time == -1 then
                    Is_Footer_Valid = true
                end
                
                if Is_Footer_Valid then
                    Show_Screen_Text(Footer.Text, Footer.Var, -1, Footer.Color, false)
                else
                    table.remove(self.Footer, i)
                end
            end
        end
    end
end

function Display_Handler:Remove_Header(text)
    if type(text) ~= "string" then
        return
    end

    local Header_Length = tableLength(self.Headers)

    for i=1, Header_Length do
        local Header = self.Headers[i]

        if Header ~= nil then
            if Header.Text == text then
                table.remove(self.Headers,i)
                Remove_Screen_Text(text)
                break
            end
        end
    end
end

function Display_Handler:Remove_Footer(text)
    if type(text) ~= "string" then
        return
    end

    local Header_Length = tableLength(self.Footer)

    for i=1, Header_Length do
        local Header = self.Footer[i]

        if Header ~= nil then
            if Header.Text == text then
                table.remove(self.Footer,i)
                break
            end
        end
    end
end

---@param color table|string
---@return table
function Display_Handler:Process_Color(color)

    local out = {r=255,g=255,b=255}

    if type(color) == "string" then

        local map = self.COLOR_MAP[string.lower(color)]

        if map then
            out = Clone_Table(map)
        end
        
    elseif type(color) == "table" then
        if type(color.r) ~= "number" or color.r < 0 or color.r > 255 then
            return out
        end

        if type(color.g) ~= "number" or color.g < 0 or color.g > 255 then
            return out
        end

        if type(color.b) ~= "number" or color.b < 0 or color.b > 255 then
            return out
        end

        out = Clone_Table(color)
    else
        return out
    end

    return out
end

function Dynamic_Year_Header()
    local cur_year = Global_Values.Starting_Year + (Get_Current_Week() - 1)

    local Base_String = "Year "

    if cur_year == Global_Values.Starting_Year then
        Display_Handler:Add_Header(Base_String .. tostring(cur_year))
    end
    
    if Global_Values.Current_Year ~= cur_year then
        Display_Handler:Update_Header(Base_String .. tostring(Global_Values.Current_Year), Base_String..tostring(cur_year))

        Global_Values.Current_Year = cur_year
    end
end
