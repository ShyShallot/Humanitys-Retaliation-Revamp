require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("PGStoryMode")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    StoryModeEvents = {
        HWD_Init = HWD_Handler,
        HWD_DISPLAY = Activate_Display,
        HWD_REQS_MET = Unlock_CSO,
        Flush = Flush,
    }

    HWD = {
        player = nil,
        Display = {
            Plot = nil,
            Body = nil,
            Active = false,
        },
        CSO_Unlocked = false
    }

end

function HWD_Handler(message)
    if message == OnEnter then 

        HWD.player = Find_Player("EMPIRE")
        
        GlobalValue.Set("COVENANT_HEAVY_WEAPONS_NOT_RESEARCHED", 1)
        
        GlobalValue.Set("CSO_LOCKED", 1)

    end

    if message == OnUpdate then
        if HWD.Display.Active then

            local hwd = Find_First_Object("Covenant_Heavy_Weapons")

            local display = HWD.Display.Body

            display.Clear_Dialog_Text()

            status = "Not Researched"

            if hwd ~= nil then
                GlobalValue.Set("COVENANT_HEAVY_WEAPONS_NOT_RESEARCHED", 0)

                status = "Researched"
            else
                GlobalValue.Set("COVENANT_HEAVY_WEAPONS_NOT_RESEARCHED", 1)
            end

            display.Add_Dialog_Text("Heavy Weapons Development Status: " .. status)

            display.Add_Dialog_Text("CSO-class Supercarrier Unlocked: " .. Capital_First_Letter(tostring(HWD.CSO_Unlocked)))
        end
    end
end

function Activate_Display(message) 

    if message == OnEnter then
        HWD.Display.Plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Covenant_Tech.xml")
        HWD.Display.Body = HWD.Display.Plot.Get_Event("HWD_DISPLAY")
        HWD.Display.Active = true

        Set_Next_State("Flush")
    end
end

function Unlock_CSO(message) 
    if message == OnEnter then
        HWD.CSO_Unlocked = true

        GlobalValue.Set("CSO_UNLOCKED", 1)

        Set_Next_State("Flush")
    end
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("HWD_Init")
    end
end