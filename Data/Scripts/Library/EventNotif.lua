---@class Game_Scoring_Event_Manager

---@alias Galactic_Events_Names "Unit_Destroyed" | "Production_Started" | "Production_Canceled" | "Production_End" | "Starbase_Level_Change" | "Planet_Ownership_Change" | "Hero_Neutralized" | "Planet_Attacked"

Game_Scoring_Event_Manager = {
    Events = {
        Galactic = {
            ["Unit_Destroyed"] = {
                Subscribers = {},
            },
            ["Production_Started"] = {
                Subscribers = {},
            },
            ["Production_Canceled"] = {
                Subscribers = {},
            },
            ["Production_End"] = {
                Subscribers = {},
            },
            ["Starbase_Level_Change"] = {
                Subscribers = {},
            },
            ["Planet_Ownership_Change"] = {
                Subscribers = {},
            },
            ["Hero_Neutralized"] = {
                Subscribers = {},
            },
            ["Planet_Attacked"] = {
                Subscribers = {},
            }
        }
    }
}

function Game_Scoring_Event_Manager:Process_Galactic_Events()
    if Get_Game_Mode() == "Galactic" then
        for Event_Name, Info in pairs(self.Events.Galactic) do
            local Did_Event_Trigger = GlobalValue.Get(Event_Name)

            if Did_Event_Trigger == "true" then
                GlobalValue.Set(Event_Name, nil)
                
                local Data = {Custom_Global_Var:Get(Event_Name .. "_DATA", true)}

                for _, Subscriber in pairs(Info.Subscribers) do
                    if type(Subscriber) == "function" then
                        pcall(Subscriber, unpack(Data))
                    end
                end
            end
        end
    end
end

---@param Event_Name Galactic_Events_Names
---@param func function
---@param filter_friendly? boolean If true only triggers on friendly events, if not triggers on any
function Game_Scoring_Event_Manager:Subscribe_To_Galactic_Event(Event_Name, func, filter_friendly)

    if type(Event_Name) ~= "string" then
        return
    end

    if type(func) ~= "function" then
        return
    end

    if self.Events.Galactic[Event_Name] == nil then
        return
    end

    if filter_friendly ~= true then
        filter_friendly = false
    end

    local Sub = {func = func, Only_Friendly = filter_friendly}

    table.insert(self.Events.Galactic[Event_Name].Subscribers, Sub)
end

function Game_Scoring_Event_Manager:Trigger(Event_Name, args)
    GlobalValue.Set(Event_Name, "true")

    Custom_Global_Var:Set(Event_Name .. "_DATA", args)
end