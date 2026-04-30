Custom_Global_Var = {}

---@alias SupportedVar string|number|userdata

---@param Name string @ Name of the entry
---@param vars SupportedVar|SupportedVar[]
function Custom_Global_Var:Set(Name, vars)

    if type(Name) ~= "string" then
        return false
    end

    if type(vars) ~= "table" then
        vars = {vars}
    end

    local value = ""

    local first = true

    for i=1, tableLength(vars) do
        local var = vars[i]
        if type(var) ~= "table" then
            local var_type = type(var)
            if not first then
                value = value .. ";"
            end
            first = false

            if var_type ~= "table" or var_type ~= "userdata" or var_type ~= "function" then
                value = value .. tostring(var)
            end
        end
    end

    GlobalValue.Set(Name, value)
end

---@param Name string @ Name of the entry
---@param reset boolean @ Resets the GlobalValue to nil after reading
---@return SupportedVar[]
function Custom_Global_Var:Get(Name, reset)
    if type(Name) ~= "string" then
        return nil
    end

    local Global_Var = GlobalValue.Get(Name)

    if Global_Var == nil then
        return nil
    end

    local Vars = split(Global_Var, ";")

    for i=1, tableLength(Vars) do
        local var = Vars[i]
        if type(tonumber(var)) == "number" then
            Vars[i] = tonumber(var)
        end
    end

    if reset then
        GlobalValue.Set(Name, nil)
    end

    return unpack(Vars)
end