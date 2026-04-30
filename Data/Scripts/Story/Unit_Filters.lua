---@class Unit_Filters
local Unit_Filters = {

    Units = nil,

    Player = nil,

    Cache = {
        Special_Case = {},
        Category = {},
    },

    Active_Filter = nil,

    Structure_Super_Filter = {"Structure", "Super"},
    Capitals_Filter = {"Capital"},
    Frigate_Corvette_Filter = {"Frigate", "Corvette", "Vehicle"},
    Fighter_Filter = {"Fighter" , "Infantry"},
}

function Unit_Filters:Init(plot_file)

    DebugMessage("%s -- Init Unit Filters", tostring(Script))

    local player = Find_Human_Player()

    if not TestValid(player) then
        DebugMessage("%s -- NO VALID PLAYER ASSIGNED", tostring(Script))
        return
    end

    if plot_file == nil then
        DebugMessage("%s -- No Plot File", tostring(Script))
        return
    end

    self.Player = player

    self.Units = require("globalUnitTable")

    if self.Units == nil then
        DebugMessage("%s -- GLOBAL UNITS TABLE RETURNED NIL", tostring(Script))
        return
    end

    DebugMessage("%s -- Init Unit Filter Cache", tostring(Script))

    for unit_name, info in pairs(self.Units) do
        
        if info.Is_Locked == nil then
            info.Is_Locked = false
            info.Should_Lock = false
        end
        

        if info.Global_Value_Check ~= nil then
            if self.Cache.Special_Case[info.Global_Value_Check] == nil then
                self.Cache.Special_Case[info.Global_Value_Check] = {}
            end

            DebugMessage("%s -- Added %s to Special Case Cache: %s", tostring(Script), tostring(unit_name), tostring(info.Global_Value_Check))

            table.insert(self.Cache.Special_Case[info.Global_Value_Check], unit_name)
        end

        if self.Cache.Category[info.Category] == nil then
            self.Cache.Category[info.Category] = {}
        end

        DebugMessage("%s -- Unit Name: %s, Category: %s, Value Check: %s", tostring(Script), tostring(unit_name), tostring(info.Category), tostring(info.Global_Value_Check))
        
        table.insert(self.Cache.Category[info.Category], unit_name)
    end

    local plot = Get_Story_Plot(plot_file)
        
    local Structures_Super_Filter_Event = plot.Get_Event("Structures_Super_Filter")
    Structures_Super_Filter_Event.Set_Reward_Parameter(1, self.Player.Get_Faction_Name())

    local Capitals_Filter_Event = plot.Get_Event("Capitals_Filter")
    Capitals_Filter_Event.Set_Reward_Parameter(1, self.Player.Get_Faction_Name())

    local Frigate_Corvette_Filter_Event = plot.Get_Event("Frigate_Corvette_Filter")
    Frigate_Corvette_Filter_Event.Set_Reward_Parameter(1, self.Player.Get_Faction_Name())

    local Fighter_Filter_Event = plot.Get_Event("Fighter_Filter")
    Fighter_Filter_Event.Set_Reward_Parameter(1, self.Player.Get_Faction_Name())
    
end

function Unit_Filters:Update()

    self:Check_Cache()

    self:Check_Filter()
end

function Unit_Filters:Get_Entry(unit_name)
    return self.Units[unit_name]
end

function Unit_Filters:Has_Special_Case(unit_name)
    local entry = self:Get_Entry(unit_name)

    if entry ~= nil then
        if entry.Global_Value_Check ~= nil then
            return true
        else
            return false
        end
    end

    return false
end

function Unit_Filters:Check_Cache()

    DebugMessage("%s -- Checking Filter Cache", tostring(Script))

    for Special_Case, units in pairs(self.Cache.Special_Case) do

        DebugMessage("%s -- Special Case: %s, Unit Table: %s", tostring(Script), tostring(Special_Case), tostring(units))

        local Special_Case_Status = GlobalValue.Get(Special_Case)

        DebugMessage("%s -- Special Case Status: %s", tostring(Script), tostring(Special_Case_Status))

        if type(Special_Case_Status) == "number" then

            local lock = false

            if Special_Case_Status == 1 then
                lock = true
            end

            for _, unit_name in pairs(units) do
                DebugMessage("%s -- Locking/Unlock Unit %s: %s", tostring(Script), tostring(unit_name), tostring(lock))
                if self.Units[unit_name] ~= nil then
                    self.Units[unit_name].Should_Lock = lock
                end
            end

        end
    end
end

function Unit_Filters:Check_Filter()

    if self.Units == nil then
        return
    end

    DebugMessage("%s -- Current Filter: %s", tostring(Script), tostring(self.Active_Filter))

    for unit_name, info in pairs(self.Units) do
        if self:Is_Unit_In_Filter(unit_name) then
            local lock = false
        
            if info.Should_Lock then
                lock = true
            end

            self:Lock_Unit(unit_name, lock)
        else
            self:Lock_Unit(unit_name, true)
        end
    end
end

---@param unit_name string
---@return boolean
function Unit_Filters:Is_Unit_Locked(unit_name)

    local Unit_Entry = self:Get_Entry(unit_name)

    if Unit_Entry ~= nil then
        return Unit_Entry.Is_Locked
    end

    return false
end

---@param unit_name string
---@param lock boolean
function Unit_Filters:Lock_Unit(unit_name, lock)

    if unit_name == nil then
        return
    end

    if lock == nil then
        return
    end

    local Unit_Entry = self:Get_Entry(unit_name)

    if Unit_Entry ~= nil then

        if Unit_Entry.Is_Locked ~= lock then
            Unit_Entry.Is_Locked = lock

            local Unit_Type = Find_Object_Type(unit_name)

            DebugMessage("%s -- Unit Name: %s, Unit Type: %s", tostring(Script), tostring(unit_name), tostring(Unit_Type))

            if Unit_Type ~= nil then 
                if lock then
                    
                    self.Player.Lock_Tech(Unit_Type)
                else
                    self.Player.Unlock_Tech(Unit_Type)
                end
            end
        end
    end
end

function Unit_Filters:Should_Lock_Unit(unit_name, lock)
    if unit_name == nil then
        return
    end

    if lock == nil then
        return
    end

    local Unit_Entry = self:Get_Entry(unit_name)

    if Unit_Entry ~= nil then

        if Unit_Entry.Should_Lock ~= lock then
            Unit_Entry.Should_Lock = lock
        end
    end
end

function Unit_Filters:Reset_Filters()

    DebugMessage("%s -- Resetting Filters", tostring(Script))

    self.Active_Filter = nil

    for unit_name, info in pairs(self.Units) do

        DebugMessage("%s -- Resetting %s", tostring(Script), tostring(unit_name))

        local lock = false
        
        if info.Should_Lock then
            lock = true
        end

        self:Lock_Unit(unit_name, lock)
    end
end

---@param filter table
function Unit_Filters:Set_Filter(filter)

    if filter == nil then
        return
    end

    DebugMessage("%s -- New Filter: %s, Current Filter: %s", tostring(Script), tostring(filter), tostring(self.Active_Filter))

    if self.Active_Filter == filter then
        DebugMessage("%s -- Filter Already Active", tostring(Script))
        self:Reset_Filters()
        return
    end

    self.Active_Filter = filter
end
        

---@param unit_name string
---@return boolean
function Unit_Filters:Is_Unit_In_Filter(unit_name)
    --DebugMessage("Category: %s, Filter: %s", tostring(category), tostring(filter))

    if self.Active_Filter == nil or type(self.Active_Filter) ~= "table" then
        return true
    end

    local Unit_Entry = self:Get_Entry(unit_name)

    if Unit_Entry == nil then
        return true
    end

    local is_in_filter = false

    for _, split_filter in pairs(self.Active_Filter) do
        if StringCompare(split_filter,Unit_Entry.Category) then
            is_in_filter = true
        end
    end

    return is_in_filter
end

---@return table
function Unit_Filters:Get_Active_Filter()
    return self.Active_Filter
end

return Unit_Filters