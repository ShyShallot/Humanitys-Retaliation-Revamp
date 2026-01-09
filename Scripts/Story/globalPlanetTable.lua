---@class PlanetTable
Planet_Table = {
    ---@type table
    Planets = {
        REACH = {
            Tech_Difficulty = 5, -- 1 Easiest, 5 Hardest
            Tech_Availability = 5,
        },
        AKTIS_IV = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        ALERIA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        ALLUVION = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        ARCADIA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        CHI_CETI_IV = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        ERIDANUS_2 = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        MADRIGAL = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        CHARYBDIS_IX = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        MERIDIAN = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        GAO = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        HARVEST = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        EARTH = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        FALAKNUMA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        HARMONY = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        NEW_CARTHAGE = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        NEW_JERUSALEM = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        TANTALUS = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        TERRA_NOVA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        MARS = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        MIRIDEM = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        NETHEROP = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        FAR_ISLE = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        THRESHOLD = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        YONHE = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        KAMCHATKA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        TARAM = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        TROVE = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        INSTALLATION_05 = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        NEFOLUZO = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        THUA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        GLYKE = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        KARAVA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        VICTORS_TRUTH = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        BALAHO = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        TE = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        DOISAC = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        SANGHELIOS = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        RHANELO = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        SONG_OF_VICTORY = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        EAYN = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        BHEDALON = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        CODISFOLD = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        FELDOKRA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        ULGETHON = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        PALAMOK = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        VEN_III = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        KOSTRODA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        KHAELMOTHKA = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
        },
        TVAO = {
            Tech_Difficulty = 5,
            Tech_Availability = 5,
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