---@class Tech_Stealing
Tech_Stealing = {
    ---@type table
    Stealing_Unit = {
        ---@type GameObject
        Object = nil,
        ---@type table
        Unit_Name = {
            ---@type table
            TERRORISTS = {
                Find = "FART_TOO_DEE_POO",
                Lock = "INNIE_MY_ASSHOLE"
            }
        }
    },

    ---@type StoryPlot|nil
    Plot = nil,

    ---@type StoryEvent|nil
    Display = nil,

    ---@type PlayerWrapper|nil
    Player = nil,

    ---@class Theft_Table
    Theft_Table = {
        ---@type table
        Base_Respawn_Time_Per_Planet_Difficulty = {2,3,4,5,6},
        Chance_Table = {
            Difficulty = {1, 0.75, 0.5, 0.35, 0.25},
            Availability = {0.15, 0.3, 0.5, 0.8, 1}
        },
        Valid_Theft_Targets = {
            TERRORISTS = {"REBEL"}
        }
    },

    Tech_Table = {
        TERRORISTS = {
            { -- This is for Tech 1, so Tech 1 --> 2, we need to steal all of these ships to get to Tech 2, when all are stolen we advance from 1 --> 2
                TERROR_HALCYON = false,
                TERROR_HALBERD = false,
                TERROR_CHARON = false,
                TERROR_MUSASHI = false,
                TERROR_STALWART = false,
            }, 
            {
                TERROR_MARATHON = false,
				TERROR_EPOCH = false,
            }, -- Same as above but from Tech 2 to 3
            {}, -- 3 --> 4
            {} -- 4 --> 5
        }
    },

    ---@class Tech_String_Table
    String_Table = {
        STATUS = "TEXT_STORY_TECH_THEFT_CURRENT_STATUS",
        LAST_THEFT = "TEXT_STORY_TECH_THEFT_LATEST",
        COOLDOWN_STATUS = "TEXT_STORY_TECH_THEFT_COOLDOWN",
        VALID_TARGETS = "TEXT_STORY_TECH_THEFT_TARGETS",
        REBEL = "TEXT_FACTION_REBELS",
        EMPIRE = "TEXT_FACTION_EMPIRE",
        SWORDS = "TEXT_FACTION_SWORDS",
        TERRORISTS = "TEXT_FACTION_INSURRECTIONISTS",
    },

    Theft_Cooldown = {
        Active = false,
        End_On = nil,
    },

    Last_Theft_Info = {
        Verdict = false,
        Tech_Stolen = nil,
    },

    Initialized = false
}


---@param Player PlayerWrapper|nil
---@return nil|
function Tech_Stealing.Tech_Table:Get_Player_Entry(Player)

    DebugMessage("%s -- Tech_Stealing Tech Table Finding Player Entry for: %s", tostring(Script), tostring(Player))
    
    if not TestValid(Player) then
        return nil
    end

    local Player_Entry = self[string.upper(Player.Get_Faction_Name())]

    DebugMessage("%s -- Tech_Stealing Tech Table Entry for %s:  %s", tostring(Script), tostring(Player), tostring(Player_Entry))

    return Player_Entry
end

---@param Player PlayerWrapper|nil
---@param Tech_level number|nil
---@return table|nil
function Tech_Stealing.Tech_Table:Get_Tech_Level_Entry(Player, Tech_level)
    if Tech_level == nil then
        return nil
    end

    if Tech_level < 1 or Tech_level > 5 then
        return nil
    end

    if not TestValid(Player) then
        return nil
    end

    local Player_Entry = self:Get_Player_Entry(Player)

    if Player_Entry == nil then
        return nil
    end

    local Tech_Level_Entry = Player_Entry[Tech_level]

    return Tech_Level_Entry
end

---@return table
function Tech_Stealing.Tech_Table:Techs_Left_To_Steal(Player, Tech_Level)

    local Techs_Info = {
        Total = 0,
        Stolen = 0,
    }

    if not TestValid(Player) then
        return Techs_Info
    end

    if type(Tech_Level) ~= "number" then
        return Techs_Info
    end

    if Tech_Level < 1 then
        return Techs_Info
    end

    if Tech_Level > 4 then
        return Techs_Info
    end

    local Techs_Table = self:Get_Tech_Level_Entry(Player, Tech_Level)

    if Techs_Table == nil then
        return Techs_Info
    end

    for _, Stolen in pairs(Techs_Table) do
        Techs_Info.Total = Techs_Info.Total + 1
    
        if Stolen then
            Techs_Info.Stolen = Techs_Info.Stolen + 1
        end
    end

    return Techs_Info
     
end

function Tech_Stealing.Tech_Table:Is_Tech_Stolen(Player, Tech_Name)
    if not TestValid(Player) then
        return true
    end

    if Tech_Name == nil then
        return true
    end

    local Player_Entry = self:Get_Player_Entry(Player)

    if Player_Entry == nil then
        return true
    end

    for Tech_Level, Techs in pairs(Player_Entry) do
        for Tech, Stolen in pairs(Techs) do
            if Tech == Tech_Name then
                return Stolen
            end
        end
    end

    return true
end

---@param Player PlayerWrapper|nil
---@param Tech_Name string|nil
---@param Is_Stolen boolean|nil
function Tech_Stealing.Tech_Table:Set_Tech_Stolen_Status(Player, Tech_Name, Is_Stolen)
    if not TestValid(Player) then
        return
    end

    if type(Tech_Name) ~= "string" then
        return
    end

    if type(Is_Stolen) ~= "boolean" then
        return
    end

    local Player_Entry = self:Get_Player_Entry(Player)

    if Player_Entry == nil then
        return 
    end

    for Tech_Level, Techs in pairs(Player_Entry) do
        for Tech, Stolen in pairs(Techs) do
            if Tech == Tech_Name then
                self[string.upper(Player.Get_Faction_Name())][Tech_Level][Tech] = Is_Stolen
                break
            end
        end
    end
end

function Tech_Stealing:Init(Plot)


    if Planet_Table == nil or tableLength(Planet_Table.Planets) < 1 then
        ScriptError("%s -- Planet Table is Empty or Nil", tostring(Script))
    end

    self.Player = Find_Human_Player()

    if not TestValid(self.Player) then
        ScriptError("%s -- Cannot Find a Valid Human Player", tostring(Script)) -- ScriptError auto Script Exits
    end

    local Tech_Table_Entry = self.Tech_Table:Get_Player_Entry(self.Player)

    if Tech_Table_Entry == nil then
        DebugMessage("%s -- No Ship Table Entry for Player: %s",tostring(Script), tostring(self.Player.Get_Faction_Name()))
        return
    end

    local Valid_Targets_Entry = self.Theft_Table.Valid_Theft_Targets[string.upper(self.Player.Get_Faction_Name())]

    if Valid_Targets_Entry == nil or tableLength(Valid_Targets_Entry) < 1 then
        ScriptError("%s -- Player does not have a Valid Targets Table", tostring(Script))
    end

    if Unit_Filters == nil then
        ScriptError("%s -- Unit Filter System is not init", tostring(Script))
    end

    for _, Tech_Entry in pairs(Tech_Table_Entry) do
        for Tech, Stolen in pairs(Tech_Entry) do
            if Tech ~= nil then
                Unit_Filters:Should_Lock_Unit(Tech, not Stolen)
            end
        end
    end

    self.Plot = Get_Story_Plot(Plot)

    if self.Plot ~= nil then

        Story_Event("ACTIVATE_THEFT_DISPLAY")

        self.Display = self.Plot.Get_Event("Tech_Theft_Display")
    end

    if self.Display == nil then
        ScriptError("%s -- Could not find a valid display Event or Plot File", tostring(Script))
    end

    self.Initialized = true
end

function Tech_Stealing:Update()

    if not self.Initialized then
        return
    end

    self.Display.Clear_Dialog_Text()

    self:Check_For_Tech_Advance()

    if self.Theft_Cooldown.Active and self.Theft_Cooldown.End_On ~= nil then
        self.Display.Add_Dialog_Text(self.String_Table.COOLDOWN_STATUS, tostring(self.Theft_Cooldown.End_On))

        self.Display.Add_Dialog_Text(" ")

        DebugMessage("%s -- Theft Cooldown is Active Until: %s, Current Time: %s", tostring(Script), tostring(self.Theft_Cooldown.End_On), tostring(Get_Current_Week()))

        if Get_Current_Week() >= self.Theft_Cooldown.End_On then
            DebugMessage("%s -- Cooldown Ended", tostring(Script))
            self.Theft_Cooldown.Active = false
            self.Theft_Cooldown.End_On = nil

            Unit_Filters:Should_Lock_Unit(self.Stealing_Unit.Unit_Name[string.upper(self.Player.Get_Faction_Name())].Lock, false)
        end
    end

    ---@type table
    local Techs_Left = self.Tech_Table:Techs_Left_To_Steal(self.Player, self.Player.Get_Tech_Level())

    local Techs_Left_String = tostring(Techs_Left.Stolen) .. " / " .. tostring(Techs_Left.Total)

    

    self.Display.Add_Dialog_Text(self.String_Table.STATUS, tostring(self.Player.Get_Tech_Level()), Techs_Left_String)

    self.Display.Add_Dialog_Text(" ")
    
    if self.Last_Theft_Info.Tech_Stolen ~= nil then
        self.Display.Add_Dialog_Text(self.String_Table.LAST_THEFT, tostring(self.Last_Theft_Info.Verdict), tostring(self.Last_Theft_Info.Tech_Stolen))

        self.Display.Add_Dialog_Text(" ")
    end

    self.Display.Add_Dialog_Text(self.String_Table.VALID_TARGETS)

    local Valid_Targets_Table = self.Theft_Table.Valid_Theft_Targets[string.upper(self.Player.Get_Faction_Name())]

    if Valid_Targets_Table ~= nil then
        for _, Faction_Name in pairs(Valid_Targets_Table) do

            local Proper_Faction_Name = self.String_Table[string.upper(Faction_Name)]

            if Proper_Faction_Name ~= nil then
                self.Display.Add_Dialog_Text(Proper_Faction_Name)
            end
        end
    end

    local Stealing_Unit_Name = self.Stealing_Unit.Unit_Name[string.upper(self.Player.Get_Faction_Name())].Find

    DebugMessage("%s -- Could not Find Valid Stealing_Unit Object for Faction: %s, Checking for: %s", tostring(Script), tostring(self.Player), tostring(Stealing_Unit_Name))

    local Theft_Unit = Find_First_Object(Stealing_Unit_Name)

    DebugMessage("%s -- Checking Stealing_Unit Object: %s", tostring(Script), tostring(Theft_Unit))

    if Theft_Unit ~= nil then
        self.Stealing_Unit.Object = Theft_Unit
    else
        return
    end

    DebugMessage("%s -- Stealing_Unit: %s", tostring(Script), tostring(self.Stealing_Unit.Object))

    local Stealing_Fleet = self.Stealing_Unit.Object.Get_Parent_Object().Get_Parent_Object()

    DebugMessage("%s -- Stealing_Unit Fleet: %s", tostring(Script), tostring(Stealing_Fleet))

    if Stealing_Fleet == nil then
        return
    end

    local Fleet_Size = Stealing_Fleet.Get_Contained_Object_Count()

    DebugMessage("%s -- Stealing_Unit Fleet Size: %s", tostring(Script), tostring(Fleet_Size))

    if Fleet_Size ~= 1 then
        return
    end

    local Location = self.Stealing_Unit.Object.Get_Planet_Location()

    DebugMessage("%s -- Stealing_Unit Location: %s", tostring(Script), tostring(Location))

    if not TestValid(Location) then
        return
    end

    if not self:Is_Valid_Target_Planet(Location) then
        return
    end

    DebugMessage("%s -- All Steal Checks are Valid running self:Steal_Tech", tostring(Script))

    self:Steal_Tech(Location)

end

function Tech_Stealing:Check_For_Tech_Advance()

    DebugMessage("%s -- Check if %s Tech Level Should Advance", tostring(Script), tostring(Player))

    local Tech_Level = self.Player.Get_Tech_Level()

    DebugMessage("%s -- Players Tech Level: %s", tostring(Script), tostring(Tech_Level))

    local Tech_Table = self.Tech_Table:Get_Player_Entry(self.Player)

    PrintTable(Tech_Table)

    if Tech_Table ~= nil and Tech_Table ~= nil then
        local Tech_Entries = Tech_Table[Tech_Level]

        PrintTable(Tech_Entries)

        local Should_Advance_Tech_Level = true -- we default to true, that way if there no entries we just skip that tech level, and that way we only look for the false stolen tech (faster sort of)
        if Tech_Entries ~= nil then
            for Tech, Stolen in pairs(Tech_Entries) do
                DebugMessage("%s -- Checking if %s Was Stolen: %s", tostring(Script), tostring(Tech), tostring(Stolen))
                if Stolen == false then
                    Should_Advance_Tech_Level = false

                    break
                end
            end
        end

        DebugMessage("%s -- Should Player Advance Tech Verdict: %s", tostring(Script), tostring(Should_Advance_Tech_Level))

        if Should_Advance_Tech_Level then
            self.Player.Set_Tech_Level(Tech_Level + 1)

            return
        end
    end
end

---@param Planet PlanetObject|nil
---@return boolean
function Tech_Stealing:Is_Valid_Target_Planet(Planet)

    if self.Theft_Table.Valid_Theft_Targets[string.upper(self.Player.Get_Faction_Name())] == nil or tableLength(self.Theft_Table.Valid_Theft_Targets[string.upper(self.Player.Get_Faction_Name())]) < 1 then
        return false
    end

    if not TestValid(Planet) then
        return false
    end

    local Location_Owner = Planet.Get_Owner()

    if not TestValid(Location_Owner) then
        return false
    end

    local Owner_Name = string.upper(Location_Owner.Get_Faction_Name())

    local Is_Valid = false

    for _, Target in pairs(self.Theft_Table.Valid_Theft_Targets[string.upper(self.Player.Get_Faction_Name())]) do
        if string.upper(Owner_Name) == string.upper(Target) then
            Is_Valid = true
        end
    end

    return Is_Valid
end

---@return table
function Tech_Stealing:Select_Tech_To_Steal()
    local Tech_List = self.Tech_Table:Get_Player_Entry(self.Player)

    PrintTable(Tech_List)

    if Tech_List == nil then
        return {}
    end

    local Available_Techs = Tech_List[self.Player.Get_Tech_Level()]

    PrintTable(Available_Techs)

    if Available_Techs == nil then
        return {}
    end

    local Not_Stolen_Techs = {}

    for Tech, Stolen in pairs(Available_Techs) do
        DebugMessage("%s -- Tech to Add: %s, Is Stolen Already: %s", tostring(Script), tostring(Tech), tostring(Stolen))
        if Stolen == false then
            table.insert(Not_Stolen_Techs, Tech)
        end
    end

    PrintTable(Not_Stolen_Techs)

    return Not_Stolen_Techs
end

---@param Planet nil|PlanetObject
function Tech_Stealing:Steal_Tech(Planet)

    DebugMessage("%s -- Steal_Tech Planet: %s", tostring(Script), tostring(Planet))

    if not TestValid(Planet) then
        return
    end

    DebugMessage("%s -- Steal_Tech Object: %s", tostring(Script), tostring(self.Stealing_Unit.Object))

    if not TestValid(self.Stealing_Unit.Object) then
        return
    end

    DebugMessage("%s -- Steal_Tech Object Location: %s Comparing to Provided Planet: %s", tostring(Script), tostring(self.Stealing_Unit.Object.Get_Planet_Location()), tostring(Planet))

    if self.Stealing_Unit.Object.Get_Planet_Location() ~= Planet then
        return
    end

    local Random_Tech = Random_From_List(self:Select_Tech_To_Steal())

    DebugMessage("%s -- Stealing Random Tech: %s", tostring(Script), tostring(Random_Tech))

    if Random_Tech == nil then
        return
    end

    local Theft_Status = Tech_Stealing:Does_Theft_Succeed(Planet)

    PrintTable(Theft_Status)

    if Theft_Status.Was_Stolen ~= true then
        DebugMessage("%s -- Theft Failed", tostring(Script))

        self.Stealing_Unit.Object.Despawn()

        self:Thief_Build_Cooldown(Theft_Status)

        self.Last_Theft_Info.Verdict = false
        self.Last_Theft_Info.Tech_Stolen = "None"

        return
    end

    DebugMessage("%s -- Steal_Tech Succeed", tostring(Script))

    self.Last_Theft_Info.Verdict = true
    self.Last_Theft_Info.Tech_Stolen = Random_Tech

    Unit_Filters:Should_Lock_Unit(Random_Tech, false) 
    
    self.Tech_Table:Set_Tech_Stolen_Status(self.Player, Random_Tech, true)

    self.Stealing_Unit.Object.Despawn()

    self:Thief_Build_Cooldown(Theft_Status)
end

function Tech_Stealing:Thief_Build_Cooldown(Theft_Status)

    if type(Theft_Status) ~= "table" then
        return
    end

    local Cooldown_Time = self.Theft_Table.Base_Respawn_Time_Per_Planet_Difficulty[Theft_Status.Difficulty]

    self.Theft_Cooldown.Active = true
    self.Theft_Cooldown.End_On = Get_Current_Week() + Cooldown_Time

    Unit_Filters:Should_Lock_Unit(self.Stealing_Unit.Unit_Name[string.upper(self.Player.Get_Faction_Name())].Lock, true)
end

---@param Planet PlanetObject|nil
---@return table
function Tech_Stealing:Does_Theft_Succeed(Planet)

    DebugMessage("%s -- Checking if Theft will Succeed for Planet: %s",tostring(Script), tostring(Planet))

    if not TestValid(Planet) then
        return Return_Theft_Status()
    end

    local Planet_Entry = Planet_Table:Get_Entry(Planet)

    PrintTable(Planet_Entry)

    if Planet_Entry == nil then
        return Return_Theft_Status()
    end 

    local Availability = Planet_Entry.Tech_Availability
    local Difficulty = Planet_Entry.Tech_Difficulty

    DebugMessage("%s -- Planet Tech Availability: %s, Planet Tech Difficulty: %s",tostring(Script), tostring(Availability), tostring(Difficulty))

    if type(Availability) == "number" and type(Difficulty) == "number" then
        local Availability_Chance = self.Theft_Table.Chance_Table.Availability[Availability]
        local Difficulty_Chance = self.Theft_Table.Chance_Table.Difficulty[Difficulty]

        DebugMessage("%s -- Availability Chance: %s, Difficulty Chance: %s", tostring(Script), tostring(Availability_Chance), tostring(Difficulty_Chance))

        if type(Availability_Chance) == "number" and type(Difficulty_Chance) == "number" then
            return Return_Theft_Status(Return_Chance(Availability_Chance * Difficulty_Chance, 1), Availability, Difficulty)
        end
    end

    return Return_Theft_Status()
end

function Return_Theft_Status(Stolen, Planet_Avail, Planet_Diff)
    if type(Stolen) ~= "boolean" then
        Stolen = false
    end

    if type(Planet_Avail) ~= "number" then
        Planet_Avail = 1
    end

    if type(Planet_Diff) ~= "number" then
        Planet_Diff = 1
    end

    if Planet_Avail < 1 then
        Planet_Avail = 1
    end

    if Planet_Avail > 5 then
        Planet_Avail = 5
    end

    if Planet_Diff < 1 then
        Planet_Diff = 1
    end

    if Planet_Diff > 5 then
        Planet_Diff = 5
    end

    return {Was_Stolen = Stolen, Availability = Planet_Avail, Difficulty = Planet_Diff}
end

return Tech_Stealing