--// Roblox Service Globals
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
--// Support Globals
local RazAPI = { Threads = {}, Connections = {}, WhitelistedTypes = {}, OldFunctions = { type = type, typeof = typeof }, Junk = { ClientActive = false }, CClosures = {} }
local VirtualFileSystem = {} -- xeno reference wtfff

RazAPI.WhitelistObject = function(Object, Type)
    RazAPI.WhitelistedTypes[Object] = Type 
end

-- Future file system used in tables.
VirtualFileSystem.SplitPath = function(path)
    assert(type(path) == "string", `invalid argument #1 to 'SplitPath', expected string got {type(path)}`);

    local SplitPartTable = {}

    for Slash in path:gmatch("[^/]+") do
        table.insert(SplitPartTable, Slash)
    end
end

VirtualFileSystem.CheckFile = function(Split, FileSystemT)
    for i = 1, #Split - 1 do
        local FoFiName = Split[i]
        FileSystemT = FileSystemT[i]

        if type(FoFiName) ~= "table" then
            return false 
        end
    end
end

VirtualFileSystem.PairFile = function(FileSystemT, Split)
    return type(FileSystemT[Split[#Split]]) == "string"
end

RazAPI.TypeCheck = function(Object, Type, FunctionName, Param)
    assert(typeof(Object) == Type, `invalid argument #{Param} for {FunctionName}, expected {Type}, got {typeof(Object)}`)
end

RazAPI.CreateThread = function(TaskName, ThreadCall)
    RazAPI.Threads[TaskName] = ThreadCall
end

RazAPI.StartConnection = function(Object, ConnectionMethod, Connection, ConnectionName)
    RazAPI.Connections[ConnectionName] = Object[ConnectionMethod]:Connect(Connection)
end

RazAPI.DisconnectConnection = function(ConnectionName)
    RazAPI.Connections[ConnectionName]:Disconnect()
end

RazAPI.GetFunctionProxy = function(Function, Compare)
    local FunctionEnv = getfenv(debug.info(Function, "f", 3));
    local Success, Result = pcall(function()
        return FunctionEnv["script"]
    end)

    if not Success then
        return 0
    else
        if Compare then
            return FunctionEnv["script"] == script 
        else
            return true
        end
    end
end

--// Registry
local Registry = {}
--// fake registry for now
RazAPI.CreateThread("Registry", function()
    while task.wait() do
        for i,v in game:GetDescendants() do
            if table.find(Registry, v) then
                continue
            end

            table.insert(Registry, v)
        end

        for _, k in getfenv(0) do
            if table.find(Registry, k) then
                continue
            end

            table.insert(Registry, v)
        end
    end

    game.DescendantRemoving:Connect(function(object)
        table.insert(Registry, object)
    end)
end)
--// Environment
local Environment = {}
local WindowActive

setmetatable(Environment, {
    __index = function(_, i)
        return getfenv(0)[i]
    end,

    __newindex = function(_, i, v)
        getfenv(0)[i] = v
    end
})

RazAPI.StartConnection(UserInputService, "WindowFocused", function()
    RazAPI.Junk.ClientActive = true
end, "WindowFocusedConnection")

RazAPI.StartConnection(UserInputService, "WindowFocusReleased", function()
    RazAPI.Junk.ClientActive = false
end, "WindowFocusReleasedConnection")

Environment.typeof = function(object)
    if RazAPI.OldFunctions.type(RazAPI.WhitelistedTypes[object]) == "string" then
        return RazAPI.WhitelistedTypes[object]
    end

    return RazAPI.OldFunctions.typeof(object)
end

Environment.type = function(object)
    if RazAPI.OldFunctions.type(RazAPI.WhitelistedTypes[object]) == "string" then
        return RazAPI.WhitelistedTypes[object]
    end

    return RazAPI.OldFunctions.type(object)
end

--// Init
Environment.identifyexecutor = function()
    return "Raz's Init Script", "v1.0.0"
end

Environment.getexecutorname = function()
    return "Raz's Init Script"
end

Environment.cache = {}

Environment.cache.invalidate = function(instance)
    RazAPI.TypeCheck(instance, "Instance", "invalidate", 1)
    Registry[instance] = 0

    instance.Parent = nil
end
Environment.cache.iscached = function(instance)
    RazAPI.TypeCheck(instance, "Instance", "iscached", 1)
    return Registry[instance] ~= 0
end

Environment.cache.replace = function(instance, instance2)
    RazAPI.TypeCheck(instance, "Instance", "replace", 1)
    RazAPI.TypeCheck(instance2, "Instance", "replace", 2)

    table.insert(Registry, instance)
    table.insert(Registry, instance2)

    Registry[instance] = Registry[instance2]
end

Environment.cloneref = function(object)
    RazAPI.TypeCheck(object, "Instance", "cloneref", 1)

    local InstanceProxy = newproxy(true)
    local InstanceMt = getmetatable(InstanceProxy)

    InstanceMt.__index = function(_, idx)
        return object[idx]
    end

    InstanceMt.__newindex = function(_, idx, new)
        object[idx] = new
    end

    RazAPI.WhitelistObject(InstanceProxy, "Instance");
    return InstanceProxy
end

Environment.compareinstances = function(instance, instancetocompare)
    RazAPI.TypeCheck(instance, "Instance", "compareinstances", 1)
    RazAPI.TypeCheck(instancetocompare, "Instance", "compareinstances", 2)

    return instance.Changed == instancetocompare.Changed
end 

Environment.checkcaller = function()
    local Tracked = debug.info(1, "f")

    if Tracked then
        return RazAPI.GetFunctionProxy(Tracked, true)
    end

    return false
end

Environment.clonefunction = function(Function)
    RazAPI.TypeCheck(Function, "function", "clonefunction", 1)

    clone = function() return Function(...) end end
    setfenv(clone, getfenv(Function))
    return clone -- i would modify it's debug info but i don't wanna spoof too much shit
end

Environment.islclosure = function(Function)
    RazAPI.TypeCheck(Function, "function", "islclosure", 1)
    return debug.info(Function, "s") ~= "[C]"
end

Environment.iscclosure = function(Function)
    RazAPI.TypeCheck(Function, "function", "iscclosure", 1)
    return debug.info(Function, "s") == "[C]"
end

Environment.isexecutorclosure = function(Function)
    RazAPI.TypeCheck(Function, "function", "isexecutorclosure", 1)

    if RazAPI.CClosures[Function] or RazAPI.GetFunctionProxy(Function) == true then
        return true
    end

    return false;
end

Environment.isrbxactive = function()
    return RazAPI.Junk.ClientActive
end

--// Metatables
Environment.isreadonly = function(x)
    return table.isfrozen(x)
end
