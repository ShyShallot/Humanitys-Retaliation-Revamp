require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PGStoryMode")
require("PlanetNameTable")

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
                UNSC_POA = {Current_Status = false, Equation = "Is_POA_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Pillar of Autumn"},
                UNSC_IAC = {Current_Status = false, Equation = "Is_IAC_Alive", Object = nil, Owner = nil, deaths = 0, Name = "In Amber Clad"},
                UNSC_ROMAN_BLUE = {Current_Status = false, Equation = "Is_Roman_Blue_Alive", Object = nil, Owner = nil, deaths = 0, "Fleet Admiral Hood"},
                UNSC_SOF = {Current_Status = false, Equation = "Is_SOF_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Spirit Of Fire"},
            },
            ["EMPIRE"] = {
                COVN_PIOUS = {Current_Status = false, Equation = "Is_Pious_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Nizat 'Kvarosee"},
                COVN_JUL = {Current_Status = false, Equation = "Is_Jul_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Jul 'Mdamaee"},
                COVN_ARDO = {Current_Status = false, Equation = "Is_Ardo_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Ardo 'Moretumee"},
                COVN_MACCABEUS = {Current_Status = false, Equation = "Is_Maccabeus_Alive", Object = nil, Owner = nil, deaths = 0, Name = "Maccabeus"},
            },
        },
        Player = nil,
        AI_Entries = {},
        Max_Deaths = 5
    }

    Mission = {
        Hero = nil,
        Prison = nil,
        Active = false,
        Setup = false
    }
    
    Rescue_Queue = {}

    rescue_plot = nil

    rescue_display_event = nil

    mission_event = nil

    Difficulty = ""

    enemy = nil

    respawn_time = 0
    

end

function Hero_Rescue_Init(message)

    if message ~= OnEnter then return end

    player = Find_Human_Player()

    for faction, entries in pairs(Status_Table.Factions) do
        if faction == string.upper(player.Get_Faction_Name()) then
            Status_Table.Player = entries
        else
            table.insert(Status_Table.AI_Entries, faction)
        end

        for Hero, Status in pairs(entries) do
            if EvaluatePerception(Status.Equation, player) == 1 then
                Status.Current_Status = true

                local Hero_Object = Find_First_Object(Hero)

                if TestValid(Hero_Object) then
                    Status.Object = Hero_Object
                    Status.Owner = Hero_Object.Get_Owner()
                end
            end
        end
    end


    rescue_plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Rescue_Hero.xml")

    rescue_display_event = rescue_plot.Get_Event("Rescue_Major_Hero_Dialog")

    mission_event = rescue_plot.Get_Event("Rescue_Major_Hero_Mission")

    if StringCompare(player.Get_Faction_Name(), "Empire") then
        enemy = Find_Player("Rebel")
    else
        enemy = Find_Player("Empire")
    end

    DebugMessage("%s -- Enemy Player: %s", tostring(Script), tostring(enemy))

    if TestValid(enemy) then
        Difficulty = enemy.Get_Difficulty()
    end
    
    Set_Next_State("Hero_Rescue_Update")
end

function Hero_Rescue_Update(message)

    if message ~= OnUpdate then return end

    Check_Hero_Status()

    Process_Hero_Queue()

    if Mission.Active == false then return end

    if not TestValid(Mission.Prison) and not TestValid(Mission.Hero) then return end

    if not Mission.Setup then
        mission_event.Set_Event_Parameter(0, Mission.Prison)
        mission_event.Set_Reward_Parameter(0, Mission.Hero)
        Mission.Setup = true
        Story_Event("Rescue_Major_Hero_Activate")

        rescue_display_event.Clear_Dialog_Text()

        if Difficulty == "Hard" then
            rescue_display_event.Add_Dialog_Text("TEXT_STORY_HERO_RESCUE_WARNING")

            rescue_display_event.Add_Dialog_Text(" ")
        end

        rescue_display_event.Add_Dialog_Text("TEXT_STORY_HERO_RESCUE_LOCATION", tostring(Mission.Prison.Get_Type().Get_Name()))

        rescue_display_event.Add_Dialog_Text(" ")

        rescue_display_event.Add_Dialog_Text("TEXT_STORY_HERO_RESCUE_CAPTURED_HERO", tostring(Status_Table.Player[Mission.Hero].Name))
    end
end

function Hero_Rescue_Finish(message) 
    if message ~= OnEnter then return end

    Mission.Active = false
    Mission.Hero = nil
    Mission.Prison = nil
    Mission.Setup = false

    Set_Next_State("Flush")
end

function Process_Hero_Queue()
    
    if table.getn(Rescue_Queue) == 0 then return end

    for _, hero_info in ipairs(Rescue_Queue) do 

        local valid_respawn = true

        if Difficulty == "Hard" and hero_info.deaths >= Status_Table.Max_Deaths then
            valid_respawn = false
        end

        local hero_owner = hero_info.Owner

        if TestValid(hero_owner) and valid_respawn then
            if hero_owner ~= player then
                if Get_Current_Week() >= hero_info.Death_Date + respawn_time then
                    local hero_type = Find_Object_Type(hero_info.Hero)

                    if hero_type ~= nil then
                        local spawn_planet = Find_Random_AI_Planet(hero_owner)

                        if spawn_planet ~= nil then
                            Spawn_Unit(hero_type, spawn_planet, hero_owner)
                        end
                    end
                end
            else 
                if Mission.Active == false then
                    Mission = {
                        Hero = hero_info.Hero,
                        Prison = Find_Suitable_Prison(),
                        Active = true,
                        Setup = false
                    }
                end
            end
        end
    end
end

function Hero_Lost(hero, owner)

    if not TestValid(owner) then 
        return 
    end

    if Is_Hero_In_Queue(hero) then
        return
    end

    local queue_struc = {
        Hero = hero,
        Owner = owner,
        Death_Date = Get_Current_Week()
    }

    table.insert(Rescue_Queue, queue_struc)
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Hero_Rescue_Update")
    end
end 

function Check_Hero_Status()
    for Faction, Entries in pairs(Status_Table.Factions) do

        for Hero, Status in pairs(Entries) do
            local Is_Dead = (EvaluatePerception(Status.Equation, player) == 0)

            if Status.Current_Status and Is_Dead then
                Status.Current_Status = false
                Status.deaths = Status.deaths + 1

                Hero_Lost(Hero, Status.Owner)
            end

            if not Is_Dead then
                Status.Current_Status = true

                if not TestValid(Status.Object) then
                    local Hero_Object = Find_First_Object(Hero)

                    if TestValid(Hero_Object) then
                        Status.Object = Hero_Object
                        Status.Owner = Hero_Object.Get_Owner()
                    end
                end
            end
        end
    end
end

function Is_Hero_In_Queue(hero)

    if table.getn(Rescue_Queue) == 0 then
        return false
    end

    for _, hero_entry in pairs(Rescue_Queue) do
        if hero == hero_entry.Hero then
            return true
        end
    end

    return false
end

function Find_Suitable_Prison()
    local Planets = FindPlanet.Get_All_Planets()

    local Neutral = Find_Player("Neutral")

    local highest_power = 0

    local prison = nil

    for _, planet in pairs(Planets) do
        if planet.Get_Owner() ~= player and planet.Get_Owner() ~= Neutral then
            local power = EvaluatePerception("Planet_Force_Strength", planet.Get_Owner(), planet)

            if power > highest_power then
                prison = planet
                highest_power = power
            end
        end
    end

    return prison
end

function Find_Random_AI_Planet(owner)
    if not TestValid(owner) then return end

    local Planets = FindPlanet.Get_All_Planets()

    local Owned_Planets = {}

    for _, planet in pairs(Planets) do 
        if planet.Get_Owner() == owner then
            table.insert(Owned_Planets, planet)
        end
    end
    
    return Random_From_List(Owned_Planets)
end