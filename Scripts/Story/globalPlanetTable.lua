---@class PlanetTable
Planet_Table = {
    ---@type table
    Planets = {
        REACH = {
            Tech_Difficulty = 1, -- 1 Easiest, 1 Hardest
            Tech_Availability = 1,
        },
        AKTIS_IV = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        ALERIA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        ALLUVION = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        ARCADIA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        CHI_CETI_IV = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        ERIDANUS_2 = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        MADRIGAL = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        CHARYBDIS_IX = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        MERIDIAN = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        GAO = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        HARVEST = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        EARTH = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        FALAKNUMA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        HARMONY = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        NEW_CARTHAGE = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        NEW_JERUSALEM = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        TANTALUS = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        TERRA_NOVA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        MARS = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        MIRIDEM = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        NETHEROP = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        FAR_ISLE = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        THRESHOLD = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        YONHE = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        KAMCHATKA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        TARAM = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        TROVE = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        INSTALLATION_01 = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        NEFOLUZO = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        THUA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        GLYKE = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        KARAVA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        VICTORS_TRUTH = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        BALAHO = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        TE = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        DOISAC = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        SANGHELIOS = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        RHANELO = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        SONG_OF_VICTORY = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        EAYN = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        BHEDALON = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        CODISFOLD = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        FELDOKRA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        ULGETHON = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        PALAMOK = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        VEN_III = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        KOSTRODA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        KHAELMOTHKA = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
        TVAO = {
            Tech_Difficulty = 1,
            Tech_Availability = 1,
        },
    }
}

---@param planet string|PlanetObject|nil
---@return nil|table
function Planet_Table:Get_Entry(planet)

    if planet == nil then
        return nil
    end

    if type(planet) ~= "string" then
        if TestValid(planet) then
            local Planet_Name = planet.Get_Type().Get_Name()

            return self:Get_Entry_From_String(Planet_Name)
        end
    else
        return self:Get_Entry_From_String(planet)
    end
end

---@private
---@param planet_name string|nil
---@return nil|table
function Planet_Table:Get_Entry_From_String(planet_name)

    if type(planet_name) ~= "string" then
        return nil
    end

    if tableLength(self.Planets) == 0 then
        return nil
    end

    return self.Planets[string.upper(planet_name)] -- will return nil or the table
end

---@return nil|table
function Planet_Table:Return_All_Keys()
    if tableLength(self.Planets) == 0 then
        return nil
    end

    local keys = {}

    for key, _ in pairs(self.Planets) do
        table.insert(keys, key)
    end

    return keys
end

return Planet_Table