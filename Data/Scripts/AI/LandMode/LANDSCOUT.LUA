-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/LandMode/LandScout.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/LandMode/LandScout.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 637819 $
--
--          $DateTime: 2017/03/22 10:16:16 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgevents")

function Definitions()

	Category = "Land_Scout_Area"
	IgnoreTarget = true
	TaskForce = 
	{
		{
			"MainForce",
			"Infantry | Air | LandHero = 1"
		}
	}

end

function MainForce_Thread()
	BlockOnCommand(MainForce.Produce_Force())
	QuickReinforce(PlayerObject, AITarget, MainForce)	

	-- Do it once without interruption
	MainForce.Set_As_Goal_System_Removable(false)
	Try_Ability(MainForce, "FORCE_CLOAK")
	BlockOnCommand(MainForce.Attack_Move(AITarget, MainForce.Get_Self_Threat_Max()))
	BlockOnCommand(MainForce.Explore_Area(AITarget), 10)
	MainForce.Set_Plan_Result(true)
--	MainForce.Set_As_Goal_System_Removable(true)

-- 	Removing this loop to give other plans a chance.  If the AI still wants to scout, the plan will be proposed again.
--	while true do
--		AITarget = FindTarget(MainForce, "Land_Area_Needs_Scouting", "Tactical_Location", 0.8, 1000.0)
		
--		if not TestValid(AITarget) then
--			DebugMessage("%s -- Unable to find a target for MainForce.", tostring(Script))
--			ScriptExit()
--		end
		
--		BlockOnCommand(MainForce.Move_To(AITarget, MainForce.Get_Self_Threat_Max()))
--		BlockOnCommand(MainForce.Explore_Area(AITarget), 10)
--		Sleep(1)
--	end
	
	ScriptExit()
end