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

--// VirtualFileSystem.CheckFile -- Checks if a file exists

local FS = {
    User = {
        Downloads = {
            Exec = {
                Workspace = {}
            }
        }
    }
}

--// This is subject to change with adding new stuff to the VFS API.

local split = VirtualFileSystem.SplitPath("User/Downloads/Exec/Workspace")
print(VirtualFileSystem.CheckFile(split, filesys))-->true
```
