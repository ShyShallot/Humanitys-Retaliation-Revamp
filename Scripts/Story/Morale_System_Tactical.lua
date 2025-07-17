require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("PGStoryMode")

function Definitions()
    ServiceRate = 0.5
	
    StoryModeEvents = {
        Morale_Tactical_Battle_Start = Morale_Tactical_Init,
        Morale_Player_Kill = Killed_Unit,
        Morale_Player_Loss = Unit_Lost,
        Morale_Tactical_Player_Lost = Morale_Tactical_End,
        Morale_Tactical_Player_Won = Morale_Tactical_End,
    }

    player = nil

    enemy = nil

    player_kills = 0

    player_losses = 0
end

function Morale_Tactical_Init(message)
    if message == OnEnter then

        Sleep(1)

        DebugMessage("%s -- Is Now Active", tostring(Script))

        GlobalValue.Set("Morale_Kill_Ratio", 0)

        player = Find_Human_Player()

        enemy = Tactical_Find_Enemy(player)

        local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Morale_System_Tactical.xml")
        
        local Win_Event = plot.Get_Event("Morale_Tactical_Player_Won")

        local Loss_Event = plot.Get_Event("Morale_Tactical_Player_Lost")

        DebugMessage("%s -- Player: %s, Enemy: %s", tostring(Script), tostring(player), tostring(enemy))

        Win_Event.Set_Event_Parameter(0,player.Get_Faction_Name())

        Loss_Event.Set_Event_Parameter(0, enemy.Get_Faction_Name())

    end
end

function Killed_Unit(message) then
    if message == OnEnter then
        player_kills = player_kills + 1
    end
end

function Unit_Lost(message) then
    if message == OnEnter then
        player_losses = player_losses + 1
    end
end

function Morale_Tactical_End(message) then
    if message == OnEnter then

        if player_losses == 0 then
            GlobalValue.Set("Morale_Kill_Ratio", player_kills)

            ScriptExit()

            return
        end

        local kill_ratio = player_kills / player_losses

        GlobalValue.Set("Morale_Kill_Ratio", kill_ratio)

        ScriptExit()
    end
end