---@class DynamicWeightTable
---@field Entries table<string, number>
DynamicWeightTable = {}
DynamicWeightTable.__index = DynamicWeightTable

---@return DynamicWeightTable
function DynamicWeightTable.New()

    local self = setmetatable({}, DynamicWeightTable)

    self.Entries = {}

    return self
end

---@param Key string
---@param Weight number
function DynamicWeightTable:Insert(Key, Weight)
    if type(Key) ~= "string" then
        DebugMessage("%s -- Insert failed: Key must be a string, got %s", tostring(Script), tostring(type(Key)))
        return
    end

    if type(Weight) ~= "number" then
        DebugMessage("%s -- Insert failed: Weight must be a number, got %s", tostring(Script), tostring(type(Weight)))
        return
    end

    DebugMessage("%s -- Inserting key %s with weight %s", tostring(Script), tostring(Key), tostring(Weight))
    self.Entries[Key] = Weight
end

---@param Key string
---@param New_Weight number
function DynamicWeightTable:Update_Weight(Key, New_Weight)
    if type(Key) ~= "string" then
        DebugMessage("%s -- Update_Weight failed: Key must be a string, got %s", tostring(Script), tostring(type(Key)))
        return
    end

    local Entry = self.Entries[Key]

    if Entry == nil then
        DebugMessage("%s -- Update_Weight failed: No existing entry for key %s", tostring(Script), tostring(Key))
        return
    end

    DebugMessage("%s -- Updating weight for key %s from %s to %s", tostring(Script), tostring(Key), tostring(Entry), tostring(New_Weight))
    self.Entries[Key] = New_Weight
end

---@return string|nil
function DynamicWeightTable:Sample()
    local Total_Weight = 0
    local entry_count = 0

    for K, Weight in pairs(self.Entries) do
        Total_Weight = Total_Weight + Weight
        entry_count = entry_count + 1
        DebugMessage("%s -- Entry %s => %s", tostring(Script), tostring(K), tostring(Weight))
    end

    DebugMessage("%s -- Sampling from table with %s entries and total weight %s", tostring(Script), tostring(entry_count), tostring(Total_Weight))

    if Total_Weight <= 0 then
        DebugMessage("%s -- Sample aborted: Total weight is %s", tostring(Script), tostring(Total_Weight))
        return nil
    end

    local Chance = EvenMoreRandom(1, Total_Weight)
    DebugMessage("%s -- Roll result: %s", tostring(Script), tostring(Chance))

    local cumulative = 0

    for key, weight in pairs(self.Entries) do
        if weight > 0 then
            cumulative = cumulative + weight
            DebugMessage("%s -- Cumulative after %s: %s", tostring(Script), tostring(key), tostring(cumulative))

            if Chance <= cumulative then
                DebugMessage("%s -- Sampled key: %s", tostring(Script), tostring(key))
                return key
            end
        else
            DebugMessage("%s -- Skipping key %s with non-positive weight %s", tostring(Script), tostring(key), tostring(weight))
        end
    end

    DebugMessage("%s -- Sample ended without selecting a key", tostring(Script))
    return nil
end

