---@class Freighter_Framework
Freighter_Framework = {
    ---@type Freighter_Entry[]
    Freighters = {},
    Freight_Cooldown = 2, -- years
    ---@type PlayerWrapper
    Player = nil,
    Freighter_Name = "",
    Trade_Platform_Name = "",
    Income_Per_Year = {},
    Taken_Freight_Numbers = {},
    ---@type StoryPlot
    Plot = nil,
    ---@type StoryEvent
    Display = nil,
    Initialized = false,
}

function Freighter_Framework:Init(Player, Freighter_Name, Trade_Platform_Name)
    --DebugMessage("%s -- Init() called with Freighter_Name: %s", tostring(Script), tostring(Freighter_Name))

    if self.Initialized then
        --DebugMessage("%s -- Init() already initialized, returning early", tostring(Script))
        return
    end

    if not TestValid(Player) then
        --DebugMessage("%s -- Init() failed: Invalid Player", tostring(Script))
        ScriptExit()
        return
    end

    self.Player = Player

    if type(Freighter_Name) ~= "string" then
        --DebugMessage("%s -- Init() failed: Invalid Freighter_Name type", tostring(Script))
        ScriptExit()
        return
    end

    self.Freighter_Name = Freighter_Name

    if type(Trade_Platform_Name) ~= "string" then
        --DebugMessage("%s -- Init() failed: Invalid Trade_Platform_Name type", tostring(Script))
        ScriptExit()
        return
    end

    self.Trade_Platform_Name = Trade_Platform_Name

    --DebugMessage("%s -- Init() loading plot file", tostring(Script))
    self.Plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Freighter_Display.xml")

    if self.Plot == nil then
        --DebugMessage("%s -- Init() failed: Could not load story plot", tostring(Script))
        ScriptExit()
        return
    end

    --DebugMessage("%s -- Init() retrieving display event", tostring(Script))
    self.Display = self.Plot.Get_Event("Freight_Display")

    if self.Display == nil then
        --DebugMessage("%s -- Init() failed: Could not get Freight_Display event", tostring(Script))
        ScriptExit()
        return
    end

    --DebugMessage("%s -- Init() completed successfully", tostring(Script))
    self.Initialized = true
end

function Freighter_Framework:Service()
    --DebugMessage("%s -- Service() called", tostring(Script))

    if not self.Initialized then
        --DebugMessage("%s -- Service() not initialized, returning", tostring(Script))
        return
    end

    self.Display.Clear_Dialog_Text()

    
    local Freighters = Find_All_Objects_Of_Type(self.Freighter_Name)

    local Freighter_Count = tableLength(Freighters)

    local Freighter_Limit = self:Freighter_Cap()

    self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_CURRENT_LIMIT", tostring(Freighter_Limit), tostring(Freighter_Count))
    
    self.Display.Add_Dialog_Text(" ")

    if Freighters == nil or tableLength(Freighters) < 1 then
        --DebugMessage("%s -- Service() no freighters found", tostring(Script))
        return
    end

    if not self:More_Than_1_Planet_Owned() then
        --DebugMessage("%s -- Service() player does not own more than 1 planet", tostring(Script))
        return
    end

    if Freighter_Count >= Freighter_Limit then
        --DebugMessage("%s -- Service() freighter count at limit, removing excess. Count: %s, Limit: %s", tostring(Script), tostring(Freighter_Count), tostring(Freighter_Limit))
        GlobalValue.Set("Max_Freighters", 1)

        local Freighters_To_Remove = Freighter_Count - Freighter_Limit

        local Freighters_Removed = 0

        if Freighters_To_Remove > 0 then
            for _, Freighter in pairs(Freighters) do

                if TestValid(Freighter) then
                    if Freighters_Removed >= Freighters_To_Remove then
                        break
                    end

                    local Freighter_Entry = self:Get_Freighter_Entry(Freighter)

                    if Freighter_Entry == nil or Freighter_Entry.Allowed_To_Move == false then
                        local Freighter_Cost = Freighter.Get_Type().Get_Build_Cost()
                        Freighter.Despawn()
                        self.Freighters[Freighter] = nil
                        self.Player.Give_Money(Freighter_Cost)
                        Freighters_Removed = Freighters_Removed + 1
                    end
                end
            end
        end
    else
        --DebugMessage("%s -- Service() freighter count below limit. Count: %s, Limit: %s", tostring(Script), tostring(Freighter_Count), tostring(Freighter_Limit))
        GlobalValue.Set("Max_Freighters", 0)
    end

    for _, Freighter_Entry in pairs(self.Freighters) do
        Freighter_Entry.Allowed_To_Move = true
    end

    local Current_Year = Get_Current_Week()
    
    local Generated_Income = 0

    for Year, Income in pairs(self.Income_Per_Year) do
        Generated_Income = Generated_Income + Income
    end

    self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_YTD", formatNumberWithCommas(Generated_Income))

    self.Display.Add_Dialog_Text(" ")

    local Avg_Income_Per_Year = 0

    if Current_Year > 0 and Generated_Income > 0 then
        Avg_Income_Per_Year = Generated_Income/Current_Year
    end

    self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_AVG", formatNumberWithCommas(Avg_Income_Per_Year))

    self.Display.Add_Dialog_Text(" ")

    local Year_Current_Income = self.Income_Per_Year[Current_Year]

    local Year_Current_Income_String = "TEXT_STORY_FREIGHT_MANAGER_YTD_NONE"

    if type(Year_Current_Income) == "number" then
        Year_Current_Income_String = formatNumberWithCommas(Year_Current_Income)
    end

    self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_YEAR", tostring(Current_Year), Year_Current_Income_String)

    self.Display.Add_Dialog_Text(" ")

    if Freighter_Count < 1 then
        return
    end

    for _, Freighter_Entry in pairs(self.Freighters) do
        if Freighter_Entry.Start ~= nil and Freighter_Entry.Destination ~= nil then
            self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_01", tostring(Freighter_Entry.Number)) 
			self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_02", Freighter_Entry.Start.Get_Type().Get_Name(), Freighter_Entry.Destination.Get_Type().Get_Name())
            self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_03", formatNumberWithCommas(self:Calculate_Reward_Income(Freighter_Entry.Object, Freighter_Entry)))
			self.Display.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_04", tostring(Freighter_Entry.Done))
			self.Display.Add_Dialog_Text(" ")
        end
    end
end


---@param Freighter GameObject
function Freighter_Framework:Initialize_Freighter(Freighter)
    --DebugMessage("%s -- Initialize_Freighter() called for: %s", tostring(Script), tostring(Freighter))

    if not TestValid(Freighter) then
        --DebugMessage("%s -- Initialize_Freighter() freighter is invalid", tostring(Script))
        return
    end

    if string.upper(Freighter.Get_Type().Get_Name()) ~= string.upper(self.Freighter_Name) then
        --DebugMessage("%s -- Initialize_Freighter() freighter type mismatch to: %s", tostring(Script), tostring(self.Freighter_Name))
        return
    end

    if self.Freighters[Freighter] ~= nil then
        --DebugMessage("%s -- Initialize_Freighter() freighter already initialized", tostring(Script))
        return
    end

    
    local freight_number = self:Generate_Freight_Number()
    --DebugMessage("%s -- Initialize_Freighter() created entry with freight number: %s", tostring(Script), tostring(freight_number))
    ---@class Freighter_Entry
    self.Freighters[Freighter] = {
        ---@type PlanetObject|nil
        Destination = nil,
        ---@type PlanetObject|nil
        Start = nil,
        Done = false,
        Number = freight_number,
        ---@type number
        Finished_Date = nil,
        Allowed_To_Move = false,
        Object = Freighter,
    }
end

---@param Freighter GameObject
---@return Freighter_Entry|nil
function Freighter_Framework:Get_Freighter_Entry(Freighter)
    if not TestValid(Freighter) then
        return
    end

    if self.Freighters[Freighter] == nil then
        return nil
    end

    return self.Freighters[Freighter]
end

---@param Freighter GameObject
function Freighter_Framework:Service_Freighter(Freighter)

    if not TestValid(Freighter) then
        return
    end

    if self.Freighters[Freighter] == nil then
        return
    end

    --DebugMessage("%s -- Servicing Freighter: %s", tostring(Script), tostring(Freighter))

    if not TestValid(Freighter.Get_Planet_Location()) then
        return
    end

    ---@type Freighter_Entry|nil
    local Freighter_Entry = self:Get_Freighter_Entry(Freighter)

    if Freighter_Entry == nil then
        return
    end

    if not Freighter_Entry.Allowed_To_Move then
        return
    end

    if Freighter_Entry.Destination == nil then
        --DebugMessage("%s -- Service_Freighter() finding destination for freight %s", tostring(Script), tostring(Freighter_Entry.Number))
        Freighter_Entry.Destination = self:Find_Target(Freighter)
        Freighter_Entry.Start = Freighter.Get_Planet_Location()

        if Freighter_Entry.Destination ~= nil then
            --DebugMessage("%s -- Service_Freighter() destination found for freight %s, initiating move", tostring(Script), tostring(Freighter_Entry.Number))
            self:Move_Unit(Freighter)
        else
            --DebugMessage("%s -- Service_Freighter() no destination found for freight %s", tostring(Script), tostring(Freighter_Entry.Number))
        end
    end

    if Freighter_Entry.Destination == nil then
        return
    end

    if not FreeStore.Is_Unit_In_Transit(Freighter) and not Freighter_Entry.Done then -- if unit is not moving and not set to done yet
        if Freighter.Get_Planet_Location() == Freighter_Entry.Destination then
            --DebugMessage("%s -- Service_Freighter() freight %s reached destination", tostring(Script), tostring(Freighter_Entry.Number))
            self:Reward_Freighter(Freighter)
        else -- Movement was Interrupted
            --DebugMessage("%s -- Service_Freighter() freight %s movement interrupted, rewarding at current location", tostring(Script), tostring(Freighter_Entry.Number))
            Freighter_Entry.Destination = Freighter.Get_Planet_Location()

            self:Reward_Freighter(Freighter)
        end
    end

    if Freighter_Entry.Finished_Date ~= nil and Freighter_Entry.Done then
        if Get_Current_Week() >= Freighter_Entry.Finished_Date + self.Freight_Cooldown then
            --DebugMessage("%s -- Service_Freighter() freight %s cooldown expired, resetting for next trip", tostring(Script), tostring(Freighter_Entry.Number))
            Freighter_Entry.Done = false
            Freighter_Entry.Finished_Date = nil
            Freighter_Entry.Destination = nil
        else
            --DebugMessage("%s -- Service_Freighter() freight %s on cooldown. Current: %s, Reset at: %s", tostring(Script), tostring(Freighter_Entry.Number), tostring(Get_Current_Week()), tostring(Freighter_Entry.Finished_Date + self.Freight_Cooldown))
        end
    end
end

---@param Freighter GameObject
function Freighter_Framework:Move_Unit(Freighter)
    --DebugMessage("%s -- Move_Unit() called for: %s", tostring(Script), tostring(Freighter))
    if not TestValid(Freighter) then
        --DebugMessage("%s -- Move_Unit() freighter is invalid", tostring(Script))
        return
    end

    if Freighter.Get_Planet_Location() == nil then
        --DebugMessage("%s -- Move_Unit() freighter has no planet location", tostring(Script))
        return
    end

    local Freighter_Entry = self:Get_Freighter_Entry(Freighter)

    if Freighter_Entry == nil then
        return
    end

    local Target = Freighter_Entry.Destination

    if not TestValid(Target) then
        --DebugMessage("%s -- Move_Unit() target is invalid", tostring(Script))
        return
    end

    --DebugMessage("%s -- Move_Unit() moving freighter from %s to %s", tostring(Script), tostring(Freighter.Get_Planet_Location()), tostring(Target))
    FreeStore.Move_Object(Freighter, Target)

    return
end

---@param Freighter GameObject
---@param tries number
---@return PlanetObject|nil
function Freighter_Framework:Find_Target(Freighter, tries)
    if not TestValid(Freighter) then
        --DebugMessage("%s -- Find_Target() freighter is invalid", tostring(Script))
        return nil
    end

    if not TestValid(Freighter.Get_Planet_Location()) then
        --DebugMessage("%s -- Find_Target() freighter planet location is invalid", tostring(Script))
        return
    end

    if tries == nil then
        tries = 0
        --DebugMessage("%s -- Find_Target() starting target search for: %s", tostring(Script), tostring(Freighter))
    end

    if tries > 20 then
        --DebugMessage("%s -- Find_Target() exceeded max recursion attempts (%s)", tostring(Script), tostring(tries))
        return nil
    end

    local Target = FindTarget.Reachable_Target(self.Player, "Is_Connected_To_Me", "Friendly", "Friendly_Only", 0.1, Freighter) -- Using PerceptualEquations from SandboxHuman, select a planet that we own

    if Target == nil then
        --DebugMessage("%s -- Find_Target() no reachable target found, attempt %s/20", tostring(Script), tostring(tries))
        return self:Find_Target(Freighter, tries + 1)
    end

    local Target_Object = Target.Get_Game_Object()

    if not TestValid(Target_Object) then
        --DebugMessage("%s -- Find_Target() target object is invalid, attempt %s/20", tostring(Script), tostring(tries))
        return self:Find_Target(Freighter, tries + 1)
    end

    if Target_Object == Freighter.Get_Planet_Location() then
        --DebugMessage("%s -- Find_Target() target same as current location, attempt %s/20", tostring(Script), tostring(tries))
        return self:Find_Target(Freighter, tries + 1)
    end

    local Path = Find_Path(self.Player, Freighter.Get_Planet_Location(), Target_Object)

    if Path == nil then
        --DebugMessage("%s -- Find_Target() no valid path found, attempt %s/20", tostring(Script), tostring(tries))
        return self:Find_Target(Freighter, tries + 1)
    end

    if tableLength(Path) < 3 then
        --DebugMessage("%s -- Find_Target() path too short (%s nodes), attempt %s/20", tostring(Script), tostring(tableLength(Path)), tostring(tries))
        return self:Find_Target(Freighter, tries + 1)
    end

    local Any_Uncontrolled_Planets = false

    for _, planet in pairs(Path) do
        if planet.Get_Owner() ~= self.Player then
            Any_Uncontrolled_Planets = true
            break
        end
    end

    if Any_Uncontrolled_Planets then
        --DebugMessage("%s -- Find_Target() path contains uncontrolled planets, attempt %s/20", tostring(Script), tostring(tries))
        return self:Find_Target(Freighter, tries + 1)
    end

    --DebugMessage("%s -- Find_Target() valid target found: %s", tostring(Script), tostring(Target_Object))
    return Target_Object
end

function Freighter_Framework:More_Than_1_Planet_Owned()
    local Planets = Planet_Table:Return_All_Keys()

    local Controlled_Planets = {}

    for _, Planet_Name in pairs(Planets) do
        local Planet = FindPlanet(Planet_Name)

        if TestValid(Planet) then
            if Planet.Get_Owner() == self.Player then
                table.insert(Controlled_Planets, Planet)
            end
        end
    end

    local controlled_count = tableLength(Controlled_Planets)
    --DebugMessage("%s -- More_Than_1_Planet_Owned() player controls %s planets", tostring(Script), tostring(controlled_count))
    return controlled_count > 1
end

---@param Freighter GameObject|nil
function Freighter_Framework:Reward_Freighter(Freighter)
    --DebugMessage("%s -- Reward_Freighter() called for: %s", tostring(Script), tostring(Freighter))
    if not TestValid(Freighter) then
        --DebugMessage("%s -- Reward_Freighter() freighter is invalid", tostring(Script))
        return
    end

    local Freighter_Entry = self:Get_Freighter_Entry(Freighter) 

    if Freighter_Entry == nil then
        --DebugMessage("%s -- Reward_Freighter() could not get freighter entry", tostring(Script))
        return
    end

    if not TestValid(Freighter.Get_Planet_Location()) then
        --DebugMessage("%s -- Reward_Freighter() freighter planet location is invalid", tostring(Script))
        return
    end

    local Bonus = 0

    if EvaluatePerception("Does_Planet_Have_Econ_Structures", self.Player, Freighter.Get_Planet_Location()) > 0 then
        Bonus = 125
    end

    local Income = self:Calculate_Reward_Income(Freighter, Freighter_Entry) + Bonus

    local Current_Year = Get_Current_Week()

    if self.Income_Per_Year[Current_Year] == nil then
        self.Income_Per_Year[Current_Year] = 0
    end

    self.Income_Per_Year[Current_Year] = self.Income_Per_Year[Current_Year] + Income

    --DebugMessage("%s -- Reward_Freighter() freight %s earned %s credits (bonus: %s). Year: %s", tostring(Script), tostring(Freighter_Entry.Number), tostring(Income), tostring(Bonus), tostring(Current_Year))
    self.Player.Give_Money(Income)

    Freighter_Entry.Done = true

    --Game_Message("TEXT_STORY_FREIGHT_MANAGER_TRIP", tostring(Freighter_Entry.Number), tostring(Income))
end

---@param Freighter GameObject|nil
---@param Entry Freighter_Entry|nil
---@return number
function  Freighter_Framework:Calculate_Reward_Income(Freighter, Entry)
    --DebugMessage("%s -- Calculate_Reward_Income() called for freight %s", tostring(Script), tostring(Entry.Number))
    if not TestValid(Freighter) then
        --DebugMessage("%s -- Calculate_Reward_Income() freighter is invalid", tostring(Script))
        return 0
    end

    if Entry == nil then
        --DebugMessage("%s -- Calculate_Reward_Income() entry is nil", tostring(Script))
        return 0
    end

    local Base_Income = 80

    local Path = Find_Path(self.Player, Entry.Start, Entry.Destination)

    if Path == nil then
        --DebugMessage("%s -- Calculate_Reward_Income() could not find path for freight %s", tostring(Script), tostring(Entry.Number))
        return 0
    end

    local Multiplier = tableLength(Path) - 1

    if Multiplier < 1 then
        Multiplier = 1
    end

    if Multiplier > 8 then
        Multiplier = 8
    end

    local final_income = (Base_Income * Multiplier)
    --DebugMessage("%s -- Calculate_Reward_Income() freight %s: base_income=%s, multiplier=%s (path_length=%s), final_income=%s", tostring(Script), tostring(Entry.Number), tostring(Base_Income), tostring(Multiplier), tostring(tableLength(Path)), tostring(final_income))
    return final_income
end

---@return number
function Freighter_Framework:Freighter_Cap()
    local Trade_Platforms = Find_All_Objects_Of_Type(self.Trade_Platform_Name)

    if Trade_Platforms == nil then
        --DebugMessage("%s -- Freighter_Cap() no trade platforms found", tostring(Script))
        return 0
    end

    local Trade_Platforms_Count = tableLength(Trade_Platforms)

    if type(Trade_Platforms_Count) ~= "number" then
        Trade_Platforms_Count = 0
    end

    local Base_Cap = 2 

    local cap = Trade_Platforms_Count * Base_Cap
    --DebugMessage("%s -- Freighter_Cap() calculated cap: %s (platforms: %s, base_cap: %s)", tostring(Script), tostring(cap), tostring(Trade_Platforms_Count), tostring(Base_Cap))
    return cap
end

---@return number
function Freighter_Framework:Generate_Freight_Number()
    local Random_Freight_Number = EvenMoreRandom(1, 1000, 15)

    if tableLength(self.Taken_Freight_Numbers) < 1 then
        --DebugMessage("%s -- Generate_Freight_Number() generated new freight number: %s", tostring(Script), tostring(Random_Freight_Number))
        self.Taken_Freight_Numbers[Random_Freight_Number] = true

        return Random_Freight_Number
    end

    local Attempts = 0
    
    while self.Taken_Freight_Numbers[Random_Freight_Number] and Attempts < 10 do
        Random_Freight_Number = EvenMoreRandom(1, 1000, 1)

        Attempts = Attempts + 1
    end

    --DebugMessage("%s -- Generate_Freight_Number() generated freight number with %s collision attempts: %s", tostring(Script), tostring(Attempts), tostring(Random_Freight_Number))
    self.Taken_Freight_Numbers[Random_Freight_Number] = true

    return Random_Freight_Number
end

return Freighter_Framework