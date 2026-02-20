---@class EventNotif
EventNotif = {
    init = false,

    Events = {}
}

function EventNotif:Init()
    self.init = true

    _G.EventNotif = self
    DebugMessage("%s -- EventNotif:Init() called, table: %s", tostring(Script), tostring(self))
end

function EventNotif:Call(event_name, args)

    if _G.EventNotif == nil then
        return
    end

    if type(event_name) ~= "string" then
        return
    end

    local instance = _G.EventNotif

    DebugMessage("%s -- is EventNotif Init: %s", tostring(Script), tostring(instance.init))

    if not instance.init then
        DebugMessage("%s -- Tried Calling Event but System is not setup", tostring(Script))
        return
    end

    local Subscribers = instance.Events[event_name]

    if Subscribers == nil or table.getn(Subscribers) < 1 then
        return
    end

    if args == nil or type(args) ~= "table" then
        args = {nil, nil}
    end
 
    for _, Subscriber in pairs(Subscribers) do
        if type(Subscriber) == "function" then
            pcall(Subscriber, event_name, unpack(args))
        end
    end
end

function EventNotif:Subscribe(event_name, function_call)

    if _G.EventNotif == nil then
        return
    end

    local instance = _G.EventNotif

    if type(event_name) ~= "string" then
        return
    end

    if type(function_call) ~= "function" then
        return
    end

    if not instance.init then
        DebugMessage("%s -- Tried Calling Event but System is not setup", tostring(Script))
        return
    end

    if instance.Events[event_name] == nil then
        instance.Events[event_name] = {}
    end
    
    table.insert(instance.Events[event_name], function_call)

end

return EventNotif