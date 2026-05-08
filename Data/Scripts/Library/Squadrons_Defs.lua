---@class Squadron_Info
---@field Units string[]
---@field Offsets table[]

Squadrons_Library = {
    ["UNSC_PARIS_SQUADRON"] = "Squadron_Definitions/Paris_Squad"
}

---@param Unit_Name string
---@return Squadron_Info|nil
function Squadrons_Library:Get_Squad(Unit_Name)
    if type(Unit_Name) ~= "string" then
        return nil
    end

    ---@type string
    local File = self[Unit_Name]

    if File == nil then
        return nil
    end

    ---@type Squadron_Info
    local Entry = require(File)

    if Entry == nil then
        return nil
    end

    local Units = tableLength(Entry.Units)

    local Offsets = tableLength(Entry.Offsets)

    if Units ~= Offsets then
        return nil
    end

    return Clone_Table(Entry)
end

---@param Base_Unit GameObject
---@param Offset number[]
---@return Position
function Squadrons_Library:Calculate_Offset(Base_Unit, Offset)
    if Base_Unit == nil then
        return Create_Position(0,0,0)
    end

    if Base_Unit.Get_Position == nil then
        return Create_Position(0,0,0)
    end

    if type(Offset) ~= "table" then
        return Create_Position(0,0,0)
    end

    if type(Offset[1]) ~= "number" then
        return Create_Position(0,0,0)
    end

    if type(Offset[2]) ~= "number" then
        return Create_Position(0,0,0)
    end

    local Base_Position = Base_Unit.Get_Position()

    local X,Y,Z = Base_Position.Get_XYZ()

    local Offset_X = Offset[1]

    local Offset_Y = Offset[2]

    local New_X = X + Offset_X

    local New_Y = Y + Offset_Y

    local Offset_Position = Create_Position(New_X, New_Y, Z)

    return Offset_Position
end

---@param Base_Unit GameObject
---@param Squad_Entry Squadron_Info
function Squadrons_Library:Spawn_Squadron(Base_Unit, Squad_Entry)

    if not TestValid(Base_Unit) then
        return
    end

    if Base_Unit.Get_Owner == nil then
        return
    end

    if not TestValid(Base_Unit.Get_Owner()) then
        return
    end

    if Squad_Entry == nil then
        return
    end

    if Squad_Entry.Units == nil then
        return
    end

    local Units = Squad_Entry.Units

    local Offests = Squad_Entry.Offsets

    local Total = tableLength(Units)

    for i=1, Total do
        local Unit_Name = Units[i]
        local Offset = Offests[i]
        
        local Position = self:Calculate_Offset(Base_Unit, Offset)

        local Unit_Type = Find_Object_Type(Unit_Name)

        if Unit_Type ~= nil then
            Spawn_Unit(Unit_Type, Position, Base_Unit.Get_Owner())
        end
    end

    Base_Unit.Despawn()
end

return Squadrons_Library