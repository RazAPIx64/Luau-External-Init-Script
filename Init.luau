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

RazAPI.AddToRegistry = function(Object, CheckIfExists)
    if CheckIfExists == nil then
        CheckIfExists = 0 -- I don't bother.
    end

    for i,v in Object do
        if CheckIfExists == 0 then
            if table.find(Registry, v) then
                continue 
            end

            table.insert(Registry, v)
        elseif CheckIfExists == 1 then
            table.insert(Registry, v)
        end
    end
end
--// fake registry for now
RazAPI.CreateThread("Registry", function()
    while task.wait() do
        RazAPI.AddToRegistry(game:GetDescendants(), 0)
        RazAPI.AddToRegistry(getfenv(0), 0)
    end

    RazAPI.StartConnection(game, "DescendantAdded", function(x)
       table.insert(Registry, x)
    end, "I.C(instances_collector)")

    RazAPI.StartConnection(game, "DescendantRemoving", function(x)
       table.insert(Registry, x)
    end, "N.I.C(nil_instances_collector)")
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

--[[
    Song: Lift, Jump, Exhale
    Artist: Lucy Bedroque
    Album: Amy

    Like, "Lucy, you a motherfuckin' meanie"
    But you hurt, give a lil' nigga Kleenex
]]

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

--// Closure

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

Environment.newcclosure = function(Function)
    RazAPI.TypeCheck(Function, "function", "newcclosure", 1)
    RazAPI.CClosures[Function] = true

    return Function
end

Environment.isrbxactive = function()
    return RazAPI.Junk.ClientActive
end

--// Instances

Environment.gethui = function()
    local success, result = pcall(function()
        return Environment.cloneref(game:GetService("CoreGui"))
    end)

    if not success then
        local Proxy = newproxy(true)
        local Metatable = getmetatable(Proxy)

        local Folder = Instance.new("Folder", Players.LocalPlayer.PlayerGui);
        Folder.Name = "BasePlayerGui"

        Metatable.__index = function(_, v)
            if v == "ClassName" then
                return "BasePlayerGui"
            end

            return Folder[v]
        end

        Metatable.__newindex = function(_, i, v)
            if i == "Parent" then
                error("Cannot set the parent of a BasePlayerGui")
            end

            Folder[i] = v
        end

        RazAPI.WhitelistObject(Proxy, "Instance")
        return Metatable
    end

    return result
end

Environment.getinstances = function()
    local Instances = {}

    for i,v in Registry do
        if type(v) == "Instance" then
            table.insert(Instances, v)
        end
    end

    return Instances
end

Environment.getnilinstances = function()
    local Instances = {}

    for i,v in Registry do
        if type(v) == "Instance" and v.Parent == nil then
            table.insert(Instances, v)
        end
    end

    return Instances
end

--// Debug

Environment.debug = {}

Environment.debug.getinfo = function(FunctionOrLevel)
    assert(type(FunctionOrLevel) == "function" or type(FunctionOrLevel) == "number", "Invalid argument #1 to 'info', expected function or number, got " .. type(FunctionOrLevel))

    --[[
        Field	Type	Description
        source	string	The name of the chunk that created the function.
        short_src	string	A "printable" version of source to be used in error messages.
        func	function	The function itself.
        what	string	The string "Lua" if the function is a Luau function, or "C" if it is a C function.
        currentline	number	The current line where the given function is executing. When no line information is available, currentline is set to -1.
        name	string	The name of the function. If it cannot find a name, then name is a blank string.
        nups	number	The number of upvalues in the function.
        numparams	number	The number of parameters in the function (always 0 for C functions).
        is_vararg	number	Whether the function has a variadic argument (1 if it does, 0 if it does not).
    ]]

    local Result = {}
    local ShortSource = debug.info(FunctionOrLevel, "s")

    Result.name = debug.info(FunctionOrLevel, "n")
    Result.func = debug.info(FunctionOrLevel, "f")
    Result.what = if ShortSource == '[C]' then 'C' elseif ShortSource == 'Lua' then 'Lua' else 'Lua';
    Result.numparams = if debug.info(FunctionOrLevel, "s") == "[C]" then 0 else 1
    Result.is_vararg = select(1, debug.info(FunctionOrLevel, 'a'))
    Result.currentline = debug.info(FunctionOrLevel, "l")
    Result.short_src = ShortSource
    Result.source = `={ShortSource}`
    Result.nups = 0

    return Result
end

--// Metatables
Environment.isreadonly = function(x)
    return table.isfrozen(x)
end
