require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PGStoryMode")
require("globalPlanetTable")

function Definitions()

    ServiceRate = 0.75

    StoryModeEvents = 
    {
        Hero_Rescue_Init = Hero_Rescue_Init,
        Hero_Rescue_Update = Hero_Rescue_Update,
        Rescue_Major_Hero_Mission = Hero_Rescue_Finish,
        Flush = Flush,
    }


    Status_Table = {
        Factions = {
            ["REBEL"] = {
                UNSC_POA = {Current_Status = false, Equation = "Is_POA_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Pillar of Autumn", Respawn_Time = 0, Last_Death = nil,},
                UNSC_IAC = {Current_Status = false, Equation = "Is_IAC_Alive", Object = nil, Owner = nil, deaths = 0, Name = "In Amber Clad", Respawn_Time = 0, Last_Death = nil,},
                UNSC_ROMAN_BLUE = {Current_Status = false, Equation = "Is_Roman_Blue_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Fleet Admiral Hood", Respawn_Time = 0, Last_Death = nil,},
                UNSC_SOF = {Current_Status = false, Equation = "Is_SOF_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Spirit Of Fire", Respawn_Time = 0, Last_Death = nil,},
            },
            ["EMPIRE"] = {
                COVN_PIOUS = {Current_Status = false, Equation = "Is_Pious_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Nizat 'Kvarosee", Respawn_Time = 3, Last_Death = nil,},
                COVN_JUL = {Current_Status = false, Equation = "Is_Jul_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Jul 'Mdamaee", Respawn_Time = 3, Last_Death = nil,},
                COVN_ARDO = {Current_Status = false, Equation = "Is_Ardo_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Ardo 'Moretumee", Respawn_Time = 3, Last_Death = nil,},
                COVN_MACCABEUS = {Current_Status = false, Equation = "Is_Maccabeus_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Maccabeus", Respawn_Time = 3, Last_Death = nil,},
            },
        },
        Player = nil,
        Max_Deaths = 5
    }

    rescue_plot = nil

    rescue_display_event = nil

    mission_event = nil

    Difficulty = ""

    enemy = nil

    Rescue_Cooldown = {
        Active = false,
        Activated_On = nil,
        Length = 1
    }

    ---@type PlayerWrapper
    Player = nil

    Mission_Info = {
        Active = false,
        Setup = false,
        ---@type GameObjectType|nil
        Hero = nil,
        ---@type PlanetObject|nil
        Prison = nil
    }

    function Mission_Info:Setup_Mission(Hero, Prison)

        DebugMessage("%s -- Hero: %s, Prison: %s", tostring(Script), tostring(Hero), tostring(Prison))

        if Hero.Get_Name == nil then
            DebugMessage("%s -- Hero Type is not valid", tostring(Script))
            return false
        end

        if not TestValid(Prison) then
            DebugMessage("%s -- No Valid Prison Planet", tostring(Script))
            return false
        end

        if self.Active then
            DebugMessage("%s -- Current Mission is Active", tostring(Script))
            return false
        end

        self.Hero = Hero
        self.Prison = Prison
        self.Active = true
        self.Setup = false

        DebugMessage("%s -- Mission Setup as Successful", tostring(Script))

        return true
    end
end



function Hero_Rescue_Init(message)

    if message ~= OnEnter then return end

    Player = Find_Human_Player()

    if Player == nil then
        ScriptError("%s -- ERROR COULD NOT FIND PLAYER", tostring(Script))
        return
    end

    DebugMessage("%s -- Main Player: %s", tostring(Script), tostring(Player))

    for faction, entries in pairs(Status_Table.Factions) do
        DebugMessage("%s -- Init Faction: %s", tostring(Script), tostring(faction))

        if faction == string.upper(Player.Get_Faction_Name()) then
            DebugMessage("%s -- Faction %s Matches Player: %s", tostring(Script), tostring(faction), tostring(Player))
            Status_Table.Player = entries
        end

        for Hero, Status in pairs(entries) do
            DebugMessage("%s -- Init Hero: %s", tostring(Script), tostring(Hero))
            if EvaluatePerception(Status.Equation, Player) == 1 then
                Status.Current_Status = true

                local Hero_Object = Find_First_Object(Hero)

                if TestValid(Hero_Object) then
                    Status.Object = Hero_Object
                    Status.Owner = Hero_Object.Get_Owner()
                end

                DebugMessage("%s -- Hero %s, Is Alive, Object: %s, Owner: %s", tostring(Script), tostring(Hero), tostring(Status.Object), tostring(Status.Owner))
            end
        end
    end


    rescue_plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Rescue_Hero.xml")

    if rescue_plot == nil then
        return
    end

    rescue_display_event = rescue_plot.Get_Event("Rescue_Major_Hero_Dialog")

    if rescue_display_event == nil then
        return
    end

    mission_event = rescue_plot.Get_Event("Rescue_Major_Hero_Mission")

    if mission_event == nil then
        return
    end

    DebugMessage("%s -- Found Display Event: %s, Found Mission Event: %s", tostring(Script), tostring(rescue_display_event), tostring(mission_event))

    if StringCompare(Player.Get_Faction_Name(), "Empire") then
        enemy = Find_Player("Rebel")
    else
        enemy = Find_Player("Empire")
    end

    DebugMessage("%s -- Enemy Player: %s", tostring(Script), tostring(enemy))

    if TestValid(enemy) then
        Difficulty = enemy.Get_Difficulty()
    end

    DebugMessage("%s -- Difficulty: %s", tostring(Script), tostring(Difficulty))
    
    Set_Next_State("Hero_Rescue_Update")
end

function Hero_Rescue_Update(message)

    if message ~= OnUpdate then return end

    Check_Hero_Status()

    if Rescue_Cooldown.Active then
        DebugMessage("%s -- Cooldown Active", tostring(Script))
        if Get_Current_Week() <= (Rescue_Cooldown.Activated_On + Rescue_Cooldown.Length) then
            DebugMessage("%s -- Cooldown Started: %s, Cooldown Length: %s, Current Time: %s", tostring(Script), tostring(Rescue_Cooldown.Activated_On), tostring(Rescue_Cooldown.Length), tostring(Get_Current_Week()))
            return
        else
            Rescue_Cooldown.Active = false
        end
    end

    Process_Hero_Queue()

    if Mission_Info.Active == false then 
        return 

    end

    if not TestValid(Mission_Info.Prison) and Mission_Info.Hero.Get_Name == nil then
        return
    end

    DebugMessage("%s -- Mission Active", tostring(Script))

    if not Mission_Info.Setup then

        DebugMessage("%s -- Setting Up Mission", tostring(Script))

        mission_event.Set_Event_Parameter(0, Mission_Info.Prison)
        mission_event.Set_Reward_Parameter(0, Mission_Info.Hero)
        Mission_Info.Setup = true

        Story_Event("Rescue_Major_Hero_Activate")

        rescue_display_event.Clear_Dialog_Text()

        if Difficulty == "Hard" then
            rescue_display_event.Add_Dialog_Text("TEXT_STORY_HERO_RESCUE_WARNING")

            rescue_display_event.Add_Dialog_Text(" ")
        end

        rescue_display_event.Add_Dialog_Text("TEXT_STORY_HERO_RESCUE_LOCATION", Planet_Table:Get_Planet_String(Mission_Info.Prison))

        rescue_display_event.Add_Dialog_Text(" ")

        rescue_display_event.Add_Dialog_Text("TEXT_STORY_HERO_RESCUE_CAPTURED_HERO", tostring(Status_Table.Player[Mission_Info.Hero.Get_Name()].Name))
    end
end

function Hero_Rescue_Finish(message) 
    if message ~= OnEnter then return end

    DebugMessage("%s -- Mission Done, Resetting", tostring(Script))

    Mission_Info.Active = false
    Mission_Info.Setup = false
    Mission_Info.Hero = nil
    Mission_Info.Prison = nil

    DebugMessage("%s -- Activating Cooldown, Start Time: %s, Length: %s, Predicted End Time: %s", tostring(Script), tostring(Get_Current_Week()), tostring(Rescue_Cooldown.Length), tostring(Rescue_Cooldown.Length + Get_Current_Week()))
    Rescue_Cooldown.Active = true
    Rescue_Cooldown.Activated_On = Get_Current_Week()
    
    Story_Event("Trigger_Hero_Rescue")
    
    Set_Next_State("Flush")
end

function Process_Hero_Queue()

    if not TestValid(Player) then
        return
    end

    if Status_Table.Factions == nil then
        return
    end

    local Current_Time = Get_Current_Week()

    for Faction, Entries in pairs(Status_Table.Factions) do

        DebugMessage("%s -- Processing Queue for Faction: %s", tostring(Script), tostring(Faction))
        
        local Instant_Respawn = true
        if Faction == Player.Get_Faction_Name() then
            Instant_Respawn = false
        end

        DebugMessage("%s -- Instant_Respawn? %s", tostring(Script), tostring(Instant_Respawn))

        for Hero, Info in pairs(Entries) do
            DebugMessage("%s -- Hero: %s, Last Death: %s, Respawn_Time: %s, Current Time: %s", tostring(Script), tostring(Hero), tostring(Info.Last_Death), tostring(Info.Respawn_Time), tostring(Current_Time))
            if Info.Last_Death ~= nil and Info.Current_Status == false then
                if Instant_Respawn then
                    if (Info.Respawn_Time + Info.Last_Death) <= Current_Time then
                        local hero_type = Find_Object_Type(Hero)
                    
                        if hero_type ~= nil and TestValid(Info.Owner) then
                            local spawn_planet = Find_Random_AI_Planet(Info.Owner)
                        
                            DebugMessage("%s -- Spawn Planet: %s", tostring(Script), tostring(spawn_planet))
                        
                            if spawn_planet ~= nil then
                                DebugMessage("%s -- Spawning Hero: %s, At Planet: %s", tostring(Script), tostring(hero_type), tostring(spawn_planet))
                                Spawn_Unit(hero_type, spawn_planet, Info.Owner)
                            end
                        end
                    end
                else
                    if not Info.Current_Status and ((Info.Respawn_Time + Info.Last_Death) <= Current_Time) then
                        DebugMessage("%s -- Attempting Mission Setup for Hero: %s", tostring(Script), tostring(Hero))

                        local Valid_Respawn = true

                        if Difficulty == "Hard" and Info.deaths >= Status_Table.Max_Deaths then
                            Valid_Respawn = false
                        end

                        if Valid_Respawn then
                            Mission_Info:Setup_Mission(Find_Object_Type(Hero), Find_Suitable_Prison())
                        end
                    end
                end
            end
        end
    end
end

---@param hero string
---@param owner PlayerWrapper
function Hero_Lost(hero, owner)

    DebugMessage("%s -- Running Hero_Lost for Hero: %s", tostring(Script), tostring(hero))

    if not TestValid(owner) then 
        return 
    end

    if type(hero) ~= "string" then
        return
    end

    local Faction_Name = owner.Get_Faction_Name()

    local Faction_Entry = Status_Table.Factions[Faction_Name]

    if Faction_Entry == nil or tableLength(Faction_Entry) < 1 then
        return
    end

    local Hero_Entry = Faction_Entry[hero]

    if Hero_Entry == nil then
        return
    end

    local DoD = Get_Current_Week()

    if type(DoD) ~= "number" then
        return
    end

    Hero_Entry.Last_Death = DoD

    DebugMessage("%s -- %s Date of Death: %s", tostring(Script), tostring(hero), tostring(DoD))

    if owner ~= Player then
        Story_Event("Enemy_Hero_Killed")
    else
        Story_Event("Friendly_Hero_Lost")
    end
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Hero_Rescue_Update")
    end
end 

function Check_Hero_Status()
    for Faction, Entries in pairs(Status_Table.Factions) do

        DebugMessage("%s -- Checking Hero Status for Faction: %s", tostring(Script), tostring(Faction))

        for Hero, Status in pairs(Entries) do
            local Is_Dead = (EvaluatePerception(Status.Equation, Player) == 0)

            DebugMessage("%s -- Is Hero %s Dead? %s, Last Known Status: %s", tostring(Script), tostring(Hero), tostring(Is_Dead), tostring(Status.Current_Status))

            if Status.Current_Status and Is_Dead then

                DebugMessage("%s -- Hero is Dead", tostring(Script))

                Status.Current_Status = false
                Status.deaths = Status.deaths + 1

                DebugMessage("%s -- Death Count: %s", tostring(Script), tostring(Status.deaths))

                Hero_Lost(Hero, Status.Owner)
            end

            if not Is_Dead then
                DebugMessage("%s -- Hero is not Dead", tostring(Script))
                Status.Current_Status = true

                if not TestValid(Status.Object) then

                    local Hero_Object = Find_First_Object(Hero)
                    if TestValid(Hero_Object) then
                        Status.Object = Hero_Object
                        Status.Owner = Hero_Object.Get_Owner()
                    end
                    DebugMessage("%s -- Could not find Object, Assigning new: %s", tostring(Script), tostring(Hero_Object))
                end
            end
        end
    end
end

function Find_Suitable_Prison()
    local Planets = Planet_Table:Return_All_Keys()

    local Neutral = Find_Player("Neutral")

    local prison = nil

    local Player_Owned_Planets = {}

    local Non_Player_Owned_Planets = {}

    local Possible_Prisons = {}

    for _, planet_name in pairs(Planets) do

        local planet = FindPlanet(planet_name)

        if TestValid(planet) then
            if planet.Get_Owner() == Player then
                table.insert(Player_Owned_Planets, planet)
            else
                if planet.Get_Owner() ~= Neutral then
                    table.insert(Non_Player_Owned_Planets, planet)
                end
            end
        end
    end

    for _, planet in pairs(Non_Player_Owned_Planets) do
        for _, player_planet in pairs(Player_Owned_Planets) do
            local planet_path = Find_Path(Player, planet, player_planet)

            if planet_path ~= nil then
                local path_length = tableLength(planet_path)

                if path_length == 2 or path_length == 3 then
                    table.insert(Possible_Prisons, planet)
                end
            end
        end
    end

    prison = Random_From_List(Possible_Prisons)

    return prison
end

function Find_Random_AI_Planet(owner)
    if not TestValid(owner) then return end

    local Planets = Planet_Table:Return_All_Keys()

    local Owned_Planets = {}

    for _, planet_name in pairs(Planets) do
        
        local planet = FindPlanet(planet_name)

        if TestValid(planet) then
            if planet.Get_Owner() == owner then
                table.insert(Owned_Planets, planet)
            end
        end
    end
    
    return Random_From_List(Owned_Planets)
end