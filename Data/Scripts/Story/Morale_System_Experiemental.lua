Morale_System = {

    --[[
        The idea is that Each planet has its own morale, that is affected by individual events, global morale is then calculated from all of these, but also global events like losing a hero drops morale for all planets
        
        Events to warrant individual planet morale:
            Building Military/Civil/Political Structures
            If Neighboring planets are friendly or unfriendly
            Nearby Battles (Won/Lost)
            Global Events (Hero Lost/Enemy Hero Killed, Smaller morale gains/loses from Battles Won/Lost, Tasks(Build X Structure, Take X Planet, Save X Credits, Control X Planet, Propaganda Mission))
            
    ]]--

    Galactic_Morale_Value = 0,

    Planets = {},
}


