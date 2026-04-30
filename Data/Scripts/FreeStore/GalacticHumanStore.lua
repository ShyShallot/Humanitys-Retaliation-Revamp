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
require("globalPlanetTable")
require("FreighterFramework")
require("Persistent_Damage")

function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 0.3
	UnitServiceRate = 1
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.0
	GroundMovePercent = 0.0

	---@type Freighter_Framework
	FreighterFramework = nil



	if Definitions then
		Definitions()
	end
end

function Definitions()
	FreighterFramework = Freighter_Framework

end

function main()

	DebugMessage("%s -- In main for %s", tostring(Script), tostring(FreeStore))

	DebugMessage("%s -- PlayerObject: %s", tostring(Script), tostring(PlayerObject))

	DebugMessage("%s -- Faction Name: %s", tostring(Script), tostring(PlayerObject.Get_Faction_Name()))

	if FreeStoreService then

		if PlayerObject.Get_Faction_Name() == "REBEL" or PlayerObject.Get_Faction_Name() == "TERRORISTS" then
			FreighterFramework:Init(PlayerObject, "UNSC_GOODS_TRANSPORT", "UNSC_Trade_Platform")
		end

		Persistent_Damage_Manager:Init()

		while 1 do
			FreeStoreService()
			PumpEvents()
		end
	end
	
	ScriptExit()
end


function On_Unit_Service(object)
	FreighterFramework:Service_Freighter(object)
end

--	// param 1: playerwrapper.
--	// param 2: perception function name
--	// param 3: goal application type string
--	// param 4: reachability type string
--	// param 5: The probability of selecting the target with highest desire
--	// param 6: The source from which the find target should search for relative targets.
--	// param 7: The maximum distance from source to target.
function On_Unit_Added(object)
	FreighterFramework:Initialize_Freighter(object)

	Persistent_Damage_Manager:Add_Object(object)
end


function FreeStoreService()
	FreighterFramework:Service()

	Persistent_Damage_Manager:Galactic_Update()
end
