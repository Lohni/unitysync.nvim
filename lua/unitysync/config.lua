local M = {}

local logPath = os.getenv("XDG_DATA_HOME") 
if logPath == nil then logPath = vim.fn.stdpath("data") end

M.config = {
    logPath = logPath,
    logToFile = true,
    unityHome = "%UNITY_HOME%",
}
M.command = "cmd /c \"\"%s\\Editor\\Unity.exe\" -projectPath \"%s\" -batchmode -quit -nographics  -executeMethod \"UnityEditor.SyncVS.SyncSolution\""

M.setup = function(opts)
   M.config = vim.tbl_deep_extend("force", M.config, opts)
end

return M
