-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/LandMode/DestroyTurbolaser.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/LandMode/DestroyTurbolaser.lua $
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

ScriptPoolCount = 16

function Definitions()
	
	Category = "Destroy_Turbolaser"
	TaskForce = {
	{
		"MainForce"						
		,"DenyHeroAttach"
		,"Infantry | Air | LandHero = 3,10"
		,"-Gallofree_HTT_Company"
		,"-HAV_Juggernaut_Company"
		,"-F9TZ_Cloaking_Transport_Company"	
		,"-AT_AA_Walker"	
	},
	{
		"GuardForce"
		,"EscortForce"
		,"Squad_Rebel_Trooper | Squad_Stormtrooper = 0,2"
	}
	}
	
	start_loc = nil
	
end

function MainForce_Thread()
	BlockOnCommand(MainForce.Produce_Force())
	
	QuickReinforce(PlayerObject, AITarget, MainForce, GuardForce)
	
	Try_Ability(MainForce, "FORCE_CLOAK")
	Try_Ability(MainForce, "STEALTH")

	-- Try to get under the min attack range, then attack
	BlockOnCommand(MainForce.Move_To(AITarget, MainForce.Get_Self_Threat_Sum()))
	BlockOnCommand(MainForce.Attack_Target(AITarget))	

	ScriptExit()
end

function GuardForce_Thread()
	BlockOnCommand(GuardForce.Produce_Force())

	QuickReinforce(PlayerObject, AITarget, GuardForce, MainForce)
	
	-- Give an initial order to put the escorts in a state that the Escort function expects
	GuardForce.Guard_Target(MainForce)

	-- Make sure these guys will shoot at structures autonomously
	GuardForce.Set_Targeting_Priorities("Infantry_Attack_Move")

	while true do
		Escort(GuardForce, MainForce)
	end
end

