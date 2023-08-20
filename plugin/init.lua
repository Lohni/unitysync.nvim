local function metaFileExists()
    local file = string.gsub(vim.fn.expand("%:p"), "/", "\\")
    local path = string.gsub(file, "(.*)\\[^\\]*", "%1")
    local metaFile = string.sub(file, string.len(path) + 2, string.len(file))..".meta"
    local i, t, popen = 0, {}, io.popen
    local metaExists = false
    for filename in popen('dir "'..path..'" /b'):lines() do
        if filename == metaFile then metaExists = true; break end
    end
    return metaExists
end

local function getProjectRootFromLsp()
    for _,client in pairs(vim.lsp.get_active_clients()) do
        local isCsharpClient = false
        for _,v in pairs(client.config.filetypes) do
            if v == "cs" then
                isCsharpClient = true
                break
            end
        end

        if isCsharpClient then
           return client.config.root_dir
        end
    end
    return nil
end

function WriteLog(data)
    local nvimData= os.getenv("XDG_DATA_HOME")
    if nvimData== nil then nvimData= vim.fn.stdpath("data") end
    local logFile = io.open(nvimData.."\\unitysync.log", "a+")
    if logFile ~= nil then
        logFile:write(os.date("[%Y-%m-%d %H:%M:%S]").." "..vim.inspect(data).."\n")
        logFile:close()
    end
end

function AfterSync()
    local created = metaFileExists()
    if created then
        WriteLog("Synced sucessfully")
        WriteLog("Reload LSP")

        vim.lsp.stop_client(vim.lsp.get_active_clients())
        vim.cmd("LspRestart")
        
        local hasRestarted = false
        while not hasRestarted do
            for _, client in pairs(vim.lsp.get_active_clients()) do
                local isCsharpClient = false
                for _, type in pairs(client.config.filetypes) do
                    if type == "cs" then
                        isCsharpClient = true
                        break
                    end
                end

                if isCsharpClient and client.config.root_dir ~= nil then
                    hasRestarted = true
                    break
                else
                    WriteLog("Waiting for LSP to restart")
                end
            end
        end
        
        WriteLog("Finished")
    end
end

vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("UnitySync", {clear = true}),
    pattern = "*.cs",
    callback = function ()
        local metaExists = metaFileExists()
        local cwd = getProjectRootFromLsp()
        if not metaExists and cwd ~= nil then
            print("No matching .meta file found - Trying to sync Unity project: "..cwd)
            WriteLog("Started UnitySync on directory: "..cwd)
            local command = "cmd /c \"\"%UNITY_HOME%\\Editor\\Unity.exe\" -projectPath \"".. cwd .."\" -batchmode -quit -nographics  -executeMethod \"UnityEditor.SyncVS.SyncSolution\""
           
            vim.fn.jobstart(command, {on_stdout = function(j,d,e) WriteLog(d) end, 
                                    on_stderr = function (j,d,e) WriteLog(d) end,
                                    on_exit = function(j,d,e) AfterSync() end})
        end
    end,
})

vim.api.nvim_create_user_command("UnitySync", function ()
        local cwd = getProjectRootFromLsp()
        if cwd ~= nil then
            print("Force sync Unity project: "..cwd)
            WriteLog("Started UnitySync on directory: "..cwd)
            local command = "cmd /c \"\"%UNITY_HOME%\\Editor\\Unity.exe\" -projectPath \"".. cwd .."\" -batchmode -quit -nographics  -executeMethod \"UnityEditor.SyncVS.SyncSolution\""

            vim.fn.jobstart(command, {on_stdout = function(j,d,e) WriteLog(d) end,
                                    on_stderr = function (j,d,e) WriteLog(d) end,
                                    on_exit = function(j,d,e) AfterSync() end})
        end
    end,
{})

