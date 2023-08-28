# What is this trying to solve
When working on a Unity-Project with Neovim and omnisharp, the LSP is not recognizing any Unity related classes/functions in a newly created file.
# How does it work
After writing a new `*.cs` file (no according .meta file exists), following command gets executed to re-sync the solution:
```batch
"unityHome\Editor\Unity.exe" -projectPath "project_root" -batchmode -quit -nographics  -executeMethod "UnityEditor.SyncVS.SyncSolution"
```
After that, the LSP will be restarted.
As an alternative, you can use `:UnitySync` to force-sync the current solution.
# How to use
> - Currently only working on Windows
> - Only tested with [omnisharp](https://github.com/OmniSharp/omnisharp-roslyn) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
> - The project root passed to the syncing command is read from the LSP-Clients `config.root_dir` property

By default, the path to the Unity installation is fetched from the UNITY_HOME environment variable, but this is customizable.

Adjust config:
```lua
require("unitysync.config").setup({
    logToFile = ... --Enable/Disable logging (default true)
    logPath = ... --Path to the logging folder (default XDG_DATA_HOME (if set), otherwise vim.fn.stdpath("data"))
    unityHome = ... --Path to the Unity installation folder (default %UNITY_HOME%)
})
```

- #### [Install with Packer](https://github.com/wbthomason/packer.nvim):
```vim
use ('Lohni/unitysync.nvim')
```
