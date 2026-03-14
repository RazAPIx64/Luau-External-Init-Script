--// Roblox Service Globals
local RbxAnalyticsService do
	RbxAnalyticsService = pcall(function()
		return game:GetService("RbxAnalyticsService")
	end)
end

local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
--// Support Globals
local RazAPI = { Threads = {}, Connections = {}, WhitelistedTypes = {}, OldFunctions = { type = type, typeof = typeof, debug = debug }, Junk = { ClientActive = false }, CClosures = {}, ScriptableProperties = {}, WhitelistedScriptableProp = {}, MetatableReg = setmetatable({}, { __mode = "k" }), EngineSettings = UserSettings() }
local VirtualFileSystem = {} -- xeno reference wtfff

RazAPI.EncodeJSON = function(x)
	return HttpService:JSONEncode(x)
end

RazAPI.WhitelistObject = function(Object, Type)
	RazAPI.WhitelistedTypes[Object] = Type 
end

RazAPI.GetObjExistence = function(Object, Property)
	return (pcall(Object, Property))
end

RazAPI.IterateAndFindType = function(Type, Data)
	local Res

	for i,v in Data do
		if typeof(v) == Type then
			Res = v
		end
	end

	return Res
end

-- Future file system used in tables.
VirtualFileSystem.SplitPath = function(path)
	assert(type(path) == "string", `invalid argument #1 to 'SplitPath', expected string got {type(path)}`);

	local SplitPartTable = {}

	for Slash in path:gmatch("[^/]+") do
		table.insert(SplitPartTable, Slash)
	end

	return SplitPartTable
end

VirtualFileSystem.CheckFile = function(Split, FileSystemT)
	for i = 1, #Split - 1 do
		local FoFiName = Split[i]
		FileSystemT = FileSystemT[FoFiName]

		if type(FileSystemT) ~= "table" then
			return false
		end
	end

	return true
end

VirtualFileSystem.PairFile = function(FileSystemT, Split)
	return type(FileSystemT[Split[#Split]]) == "string"
end

RazAPI.TypeCheck = function(Object, Type, FunctionName, Param)
	assert(typeof(Object) == Type, `invalid argument #{Param} for {FunctionName}, expected {Type}, got {typeof(Object)}`)
end

RazAPI.CreateMockInstance = function(Object, Lock, GetMt)
	RazAPI.TypeCheck(Object, "Instance", "CreateMockInstance", 1)

	local InstanceProxy = newproxy(true)
	local InstanceMt = getmetatable(InstanceProxy)

	InstanceMt.__index = function(_, idx)
		return Object[idx]
	end

	InstanceMt.__newindex = function(_, idx, new)
		Object[idx] = new
	end

	RazAPI.MetatableReg[InstanceProxy] = InstanceMt

	if Lock == true then
		InstanceMt.__metatable = `No.`
	end

	RazAPI.WhitelistObject(InstanceProxy, "Instance");
	if GetMt == true then return InstanceMt else return InstanceProxy end
end

RazAPI.GetUnlockedMockInstance = function(Object)
	RazAPI.TypeCheck(Object, "Instance", "G.U.M.I", 1)

	local ProxyMt = RazAPI.MetatableReg[Object]

	if ProxyMt then
		ProxyMt.__metatable = nil
		return RazAPI.MetatableReg[Object]
	end
end

RazAPI.CaptureInstanceClassAndWriteToTable = function(ClassName, ProvidedTable, TableToWrite, ReturnFirst)
	RazAPI.TypeCheck(ProvidedTable, "table", "CaptureInstanceClass", 2)

	if typeof(ClassName) == "string" then
		ClassName = { [ClassName] = true }
	end

	for _, Object in ProvidedTable do
		if typeof(Object) == "Instance" and ClassName[Object.ClassName] then
			if ReturnFirst == 0 then
				return Object
			end

			table.insert(TableToWrite, Object)
		end
	end
end

RazAPI.FindAndRemoveObject = function(List, Predicate)
	for i = #List, 1, -1 do
		if Predicate(List[i]) then
			table.remove(List, i)
		end
	end
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
		RazAPI.AddToRegistry(getfenv(debug.info(0, 'f')), 0)
	end

	RazAPI.StartConnection(game, "DescendantAdded", function(x)
		table.insert(Registry, x)
	end, "I.C(instances_collector)")

	RazAPI.StartConnection(game, "DescendantRemoving", function(x)
		table.insert(Registry, x)
	end, "N.I.C(nil_instances_collector)")
end)
--// Environment
local Environment = {
	Operia = {} -- Library based on player info, and funny shit.
}
local WindowActive

setmetatable(Environment, {
	__index = function(_, i)
		return getfenv(debug.info(2, 'f'))[i]
	end,

	__newindex = function(_, i, v)
		getfenv(debug.info(2, 'f'))[i] = v
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
		if RazAPI.WhitelistedTypes[object] == "Instance" then
			return "userdata"--//persist between typeof
		else
			return RazAPI.WhitelistedTypes[object]
		end
	end

	return RazAPI.OldFunctions.type(object)
end

--// Init
Environment.identifyexecutor = function()
	return "Raz's Init Script", "v1.1.5"
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
	return RazAPI.CreateMockInstance(object, true, false)
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

	clone = function(...) return Function(...) end
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

		InstanceMt.__metamethod = `No.`

		RazAPI.WhitelistObject(Proxy, "Instance")
		return Metatable
	end

	return result
end

Environment.getinstances = function()
	local Instances = {}

	for i,v in Registry do
		if typeof(v) == "Instance" then
			table.insert(Instances, v)
		end
	end

	return Instances
end

Environment.getnilinstances = function()
	local Instances = {}

	for i,v in Registry do
		if typeof(v) == "Instance" and v.Parent == nil then
			table.insert(Instances, v)
		end
	end

	return Instances
end

-- fake, you should remake this using HttpService:RequestInternal.
Environment.request = function(Options)
	RazAPI.TypeCheck(Options, "table", "request", 1) -- bad.

	return {
		StatusCode = 200,
		Body = RazAPI.EncodeJSON({["user-agent"] = "RazSploit/v1"})
	}
end

--// Script Lib

Environment.getscripts = function()
	local Scripts = {}

	RazAPI.CaptureInstanceClassAndWriteToTable( { LocalScript = true, ModuleScript = true, Script = true }, Registry, Scripts )

	return Scripts
end

Environment.getrunningscripts = function()
	local Scripts = {}

	RazAPI.CaptureInstanceClassAndWriteToTable( { LocalScript = true, ModuleScript = true, Script = true }, Registry, Scripts ) --// c++ formatting woa
	RazAPI.FindAndRemoveObject( Scripts, function(Object) return Object.Enabled == false end )

	return Scripts
end
--// Debug

Environment.debug = {
	info = RazAPI.OldFunctions.debug.info,
	getmemorycategory = RazAPI.OldFunctions.debug.getmemorycategory,
	setmemorycategory = RazAPI.OldFunctions.debug.setmemorycategory,
	traceback = RazAPI.OldFunctions.debug.traceback,
	resetmemorycategory = RazAPI.OldFunctions.debug.resetmemorycategory,
	profileend = RazAPI.OldFunctions.debug.profileend,
	profilebegin = RazAPI.OldFunctions.debug.profilebegin,
	dumpcodesize = RazAPI.OldFunctions.debug.dumpcodesize
}

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

--// similar dbg function?

Environment.getthread = function()
	return coroutine.running()
end

Environment.getgenv = function()
	return Environment
end

--// Scriptable

--// god save us all
Environment.setscriptable = function(Object, Property, Bool)
	RazAPI.TypeCheck(Object, "Instance", "setscriptable", 1)
	RazAPI.TypeCheck(Property, "string", "setscriptable", 2)
	RazAPI.TypeCheck(Bool, "boolean", "setscriptable", 3)

	RazAPI.ScriptableProperties[Object] = RazAPI.ScriptableProperties[Object] or {}

	local StoredPreviousProp = RazAPI.ScriptableProperties[Object][Property] or false
	local VariableVirt

	RazAPI.ScriptableProperties[Object][Property] = Bool
	RazAPI.WhitelistedScriptableProp[Object] = Bool

	if RazAPI.GetObjExistence(Object, Property) == false then
		local Proxy = RazAPI.CreateMockInstance(Object, true, false)
		local StoredMt = RazAPI.GetUnlockedMockInstance(Proxy)

		StoredMt.__index = function(_, x)
			if x == Property then
				if not RazAPI.ScriptableProperties[Object] then
					error(`{Property} is not a valid member of {Object.ClassName} "{Object.Name}"`)
				else
					x = VariableVirt
				end
			end

			return Object[x]
		end

		StoredMt.__newindex = function(_, x, v)
			if x == Property then
				if not RazAPI.ScriptableProperties[Object] then
					error(`{Property} is not a valid member of {Object.ClassName} "{Object.Name}"`)
				else
					VariableVirt = v
				end
			end

			return Object[x]
		end
	end

	return StoredPreviousProp
end

Environment.isscriptable = function(Object, Property)
	RazAPI.TypeCheck(Object, "Instance", "isscriptable", 1)
	RazAPI.TypeCheck(Property, "string", "isscriptable", 2)

	if RazAPI.WhitelistedScriptableProp[Object] == true then
		return true
	end

	return RazAPI.GetObjExistence(Object, Property)
end

--// Metatables

--[[ (..IGNORE..)

    --// "we will use debug.info for this, but i don't really care if it doesn't return a string" 
    Environment.getnamecallmethod = function()
        local L1 = RazAPI.IterateAndFindType("string", debug.getinfo(1))
        local L2 = RazAPI.IterateAndFindType("string", debug.getinfo(2))
        local L3 = RazAPI.IterateAndFindType("string", debug.getinfo(1))

        if #L1 > #L2 and #L1 > #L3 then return L1
        elseif #L2> #L1 and #L2 > #L3 then return L2
        elseif #L3 > L1 and #L3 > #L2 then return L3

        -- SON I'M GONNA CRY
        end
    end
]]

Environment.isreadonly = function(x)
	return table.isfrozen(x)
end

--// Misc

Environment.setfpscap = function(FrameRate)
	RazAPI.TypeCheck(FrameRate, "number", "setfpscap", 1)
	RazAPI.EngineSettings.GameSettings.FramerateCap = FrameRate

	--// i love this method
end

Environment.getfpscap = function()
	return tonumber(RazAPI.EngineSettings.GameSettings.FramerateCap)
end

--// Unreferenced shit

Environment.gethwid = function()
	local Success, Result = xpcall(function()
		return RbxAnalyticsService:GetClientId()
	end, function()
		return HttpService:GenerateGUID(false)
	end)

	return Result
end
