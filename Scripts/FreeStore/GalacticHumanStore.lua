-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/FreeStore/GalacticFreeStore.lua#3 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/FreeStore/GalacticFreeStore.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 56727 $
--
--          $DateTime: 2006/10/24 14:14:26 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgcommands")
require("HALOFunctions")

function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 0.3
	UnitServiceRate = 20
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.0
	GroundMovePercent = 0.0

	freighter_table = {}

	cooldown_time = 2

	Freighter_Limit = 0

	FreighterCount = 0

	if Definitions then
		Definitions()
	end
end

function main()

	DebugMessage("%s -- In main for %s", tostring(Script), tostring(FreeStore))
	
	if FreeStoreService then
		while 1 do
			FreeStoreService()
			PumpEvents()
		end
	end
	
	ScriptExit()
end

function MoveUnit(object)

	if freighter_table[object] == nil then
		return false
	end

	local freighter_entry = freighter_table[object]
	local target = freighter_entry.Destination

	if target == nil then
		return
	end

	FreeStore.Move_Object(object, target)

	DebugMessage("%s -- Moving %s to %s", tostring(Script), tostring(object), tostring(target))

	return true
	
end

function On_Unit_Service(object)

	if not TestValid(object) then
		if freighter_table[object] ~= nil then
			freighter_table[object] = nil
		end

		return
	end
	
	if object.Get_Type().Get_Name() ~= "UNSC_GOODS_TRANSPORT" then
		return
	end

	DebugMessage("%s -- Servicing %s", tostring(Script), tostring(object))

	if object.Get_Planet_Location() == nil then
		DebugMessage("%s -- Canceling Service, No Valid Planet", tostring(Script))
		return
	end

	local Entry = freighter_table[object]

	if Entry == nil then
		return
	end
	
	if Entry.Destination == nil then
		Entry.Destination = Find_Target(object)
		Entry.Start = object.Get_Planet_Location()

		DebugMessage("%s -- Freighter %s Info: Start %s, Target: %s", tostring(Script), tostring(Entry.Number), tostring(Entry.Start), tostring(Entry.Destination))

		MoveUnit(object)
	end

	if Entry.Destination ~= nil then
		if not FreeStore.Is_Unit_In_Transit(object) and not Entry.Done then
			if object.Get_Planet_Location() == Entry.Destination then
				DebugMessage("Freighter Done with Transport")
				Reward_Freighter(object, Entry)
			else
				DebugMessage("Movement Interupted")
				Entry.Destination = object.Get_Planet_Location()
				Reward_Freighter(object, Entry)
			end
		end

		if Entry.Done and Entry.Finished_Date == nil then
			Entry.Finished_Date = Get_Current_Week()
		end

		if Entry.Finished_Date ~= nil and Entry.Done then
			if Get_Current_Week() >= Entry.Finished_Date + cooldown_time then
				Entry.Done = false
				Entry.Finished_Date = nil
				Entry.Destination = nil
			end
		end
	end

	DebugMessage("%s -- EoS for Freighter %s, Destination: %s", tostring(Script), tostring(Entry.Number), tostring(Entry.Des))
	
end

--	// param 1: playerwrapper.
--	// param 2: perception function name
--	// param 3: goal application type string
--	// param 4: reachability type string
--	// param 5: The probability of selecting the target with highest desire
--	// param 6: The source from which the find target should search for relative targets.
--	// param 7: The maximum distance from source to target.
function On_Unit_Added(object)
	DebugMessage("%s -- Added %s to Freestore", tostring(Script), tostring(object))
	
	if object.Get_Type().Get_Name() ~= "UNSC_GOODS_TRANSPORT" then
		return
	end

	if freighter_table[object] ~= nil then
		return
	end

	freighter_table[object] = {
		Destination = nil,
	    Start = nil,
	    Done = false,
		Number = Generate_Freight_Number(),
		Finished_Date = nil
	}
end


function FreeStoreService()

	local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Freighter_Display.xml")

	local event = plot.Get_Event("Freight_Display")
	event.Clear_Dialog_Text() -- Clears all added Text

	

	local freighter_list = Find_All_Objects_Of_Type("UNSC_GOODS_TRANSPORT")

	FreighterCount = tableLength(freighter_list)

	Freighter_Limit = Max_Freighters()

	if tableLength(All_UNSC_Planets()) < 2 then
		return
	end

	DebugMessage("%s -- Current Freighter Count: %s, Max Freighter Count: %s", tostring(Script), tostring(FreighterCount), tostring(Freighter_Limit))

	if FreighterCount >= Freighter_Limit then
		GlobalValue.Set("Max_Freighters", 1)

		local freighters_to_remove = FreighterCount - Freighter_Limit

		local freighters_removed = 0

		for _, freighter in pairs(freighter_list) do
			if (freighter_table[freighter] == nil or not FreeStore.Is_Unit_In_Transit(freighter)) and freighters_removed < freighters_to_remove then
				Game_Message("TEXT_STORY_FREIGHT_MANAGER_LIMIT")
				local freighter_cost = freighter.Get_Type().Get_Build_Cost()
				freighter.Get_Owner().Give_Money(freighter_cost)
				freighter.Despawn()
				freighters_removed = freighters_removed + 1
			end
		end
	else
		GlobalValue.Set("Max_Freighters", 0)
	end

	event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_CURRENT_LIMIT", tostring(Max_Freighters()), tostring(FreighterCount))
	
	if FreighterCount <= 0 then
		return	
	end

	for _, freighter in pairs(freighter_list) do

		local freighter_entry = freighter_table[freighter]

		if freighter_entry ~= nil then

			DebugMessage("%s -- Frieghter %s Start: %s, Destination: %s", tostring(Script), tostring(freighter_entry.Number), tostring(freighter_entry.Start), tostring(freighter_entry.Destination))

			if freighter_entry.Start ~= nil and freighter_entry.Destination ~= nil then
				event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_01", tostring(freighter_entry.Number)) 
				event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_02", freighter_entry.Start.Get_Type().Get_Name(), freighter_entry.Destination.Get_Type().Get_Name())
				event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_03", tostring(Calculate_Reward_Income(freighter, freighter_entry)))
				event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_04", tostring(freighter_entry.Done))
				event.Add_Dialog_Text(" ")
			end
		end
	end
end

function Freighter_Setup(freighter)

	local freighter_entry = freighter_table[freighter]
	
	if freighter_entry ~= nil then
		if freighter_entry.Done ~= true then
			return
		end
	end

	local dest = Find_Target(freighter)
	local starting = freighter.Get_Planet_Location()
	freighter_table[freighter] = {
		Destination = dest,
	    Start = starting,
	    Done = false,
		Number = Generate_Freight_Number(),
		Finished_Date = nil
	}
end

function Find_Target(freighter)

	local target = FindTarget.Reachable_Target(freighter.Get_Owner(), "Is_Connected_To_Me", "Friendly", "Friendly_Only", 0.1, freighter) -- Using PerceptualEquations from SandboxHuman, select a planet that we own

	if target == nil then
		return Find_Target(freighter)
	end

	if freighter.Get_Planet_Location() == nil then
		return Find_Target(freighter)
	end
    
    -- PerceptualEquation does not return a gameobject, so we call a function that somehow does turn it into one
    target = target.Get_Game_Object()

    -- Find a path from the freighter's location to the target
    local path = Find_Path(freighter.Get_Owner(), freighter.Get_Planet_Location(), target)

	if path == nil then
		return Find_Target(freighter)
	end

	if tableLength(path) < 2 then
		return Find_Target(freighter)
	end
    
    -- Check if the path contains any planets not controlled by the freighter's owner
    local contains_non_controlled = false
    for _, planet in pairs(path) do
        if planet.Get_Owner() ~= freighter.Get_Owner() then
            contains_non_controlled = true
            break
        end
    end

    -- If the target is the same as the freighter's current location or if the path contains non-controlled planets, call the function recursively
    if target == freighter.Get_Planet_Location() or contains_non_controlled then
        return Find_Target(freighter)  -- Recursive call
    end

    -- Return the valid target if found
    if TestValid(target) then
        return target
    end
end

function All_UNSC_Planets()
	local planets = FindPlanet.Get_All_Planets()

	local unsc_planets = {}

	for _, planet in pairs(planets) do
		if planet.Get_Owner() == PlayerObject then
			table.insert(unsc_planets, planet)
		end
	end

	return unsc_planets
end

function Max_Freighters()

	local Trade_Platform_Count = tableLength(Find_All_Objects_Of_Type("UNSC_Trade_Platform"))

	local Base_Max = 2

	return Base_Max * Trade_Platform_Count
end

function Generate_Freight_Number()
	local randomNum = EvenMoreRandom(1,500, 15)

	local isTaken = false

	if tableLength(freighter_table) > 1 then
		for _, freighter in pairs(freighter_table) do
			if freighter.Number == randomNum then
				isTaken = true
				break
			end
		end
	end

	if isTaken then
		return Generate_Freight_Number()
	end

	return randomNum
end

function Calculate_Reward_Income(freighter, entry)
	local base_credit = 110

	local credit_muliplier = (tableLength(Find_Path(freighter.Get_Owner(), entry.Start, entry.Destination))) - 1

	if credit_muliplier < 1 then
		credit_muliplier = 1
	end

	if credit_muliplier > 10 then
		credit_muliplier = 10
	end

	return (base_credit * credit_muliplier)
end


function Reward_Freighter(freighter, entry)
	
	local bonus = 0

	if EvaluatePerception("Does_Planet_Have_Econ_Structures", PlayerObject, freighter.Get_Planet_Location()) > 0 then
		bonus = 250
    end

	local income = Calculate_Reward_Income(freighter, entry) + bonus

	freighter.Get_Owner().Give_Money(income)

    freighter_table[freighter].Done = true

    DebugMessage("Finished Freight Trip from: " .. tostring(entry.Start) .. " To: " ..  tostring(entry.Destination) .. ", With an Income of " .. tostring(income) .. " Credits")

	Game_Message("Finished Freight Trip from: " .. entry.Start.Get_Type().Get_Name() .. " To: " ..  tostring(entry.Destination.Get_Type().Get_Name()) .. ", With an Income of " .. (income) .. " Credits")
end