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

--// I'll do the rest later bra
```
