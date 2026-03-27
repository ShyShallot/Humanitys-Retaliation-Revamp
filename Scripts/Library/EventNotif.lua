---@class Game_Scoring_Event_Manager

Game_Scoring_Event_Manager = {
    Events = {
        Galactic = {
            ["Unit_Destroyed"] = {
                Subscribers = {}
            },
            ["Production_Started"] = {
                Subscribers = {}
            },
            ["Production_Canceled"] = {
                Subscribers = {}
            },
            ["Production_End"] = {
                Subscribers = {}
            },
            ["Starbase_Level_Change"] = {
                Subscribers = {}
            },
            ["Planet_Ownership_Change"] = {
                Subscribers = {}
            },
            ["Hero_Neutralized"] = {
                Subscribers = {}
            },
            ["Planet_Attacked"] = {
                Subscribers = {}
            }
        }
    }
}


function Game_Scoring_Event_Manager:Trigger(Event_Name, args)

end