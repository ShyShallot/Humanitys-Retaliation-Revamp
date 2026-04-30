require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("PGStoryMode")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 1

    shield_tech_built = false

    player = nil

    trigged_event = false

    StoryModeEvents = {
        UNSC_Enters_Tech_4 = Shield_System,
        Galactic_Start = Init_Shield_Tech,
    }

end

function Init_Shield_Tech(message)
    if message == OnEnter then
        GlobalValue.Set("Is_Shield_Tech_Not_Available", 1)
        GlobalValue.Set("Is_Shield_Tech_Researched", 0)
        GlobalValue.Set("Is_Shield_Tech_Not_Researched", 1)

        player = Find_Player("Rebel")

    end
end

function Shield_System(message)

    if message == OnUpdate then

        local Installation_05 = FindPlanet("Installation_05")
        
        if TestValid(Installation_05) then

            DebugMessage("%s -- Installation 05 is Valid", tostring(Script))

            if Installation_05.Get_Owner() == player then

                Trigger_Event()

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

function Trigger_Event()
    if trigged_event then
        return
    end

    trigged_event = true

    Story_Event("Installation_Already_Captured")
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
