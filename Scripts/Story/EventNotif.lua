---@class Game_Scoring_Event_Manager

Game_Scoring_Event_Manager = {
    Events = {
        Galactic = {
            ["Unit_Destroyed"] = {
                Subscribers = {}
            },
            ["Production_Started"] = {
                Subscribers = {}
            },
            ["Production_Canceled"] = {
                Subscribers = {}
            },
            ["Production_End"] = {
                Subscribers = {}
            },
            ["Starbase_Level_Change"] = {
                Subscribers = {}
            },
            ["Planet_Ownership_Change"] = {
                Subscribers = {}
            },
            ["Hero_Neutralized"] = {
                Subscribers = {}
            }
        }
    }
}

--Get_Object_ID

function Game_Scoring_Event_Manager:Serialize_Object(obj)
    if obj == nil then
        return ""
    end

    local Object_Name = ""

    if obj.Get_Type == nil then -- assume object is type
        Object_Name = obj.Get_Name() .. "_"
    end

    

    local Serialized_String = ""
end

function Game_Scoring_Event_Manager:Subscribe(Event_Name, Function)
    if type(Event_Name) ~= "string" then
        return
    end

    if self.Events.Galactic[Event_Name] == nil then
        return
    end

    if type(Function) ~= "function" then
        return
    end

    table.insert(self.Events.Galactic[Event_Name].Subscribers, Function)
end

function Game_Scoring_Event_Manager:Process_Events()
    for Event_Name, Info in pairs(self.Events.Galactic) do
        if GlobalValue.Get(Event_Name) ~= "" or GlobalValue.Get(Event_Name) ~= nil then
            for _, Subscriber in pairs(Info.Subscribers) do
                if type(Subscriber) == "function" then
                    pcall(Subscriber, unpack(GlobalValue.Get(Event_Name).Parameters))
                end
            end

            GlobalValue.Set(Event_Name, "")
        end
    end
end

function Game_Scoring_Event_Manager:Trigger_Event(Event_Name, Parameters)
    if type(Event_Name) ~= "string" then
        return
    end

    if self.Events.Galactic[Event_Name] == nil then
        return
    end

    if type(Parameters) ~= "table" then
        return
    end

    local Event = {
        Name = "Event_Name",
        Parameters = Parameters
    }

    GlobalValue.Set(Event_Name, Event)
end