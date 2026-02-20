-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/LandMode/DestroyLandUnit.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/LandMode/DestroyLandUnit.lua $
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

ScriptPoolCount = 5

function Definitions()
	
	Category = "Destroy_Land_Unit"
	TaskForce = {
	{
		"MainForce"		
		,"DenyHeroAttach"
		,"Vehicle | Air = 1,8"
		,"LandHero = 0,1"
		,"-Gallofree_HTT_Company"
		,"-HAV_Juggernaut_Company"
		,"-F9TZ_Cloaking_Transport_Company"	
		,"-AT_AA_Walker"
	},
	{
		"GuardForce"
		,"EscortForce"
		,"Infantry = 0,4"
	}
	}

	start_loc = nil

end

function MainForce_Thread()
	BlockOnCommand(MainForce.Produce_Force())
	
	QuickReinforce(PlayerObject, AITarget, MainForce, GuardForce)
	
	--BlockOnCommand(MainForce.Move_To(MainForce.Get_Stage(), false)) -- true = wait for entire taskforce at intermediate zone points
	
	MainForce.Set_As_Goal_System_Removable(false)

	Set_Land_AI_Targeting_Priorities(MainForce)
	
	-- Assign appropriate targeting priorities here, once we get the ability to do this per unit type
	BlockOnCommand(MainForce.Attack_Move(AITarget, MainForce.Get_Self_Threat_Max()))		

	ScriptExit()
end

function GuardForce_Thread()
	BlockOnCommand(GuardForce.Produce_Force())
	QuickReinforce(PlayerObject, AITarget, GuardForce, MainForce)
	
	Set_Land_AI_Targeting_Priorities(GuardForce)
	-- Give an initial order to put the escorts in a state that the Escort function expects
	GuardForce.Guard_Target(MainForce)

	while true do
		Escort(GuardForce, MainForce)
	end
end
