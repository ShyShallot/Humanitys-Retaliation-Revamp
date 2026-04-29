---@class Persistant_Damage_Object
---@field Health_Percentage number
---@field Object GameObject

Persistent_Damage_Manager = {
    ---@type Persistant_Damage_Object[]
    Objects = {},

    Repair_Rate = 10, -- X% every year

    Last_Updated = 1,

    Categories = {"Capital"},

    Shipyards = { -- Perceptual Equation strings
        ["Capital"] = {
            "Planet_Has_Heavy_UNSC_Shipyard",
            "Planet_Has_Heavy_COVN_Shipyard" -- NEED TO ADD
        }
    },

    Category_Mask = nil,
}

function Persistent_Damage_Manager:Init()
    self.Category_Mask = self:Build_Category_Mask()

    DebugMessage("%s -- Category Mask: %s", tostring(Script), tostring(self.Category_Mask))
end

function Persistent_Damage_Manager:Build_Category_Mask()
    local Base = ""

    local Num_Of_Categories = tableLength(self.Categories)

    if Num_Of_Categories > 1 then
        for i=1, Num_Of_Categories - 1 do
            Base = Base .. self.Categories[i] .. " | "
        end

        Base = Base .. self.Categories[Num_Of_Categories]
    else
        Base = self.Categories[1]
    end

    return Base
end

function Persistent_Damage_Manager:Add_Object(Object)
    if not TestValid(Object) then
        return
    end

    local Valid_Category = false

    for _, Category in pairs(self.Categories) do
        DebugMessage("%s -- Add_Tactical_Object: Checking if Object is category '%s'", tostring(Script), tostring(Category))
        if Object.Is_Category(Category) then
            DebugMessage("%s -- Add_Tactical_Object: Object matches category '%s'", tostring(Script), tostring(Category))
            Valid_Category = true
            break
        end
    end

    if not Valid_Category then
        DebugMessage("%s -- Add_Tactical_Object: Object does not match any valid categories, returning false", tostring(Script))
        return
    end

    local Object_ID = Object.Get_Object_ID()

    DebugMessage("%s -- Object %s, Id: %s", tostring(Script), tostring(Object), tostring(Object_ID))

    self.Objects[Object_ID] = {
        Health_Percentage = 1, -- goes from value 0 to 1
        Object = Object
    }
end

---@param Object GameObject
---@returns boolean Status of whether or not it was added
function Persistent_Damage_Manager:Add_Tactical_Object(Object)
    DebugMessage("%s -- Add_Tactical_Object called with Object: %s", tostring(Script), tostring(Object))
    
    if Object == nil then
        DebugMessage("%s -- Add_Tactical_Object: Object is nil, returning false", tostring(Script))
        return false
    end

    local Valid_Category = false

    for _, Category in pairs(self.Categories) do
        DebugMessage("%s -- Add_Tactical_Object: Checking if Object is category '%s'", tostring(Script), tostring(Category))
        if Object.Is_Category(Category) then
            DebugMessage("%s -- Add_Tactical_Object: Object matches category '%s'", tostring(Script), tostring(Category))
            Valid_Category = true
            break
        end
    end

    if not Valid_Category then
        DebugMessage("%s -- Add_Tactical_Object: Object does not match any valid categories, returning false", tostring(Script))
        return false
    end

    local Object_ID = Object.Get_Parent_Mode_Object_ID()
    DebugMessage("%s -- Add_Tactical_Object: Retrieved Object_ID: %s", tostring(Script), tostring(Object_ID))

    if type(Object_ID) ~= "number" then
        DebugMessage("%s -- Add_Tactical_Object: Object_ID is not a number (type: %s), returning false", tostring(Script), tostring(type(Object_ID)))
        return false
    end

    local Persisted_Health = GlobalValue.Get(tostring(Object_ID))

    local Hull_Value = Object.Get_Hull()
    DebugMessage("%s -- Add_Tactical_Object: Retrieved Hull value: %s for Object_ID: %s", tostring(Script), tostring(Hull_Value), tostring(Object_ID))

    if type(Persisted_Health) == "number" then
        if Persisted_Health > 0 and Persisted_Health < 1 then
            Hull_Value = Persisted_Health

            Object.Take_Damage()
        end
    end
    
    self.Objects[Object_ID] = {
        Health_Percentage = Hull_Value,
        Object = Object
    }
    DebugMessage("%s -- Add_Tactical_Object: Stored tactical object with ID %s in Objects table", tostring(Script), tostring(Object_ID))

    GlobalValue.Set(tostring(Object_ID), Hull_Value)
    DebugMessage("%s -- Add_Tactical_Object: Set GlobalValue for Object_ID %s to %s", tostring(Script), tostring(Object_ID), tostring(Hull_Value))

    return true
end

function Persistent_Damage_Manager:Galactic_Update()
    --[[for ID, Entry in pairs(self.Objects) do
        DebugMessage("%s -- ID %s, Object: %s, Health: %s", tostring(Script), tostring(ID), tostring(Entry.Object), tostring(Entry.Health_Percentage))
    end
    ]]--

    if GlobalValue.Get("Mode_Ended") == 1 then
        GlobalValue.Set("Mode_Ended", 0)

        for ID, Entry in pairs(self.Objects) do
            DebugMessage("%s -- ID %s, Object: %s, Health: %s", tostring(Script), tostring(ID), tostring(Entry.Object), tostring(Entry.Health_Percentage))

            local New_Health = GlobalValue.Get(tostring(ID))

            DebugMessage("%s -- New Health for ID %s: %s", tostring(Script), tostring(ID), tostring(New_Health))
        end
    end
end

function Persistent_Damage_Manager:Tactical_Update()
    for ID, Entry in pairs(self.Objects) do
        DebugMessage("%s -- ID %s, Object: %s, Health: %s", tostring(Script), tostring(ID), tostring(Entry.Object), tostring(Entry.Health_Percentage))

        if TestValid(Entry.Object) then
            self.Objects[ID].Health_Percentage = Entry.Object.Get_Hull()

            GlobalValue.Set(tostring(ID), Entry.Object.Get_Hull())
        else
            GlobalValue.Set(tostring(ID),0)
        end
    end
end

return Persistent_Damage_Manager