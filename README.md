# Luau External Init Script
Optimized environment for Luau External Executors that focuses on functionality and prioritizes realism.

Quick doc on how the RazAPI table works:

```lua
--// RazAPI.StartConnection -- Starts a connection allowing you to disconnect it whenever so it gets stored inside of RazAPI.Connections
--// Example:

RazAPI.StartConnection(Part, "Touched", function()
    print("Touched part")
end, "TouchedConn")

--// RazAPI.DisconnectConnection -- Disconnects a connection by searching for it in RazAPI.Connections
--// Example (Since "TouchedConn" is a Connection in the RazAPI table, we'll use it here.)

RazAPI.DisconnectConnection("TouchedConn")

--// RazAPI.WhitelistObject -- Changes an objects type for type, and typeof.
--// Example:

local Folder = Instance.new("Folder", game:FindFirstChildOfClass("ReplicatedStorage")) -- we'll use this instance as an example

local Proxy = newproxy(true)
local ProxyMt = getmetatable(Proxy)

ProxyMt.__index = function(_, x)
    --// for example we could spoof "ClassName"
   if x == "ClassName" then
       return "LuaSourceContainer"
   end

   return Folder[x]
end

ProxyMt.__newindex = function(_, x, y)
    Folder[x] = y
end

RazAPI.WhitelistObject(Proxy, "Instance")

print(typeof(Proxy)) == "Instance" --> true
print(type(Proxy) == "userdata") --> true

--// RazAPI.TypeCheck -- Checks a type using 4 arguments [Object,Type,FunctionName,Param]
--// Example (using a function we created)

local function NUMBERONLY(x)
    RazAPI.TypeCheck(x, "number", "NUMBERONLY", 1)
    return x
end

NUMBERONLY(true)
--// Roblox Dev Console: Invalid argument #1 for NUMBERONLY, expected number, got boolean

--// RazAPI.CreateThread -- Creates a thread in RazAPI.Threads allowing you to cancel it without a global using 2 arguments [ThreadName,Callback]
--// Example:

RazAPI.CreateThread("SpeedEvery1Sec", function()
   while task.wait(1) do
       local WalkSpeed = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed -- IntValue
       WalkSpeed = WalkSpeed + 1
   end
end)

--// RazAPI.GetFunctionProxy -- Checks if the function being passed exists in the init's LocalScript using 2 globals [Function,Compare]
--// Example:

--// using a function that was created in the env

function ok(x)
    return x
end

print(RazAPI.GetFunctionProxy(ok, true)) --> true (Function exists in the same script/environment)

--// using a function we grabbed from the Animate LocalScript
--// [we do not have this function, it's just an example]

local ScriptAnimEnv = getsenv(game:GetService("Players").LocalPlayer.Character.Animate)
print(RazAPI.GetFunctionProxy(ScriptAnimEnv["onRunning"], true)) --> false

--// RazAPI.AddToRegistry -- adds an object to the registry that acts like the Luau Registry
--// Example:

local x = {}

RazAPI.AddToRegistry(x)
print(Registry["x"]) --> table: 0x...
```
