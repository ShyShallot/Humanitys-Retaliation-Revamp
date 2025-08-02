require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("PGStoryMode")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.5

    shield_tech_built = false

    player = nil

    StoryModeEvents = {
        Rebel_Tech_4 = Shield_System,
        Galactic_Start = Init_Shield_Tech
    }

    installation_05 = nil

end

function Init_Shield_Tech(message)
    if message == OnEnter then
        GlobalValue.Set("Is_Shield_Tech_Not_Available", 1)
        GlobalValue.Set("Is_Shield_Tech_Researched", 0)
        GlobalValue.Set("Is_Shield_Tech_Not_Researched", 1)

        player = Find_Player("Rebel")

        installation_05 = FindPlanet("Installation_05")

        DebugMessage("%s -- Found Player: %s, Found Installation 05: %s", tostring(Script), tostring(player), tostring(installation_05))
    end
end

function Shield_System(message)

    if message == OnUpdate then
        
        if TestValid(installation_05) then

            DebugMessage("%s -- Installation 05 is Valid", tostring(Script))

            if installation_05.Get_Owner() == player then

                DebugMessage("%s -- Installation 05 is owned by the Player", tostring(Script))

                GlobalValue.Set("Is_Shield_Tech_Not_Available", 0)

                local Shield_Tech = Find_First_Object("UNSC_Tech_Shield")

                DebugMessage("%s -- Shield Tech Object: %s", tostring(Script), tostring(Shield_Tech))

                if TestValid(Shield_Tech) then
                    GlobalValue.Set("Is_Shield_Tech_Not_Available", 1)
                    GlobalValue.Set("Is_Shield_Tech_Researched", 1)
                    GlobalValue.Set("Is_Shield_Tech_Not_Researched", 0)

                    Upgrade_Carriers() 
                else
                    GlobalValue.Set("Is_Shield_Tech_Not_Researched", 1)
                    GlobalValue.Set("Is_Shield_Tech_Researched", 0)
                end
            else
                GlobalValue.Set("Is_Shield_Tech_Not_Available", 1)
                GlobalValue.Set("Is_Shield_Tech_Researched", 0)
                GlobalValue.Set("Is_Shield_Tech_Not_Researched", 1)
            end
        end
        
    end
end

function Upgrade_Carriers() 
    poseidon_carriers = Find_All_Objects_Of_Type("UNSC_POSEIDON")
    musashi_carriers = Find_All_Objects_Of_Type("UNSC_MUSASHI")
    
    for i, poseidon in pairs(poseidon_carriers) do
        planet = poseidon.Get_Planet_Location()
        poseidon.Despawn()
        Spawn_Unit(Find_Object_Type("UNSC_POSEIDON_2"),planet,player)
    end
    for i, musashi in pairs(musashi_carriers) do
        planet = poseidon.Get_Planet_Location()
        musashi.Despawn()
        Spawn_Unit(Find_Object_Type("UNSC_MUSASHI_2"),planet,player)
    end
end