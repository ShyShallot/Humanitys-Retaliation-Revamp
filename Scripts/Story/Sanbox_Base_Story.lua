---@class BaseStory
local BaseStory = {
    Modules = {},
    Plot_File = nil,
}

function BaseStory:Initialize(Custom_Modules, Manual_Start)
    --DebugMessage("%s -- Initialize: Starting BaseStory Initialization", tostring(Script))
    if Custom_Modules then
        --DebugMessage("%s -- Initialize: Registering Custom Modules", tostring(Script))
        for _, Module in pairs(Custom_Modules) do
            self:Register_Module(Module.Name, Module.File, Module.Dependency, Module.Update, Module.Starts_GC, Module.Needs_Plot_File)
        end
    end

    self.Plot_File = "HaloFiles\\Campaigns\\StoryMissions\\Common_Events.xml"
    --DebugMessage("%s -- Initialize: Plot File Set to %s", tostring(Script), tostring(self.Plot_File))

    self:Load_Default_Modules()

    PG_Story_Mode_Init()

    if not Manual_Start then
        self:Start_GC()
    end
end

function BaseStory:Register_Module(Module_Name, Module_File_Name, Module_Load_Dependency, Has_Update, Starts_GC, Needs_Plot_File)
    --DebugMessage("%s -- Register_Module: Attempting to register module %s", tostring(Script), tostring(Module_Name))
    if type(Module_Name) ~= "string" then
        --DebugMessage("%s -- Register_Module: Module_Name is not string, aborting", tostring(Script))
        return
    end

    if type(Module_File_Name) ~= "string" then
        --DebugMessage("%s -- Register_Module: Module_File_Name is not string, aborting", tostring(Script))
        return
    end

    if type(Module_Load_Dependency) ~= "table" then
        Module_Load_Dependency = {
            Optional = true,
            Name = "None"
        }
    end

    if Has_Update ~= true then
        Has_Update = false
    end

    if Starts_GC ~= true then
        Starts_GC = false
    end

    if Needs_Plot_File ~= true then
        Needs_Plot_File = false
    end

    --DebugMessage("%s -- Register_Module: Requiring file %s", tostring(Script), tostring(Module_File_Name))
    local Module_Reference = require(Module_File_Name)

    if Module_Reference == nil then
        --DebugMessage("%s -- Register_Module: Module_Reference is nil, aborting", tostring(Script))
        return
    end

    --DebugMessage("%s -- Registering Module: %s", tostring(Script), tostring(Module_Name))

    ---@class Module_Entry
    self.Modules[Module_Name] = {
        Init = {
            Status = false,
        },
        Module_Reference = Module_Reference,
        Load_Dependency = {
            Optional = Module_Load_Dependency.Optional,
            Name = Module_Load_Dependency.Name
        },
        Has_Update = Has_Update,
        Starts_GC = Starts_GC,
        Needs_Plot_File = Needs_Plot_File
    }
end

function BaseStory:Unregister_Module(Module_Name)
    if type(Module_Name) ~= "string" then
        return
    end

    if self.Modules[Module_Name] == nil then
        return
    end

    self.Modules[Module_Name] = nil
end

function BaseStory:Init_Module(Module_Name)
    if type(Module_Name) ~= "string" then
        --DebugMessage("%s -- Init_Module: Module_Name is not string", tostring(Script))
        return false
    end

    --DebugMessage("%s -- Init_Module: Attempting to initialize module %s", tostring(Script), tostring(Module_Name))
    ---@type Module_Entry
    local Module_Entry = self.Modules[Module_Name]

    if Module_Entry == nil then
        --DebugMessage("%s -- Init_Module: Module_Entry not found for %s", tostring(Script), tostring(Module_Name))
        return false
    end

    if Module_Entry.Init.Status then
        --DebugMessage("%s -- Init_Module: Module %s already initialized", tostring(Script), tostring(Module_Name))
        return false
    end

    if Module_Entry.Load_Dependency then
        --DebugMessage("%s -- Init_Module: Checking dependency %s for module %s", tostring(Script), tostring(Module_Entry.Load_Dependency.Name), tostring(Module_Name))
        ---@type Module_Entry
        local Dependency = self.Modules[Module_Entry.Load_Dependency.Name]

        if Dependency == nil and not Module_Entry.Load_Dependency.Optional then
            --DebugMessage("%s -- Init_Module: Required dependency %s not found", tostring(Script), tostring(Module_Entry.Load_Dependency.Name))
            return false
        end

        if Dependency ~= nil then
            if not Dependency.Init.Status then
                --DebugMessage("%s -- Init_Module: Dependency %s not yet initialized", tostring(Script), tostring(Module_Entry.Load_Dependency.Name))
                return false
            end
            --DebugMessage("%s -- Init_Module: Dependency %s is satisfied", tostring(Script), tostring(Module_Entry.Load_Dependency.Name))
        end
    
    end

    --DebugMessage("%s -- Init_Module: Calling Init method for %s", tostring(Script), tostring(Module_Name))

    local Init_Function = Module_Entry.Module_Reference.Init

    if Init_Function == nil then
        Init_Function = Module_Entry.Module_Reference.Start
    end

    --DebugMessage("%s -- Init_Module: Init Method Found: %s", tostring(Script), tostring(Init_Function))

    if Init_Function ~= nil then
        if Module_Entry.Needs_Plot_File then
            --DebugMessage("%s -- Init_Module: Passing Plot_File to Init", tostring(Script))
            pcall(Init_Function, Module_Entry.Module_Reference, self.Plot_File)
        else
            pcall(Init_Function, Module_Entry.Module_Reference)
        end

        Module_Entry.Init.Status = true

        --DebugMessage("%s -- Init_Module: Module %s successfully initialized", tostring(Script), tostring(Module_Name))

        if Module_Entry.Starts_GC then
            --DebugMessage("%s -- Init_Module: Triggering Spawning_Done event for %s", tostring(Script), tostring(Module_Name))
            Story_Event("Spawning_Done")
        end

        return true
    end

end

function BaseStory:Call_Module_Function(Module_Name, Function_Name, Values)

    if type(Module_Name) ~= "string" then
        --DebugMessage("%s -- Call_Module_Function: Module_Name is not string", tostring(Script))
        return nil
    end
    if type(Function_Name) ~= "string" then
        --DebugMessage("%s -- Call_Module_Function: Function_Name is not string", tostring(Script))
        return nil
    end

    local Module_Entry = self.Modules[Module_Name]

    if Module_Entry == nil then
        --DebugMessage("%s -- Call_Module_Function: Module '%s' not registered", tostring(Script), tostring(Module_Name))
        return nil
    end

    local Module_Ref = Module_Entry.Module_Reference
    if Module_Ref == nil then
        --DebugMessage("%s -- Call_Module_Function: Module_Reference for '%s' is nil", tostring(Script), tostring(Module_Name))
        return nil
    end

    local Module_Function = Module_Ref[Function_Name]

    if type(Module_Function) ~= "function" then
        return
    end

    local args = {}
    if type(Values) == "table" then
       args = Values 
    elseif Values ~= nil then
        args[1] = Values
    end

    PrintTable(args)

    local results = { pcall(Module_Function, Module_Ref, unpack(args)) }

    local success = table.remove(results, 1)

    if not success then
        DebugMessage("%s -- Module Function Call %s Failed", tostring(Script), tostring(Function_Name))

        return nil
    end

    return unpack(results)
end

function BaseStory:Update_Module(Module_Name)
    if type(Module_Name) ~= "string" then
        --DebugMessage("%s -- Update_Module: Module_Name is not string", tostring(Script))
        return
    end

    ---@type Module_Entry
    local Module_Entry = self.Modules[Module_Name]

    if Module_Entry == nil then
        --DebugMessage("%s -- Update_Module: Module_Entry not found for %s", tostring(Script), tostring(Module_Name))
        return
    end

    if not Module_Entry.Has_Update then
        return
    end

    if not Module_Entry.Init.Status then
        --DebugMessage("%s -- Update_Module: Module %s not yet initialized", tostring(Script), tostring(Module_Name))
        return
    end

    if Module_Entry.Module_Reference.Update ~= nil then
        --DebugMessage("%s -- Update_Module: Updating module %s", tostring(Script), tostring(Module_Name))
        pcall(Module_Entry.Module_Reference.Update, Module_Entry.Module_Reference)
        --Module_Entry.Module_Reference:Update()
        return
    end

    if Module_Entry.Module_Reference.Check ~= nil then
        --DebugMessage("%s -- Update_Module: Checking module %s", tostring(Script), tostring(Module_Name))
        pcall(Module_Entry.Module_Reference.Check, Module_Entry.Module_Reference)
        return
    end
end

function BaseStory:Register_Library(Library_File)
    --DebugMessage("%s -- Register_Library: Attempting to register library %s", tostring(Script), tostring(Library_File))
    if type(Library_File) == "string" then
        --DebugMessage("%s -- Register_Library: Requiring library file %s", tostring(Script), tostring(Library_File))
        require(Library_File)
    else
        --DebugMessage("%s -- Register_Library: Library_File is not string", tostring(Script))
    end
end

function BaseStory:CreateStoryModeEvents(customEvents)
    local Default_Events = {
        Update = BaseStory.Update,
        Structures_Super_Filter = BaseStory.Set_Structures_Super_Filter,
        Capitals_Filter = BaseStory.Set_Capitals_Filter,
        Frigate_Corvette_Filter = BaseStory.Set_Frigate_Corvette_Filter,
        Fighter_Filter = BaseStory.Set_Fighter_Filter,
        Flush = BaseStory.Flush,
    }

    if customEvents then
        for Event, Function in pairs(customEvents) do
            Default_Events[Event] = Function
        end
    end

    return Default_Events
end

function BaseStory:Load_Default_Modules()
    --DebugMessage("%s -- Load_Default_Modules: Starting to load default modules", tostring(Script))
    self:Register_Module("Starting_Units", "Starting_Units", {Optional = true, Name = "Random_Planet_Starter"}, false, true) 
    self:Register_Module("Filter_System", "Unit_Filters", {Optional = false, Name="Starting_Units"}, true, false, true)
    self:Register_Module("Tech_Theft", "Tech_Stealing", {Optional = false, Name="Starting_Units"}, true, false, true)
    self:Register_Module("Great_Schism", "Great_Schism", {Optional = false, Name="Starting_Units"}, true)
    self:Register_Module("Far_Isle_Campaign", "Far_Isle_Campaign", {Optional = false, Name="Starting_Units"}, true)
    --DebugMessage("%s -- Load_Default_Modules: Finished loading default modules", tostring(Script))
end

function BaseStory:Start_GC()
    --DebugMessage("%s -- Start_GC: Beginning Galactic Conquest initialization cycle", tostring(Script))

    local Made_Progress = true
    local Cycle_Count = 0

    while Made_Progress do
        Made_Progress = false
        Cycle_Count = Cycle_Count + 1
        --DebugMessage("%s -- Start_GC: Galactic Conquest Cycle %d", tostring(Script), Cycle_Count)

        for Name, Entry in pairs(BaseStory.Modules) do
            if BaseStory.Init_Module(BaseStory, Name) then
                Made_Progress = true
                Sleep(1)
            end
        end
    end

    --DebugMessage("%s -- Start_GC: Galactic Conquest initialization complete after %d cycles", tostring(Script), Cycle_Count)
    Set_Next_State("Flush")
end

function BaseStory.Update(message)

    if message ~= OnUpdate then
        return
    end

    --DebugMessage("%s -- Update: Processing module updates", tostring(Script))
    for Module_Name, _ in pairs(BaseStory.Modules) do
        BaseStory:Update_Module(Module_Name)
    end
end

function BaseStory.Flush(message)
    if message == OnEnter then
        Set_Next_State("Update")
    end
end

function BaseStory.Set_Structures_Super_Filter(message)
    if message ~= OnEnter then return end
    --DebugMessage("%s -- Set_Structures_Super_Filter: Setting structures super filter", tostring(Script))
    ---@type Module_Entry
    local Filter_Module = BaseStory.Modules["Filter_System"]
    if Filter_Module ~= nil then
        Filter_Module.Module_Reference:Set_Filter(Filter_Module.Module_Reference.Structure_Super_Filter)
    else
        --DebugMessage("%s -- Set_Structures_Super_Filter: Filter_System not found", tostring(Script))
    end
    Set_Next_State("Flush")
end

function BaseStory.Set_Capitals_Filter(message)
    if message ~= OnEnter then return end
    --DebugMessage("%s -- Set_Capitals_Filter: Setting capitals filter", tostring(Script))
    ---@type Module_Entry
    local Filter_Module = BaseStory.Modules["Filter_System"]
    if Filter_Module ~= nil then
        Filter_Module.Module_Reference:Set_Filter(Filter_Module.Module_Reference.Capitals_Filter)
    else
        --DebugMessage("%s -- Set_Capitals_Filter: Filter_System not found", tostring(Script))
    end
    Set_Next_State("Flush")
end

function BaseStory.Set_Frigate_Corvette_Filter(message)
    if message ~= OnEnter then return end
    --DebugMessage("%s -- Set_Frigate_Corvette_Filter: Setting frigate/corvette filter", tostring(Script))
    ---@type Module_Entry
    local Filter_Module = BaseStory.Modules["Filter_System"]
    if Filter_Module ~= nil then
        Filter_Module.Module_Reference:Set_Filter(Filter_Module.Module_Reference.Frigate_Corvette_Filter)
    else
        --DebugMessage("%s -- Set_Frigate_Corvette_Filter: Filter_System not found", tostring(Script))
    end
    Set_Next_State("Flush")
end

function BaseStory.Set_Fighter_Filter(message)
    if message ~= OnEnter then return end
    --DebugMessage("%s -- Set_Fighter_Filter: Setting fighter filter", tostring(Script))
    ---@type Module_Entry
    local Filter_Module = BaseStory.Modules["Filter_System"]
    if Filter_Module ~= nil then
        Filter_Module.Module_Reference:Set_Filter(Filter_Module.Module_Reference.Fighter_Filter)
    else
        --DebugMessage("%s -- Set_Fighter_Filter: Filter_System not found", tostring(Script))
    end
    Set_Next_State("Flush")
end

return BaseStory