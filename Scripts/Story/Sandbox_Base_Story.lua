require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("globalPlanetTable")
require("globalUnitTable")
require("GlobalVarProcess")
require("EventNotif")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.3

    StoryModeEvents = {
        Init_GC = Init_GC,
        Structures_Super_Filter = Set_Structures_Super_Filter,
        Capitals_Filter = Set_Capitals_Filter,
        Frigate_Corvette_Filter = Set_Frigate_Corvette_Filter,
        Fighter_Filter = Set_Fighter_Filter,
        Flush = Flush,
        Update = Update,
    }

    ---@type Factions[]
    Player_List = {
        "REBEL",
        "EMPIRE",
        "SWORDS",
        "TERRORISTS"
    }

    ---@type Starting_Units_Handler
    Starting_Units = require("Starting_Units")

    Tech_Stealing = require("Tech_Stealing")

    ---@type Unit_Filters
    Unit_Filters = require("Unit_Filters")
    
    Great_Schism = require("Great_Schism")

    Far_Isle_Campaign = require("Far_Isle_Campaign")

    Random_Planet_Starter = require("Random_Planet_Starter")

    Utilize_Random_Start = false

    ---@type PlayerWrapper
    Player = nil

    ---@type Factions
    Player_Name = nil

    ---@type StoryPlot
    Plot = nil

    ---@type PlanetName[]
    Init_Restrict_List = {"VICTORS_TRUTH", "KARAVA", "TROVE", "NETHEROP"}

    Custom_Timed_Events = {
        ["SANDBOX_HALO_EVOLVED_UNSC | SANDBOX_HALO_EVOLVED_INNIES | SANDBOX_HALO_EVOLVED_COVENANT | SANDBOX_HALO_EVOLVED_SWORDS"] = {
            ["REBEL"] = {
                [0] = {
                    UNSC_MOVIE_CE
                },
                [35] = {
                    UNSC_Income_Reward,
                }
            },
            ["All"] = {
                [0] = {
                    Initial_Planet_Restrict,
                },
                [35] = {
                    Planet_Unrestrict,
                }
            }
        }
    }

    ---@type string
    Galactic_Map = ""

    Executed_Timed_Events = {}

    Time_Event_Entry = nil
end

function Init_GC(messsage)

    DebugMessage("%s -- Starting GC Init", tostring(Script))

    if messsage ~= OnEnter then
        return
    end

    Player = Find_Human_Player()

    Player_Name = string.upper(Player.Get_Faction_Name())

    Sleep(3)

    ---@type string
    Galactic_Map = GlobalValue.Get("Galactic_Map")

    DebugMessage("%s -- Galactic Map: %s", tostring(Script), tostring(Galactic_Map))

    Figure_Out_TEE(Galactic_Map)
    
    local Is_Single_Start = StringContains(Galactic_Map, "Sandbox_Halo_Random_Single")

    local Is_Double_Start = StringContains(Galactic_Map, "Sandbox_Halo_Random_Double")

    if Is_Single_Start then
        Utilize_Random_Start = true
    end

    if Is_Double_Start then
        Utilize_Random_Start = true
        Random_Planet_Starter:Set_Starting_Planet_Count(2)
    end

    if Utilize_Random_Start then
        Random_Planet_Starter:Start()
    end

    if Utilize_Random_Start and Random_Planet_Starter:Is_Finished() then
        Starting_Units:Start(Galactic_Map)
    elseif not Utilize_Random_Start then
        Starting_Units:Start(Galactic_Map)
    end

    if Starting_Units:Is_Finished() then
        Unit_Filters:Init("HaloFiles\\Campaigns\\StoryMissions\\Common_Events.xml")

        Tech_Stealing:Init("HaloFiles\\Campaigns\\StoryMissions\\Common_Events.xml")

        Great_Schism:Init()

        Far_Isle_Campaign:Init()
    end

    Story_Event("Spawning_Done")

    Plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Common_Events.xml")

    local Victory_Event = Plot.Get_Event("Galactic_Conquest_Victory")

    Victory_Event.Set_Reward_Parameter(0, Player.Get_Faction_Name())

    local Loss_Event = Plot.Get_Event("Galactic_Conquest_Loss")

    local Loss_Player = Find_Player("EMPIRE")

    if string.upper(Player.Get_Faction_Name()) == "EMPIRE" then
        Loss_Player = Find_Player("REBEL")
    end

    Loss_Event.Set_Reward_Parameter(0, Loss_Player.Get_Faction_Name())

    DebugMessage("%s -- Display Handler Table: %s", tostring(Script), tostring(Display_Handler))

    --Shield_Research_Test()

    --Game_Scoring_Event_Manager:Subscribe_To_Galactic_Event("Production_Started", Production_Started)

    Set_Next_State("Flush")
end

function Update(messsage)
    if messsage ~= OnUpdate then return end

    --Game_Scoring_Event_Manager:Process_Galactic_Events()

    Unit_Filters:Update()

    Tech_Stealing:Update()

    Great_Schism:Check()

    Far_Isle_Campaign:Check()

    Execute_Custom_Events()

    --Experiment_01()

    --DebugMessage("%s -- Time Since Last Attacker: %s, Time Since Left Defender: %s", tostring(Script), tostring(EvaluatePerception("Time_Since_Last_Attacker",Player)), tostring()

    --Test_Victory_Condition()

    --Should_GC_End()
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Update")
    end
end

function Fart_Ass()
    Game_Message("I JUST SHIT MY PANTS")
end

function Figure_Out_TEE(GC_Map)
    DebugMessage("%s -- Figure_Out_TEE called with GC_Map: %s", tostring(Script), tostring(GC_Map))
    for Maps, Entry in pairs(Custom_Timed_Events) do
        local Map_List = split(Maps, " | ")

        for _, Map in pairs(Map_List) do
            DebugMessage("%s -- Checking map: %s", tostring(Script), tostring(Map))
            if string.upper(Map) == string.upper(GC_Map) then
                DebugMessage("%s -- Found matching map: %s, setting Time_Event_Entry", tostring(Script), tostring(Map))
                Time_Event_Entry = Entry
                return
            end
        end
    end
end

function Execute_Custom_Events()

    if Time_Event_Entry == nil then
        return
    end

    local Year = Get_Current_Week()
    DebugMessage("%s -- Execute_Custom_Events called, current year: %s", tostring(Script), tostring(Year))
    
    for Faction, Events in pairs(Time_Event_Entry) do
        DebugMessage("%s -- Processing faction: %s", tostring(Script), tostring(Faction))
        if Faction == "All" or string.upper(Faction) == Player_Name then
            DebugMessage("%s -- Faction %s matches player %s", tostring(Script), tostring(Faction), tostring(Player_Name))
            for Event_Year, Functions in pairs(Events) do
                DebugMessage("%s -- Checking event year: %s", tostring(Script), tostring(Event_Year))
                if Event_Year <= Year then
                    DebugMessage("%s -- Event year %s <= current year %s, checking if executed", tostring(Script), tostring(Event_Year), tostring(Year))

                    Executed_Timed_Events[Faction] = Executed_Timed_Events[Faction] or {}

                    if not Executed_Timed_Events[Faction][Event_Year] then
                        DebugMessage("%s -- Executing functions for event year %s", tostring(Script), tostring(Event_Year))
                        for _, Function in pairs(Functions) do
                            DebugMessage("%s -- Executing function: %s", tostring(Script), tostring(Function))
                            local success, err = pcall(Function)

                            if not success then
                                DebugMessage("%s -- Custom Event Error: %s", tostring(Script), tostring(err))
                            else
                                DebugMessage("%s -- Function executed successfully", tostring(Script))
                            end
                        end

                        Executed_Timed_Events[Faction][Event_Year] = true
                        DebugMessage("%s -- Marked event year %s as executed for faction %s", tostring(Script), tostring(Event_Year), tostring(Faction))
                    else
                        DebugMessage("%s -- Event year %s already executed for faction %s", tostring(Script), tostring(Event_Year), tostring(Faction))
                    end
                end
            end
        end
    end
end

function Experiment_01()
    local Time_Since_Defense = EvaluatePerception("Time_Since_Last_Defender",Player)

    if Time_Since_Defense > 10 then
        Time_Since_Defense = 0
    end

    DebugMessage("%s -- Time Since Last Defense: %s", tostring(Script), tostring(Time_Since_Defense))

    if Time_Since_Defense > 0 then
        local All_Planet_Names = Planet_Table:Return_All_Keys()

        for _, Name in pairs(All_Planet_Names) do
            local Planet = FindPlanet(Name)

            if TestValid(Planet) then
                if Planet.Get_Owner() == Player then
                    local Space_Conflict = EvaluatePerception("Time_Since_Planet_Conflict", Player, Planet)

                    DebugMessage("%s -- Planet %s time since conflict: %s", tostring(Script), tostring(Planet), tostring(Space_Conflict))

                    if abs(Space_Conflict - Time_Since_Defense) < 0.2 then
                        for _, Faction_Name in pairs(Player_List) do
                            if Faction_Name ~= Player_Name then
                                local Faction = Find_Player(Faction_Name)

                                if TestValid(Faction) then
                                    local Time_Since_Attack = EvaluatePerception("Time_Since_Last_Attacker", Faction)

                                    if Time_Since_Attack > 10 then
                                        Time_Since_Attack = 0
                                    end

                                    if Time_Since_Attack > 0 then
                                        if abs(Time_Since_Defense - Time_Since_Attack) <= 0.1 then
                                            DebugMessage("%s -- Player %s was Attacked by: %s", tostring(Script), tostring(Player), tostring(Faction))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Test_Victory_Condition()

    local Neutral = Find_Player("Neutral")

    if GetCurrentTime.Galactic_Time() >= 6 then
        for _, Planet_Name in pairs(Planet_Table:Return_All_Keys()) do
            local Planet = FindPlanet(Planet_Name)

            if TestValid(Planet) then
                if Planet.Get_Owner() == Player then
                    Planet.Change_Owner(Neutral)
                end
            end
        end
    end
end

function Should_GC_End()
   local Player_Planets = 0

    if GetCurrentTime.Galactic_Time() <= 45 then
        return
    end

    for _, Planet_Name in pairs(Planet_Table:Return_All_Keys()) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            if Planet.Get_Owner() == Player then
                Player_Planets = Player_Planets + 1
            else
                break
            end
        end
    end

    DebugMessage("%s -- Num of Player Controlled Planets: %s", tostring(Script), tostring(Player_Planets))

    if Player_Planets == table.getn(Planet_Table:Return_All_Keys()) then
        Story_Event("Trigger_GC_Victory")
    end

    if Player_Planets == 0 then
        Story_Event("Trigger_GC_Loss")
    end
end

function Shield_Research_Test()
    if string.upper(Player.Get_Faction_Name()) ~= "REBEL" then
        return
    end

    local Planet = FindPlanet("INSTALLATION_05")

    if TestValid(Planet) then
        Planet.Change_Owner(Player)

        Spawn_Unit(Find_Object_Type("UNSC_RESEARCH_FACILITY"), FindPlanet("EARTH"), Player)
    end
end

function UNSC_MOVIE_CE()
    Play_Bink_Movie("UNSC_Start_Space")
end

function UNSC_Income_Reward()

    local Player_Credits = Player.Get_Credits()

    Player_Credits = Player_Credits * 2

    Player.Give_Money(Player_Credits)
end

function Initial_Planet_Restrict()

    for _, Planet_Name in pairs(Init_Restrict_List) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            Restrict_Planet(Planet)
        end
    end
end

function Planet_Unrestrict()

    for _, Planet_Name in pairs(Init_Restrict_List) do

        local Planet = FindPlanet(Planet_Name)
            
        if TestValid(Planet) then
            Unrestrict_Planet(Planet)
        end
            
    end

    Post_Unrestrict = true
end

---@param Planet PlanetObject|nil
function Restrict_Planet(Planet)

    if not TestValid(Planet) or Planet.Get_Type == nil then
        return
    end

    local restrict = Plot.Get_Event("Restrict_Planet")

    local Planet_Name = Planet.Get_Type().Get_Name()

    if restrict == nil then
        return
    end

    if Planet_Name == nil then
        return
    end

    restrict.Set_Reward_Parameter(0, Planet_Name)

    Story_Event("Restrict_Planet")
end

---@param Planet PlanetObject|nil
function Unrestrict_Planet(Planet)

    if not TestValid(Planet) or Planet.Get_Type == nil then
        return
    end

    local unrestrict = Plot.Get_Event("Unrestrict_Planet")

    local Planet_Name = Planet.Get_Type().Get_Name()

    if unrestrict == nil then
        return
    end

    if Planet_Name == nil then
        return
    end

    unrestrict.Set_Reward_Parameter(0, Planet_Name)

    Story_Event("Unrestrict_Planet")
end

function Set_Structures_Super_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Structures_Super_Filter: Setting structures super filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Structure_Super_Filter)
    Set_Next_State("Flush")
end

function Set_Capitals_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Capitals_Filter: Setting capitals filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Capitals_Filter)
    Set_Next_State("Flush")
end

function Set_Frigate_Corvette_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Frigate_Corvette_Filter: Setting frigate/corvette filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Frigate_Corvette_Filter)
    Set_Next_State("Flush")
end

function Set_Fighter_Filter(message)
    if message ~= OnEnter then return end
    DebugMessage("%s -- Set_Fighter_Filter: Setting fighter filter", tostring(Script))
    Unit_Filters:Set_Filter(Unit_Filters.Fighter_Filter)
    Set_Next_State("Flush")
end
