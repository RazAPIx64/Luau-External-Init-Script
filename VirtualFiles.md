Kuick tutorial on the VFS API.

```lua
 --// VirtualFileSystem.SplitPath -- Splits a path using 1 argument, then returns its directories.
 --// Example:

 local Parts = VirtualFileSystem.SplitPath("User/Downloads/Exec/Workspace")

  for i, v in parts do
      print(i, v) --[[
        1 User
        2 Downloads
        3 Exec
        4 Workspace
    ]]
  end
```
