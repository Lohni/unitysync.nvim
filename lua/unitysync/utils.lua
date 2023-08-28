function MetaFileExists()
    local file = string.gsub(vim.fn.expand("%:p"), "/", "\\")
    local path = string.gsub(file, "(.*)\\[^\\]*", "%1")
    local metaFile = string.sub(file, string.len(path) + 2, string.len(file))..".meta"
    local metaExists = false
    for filename in io.popen('dir "'..path..'" /b'):lines() do
        if filename == metaFile then metaExists = true; break end
    end
    return metaExists
end

function GetProjectRootFromLsp()
    for _,client in pairs(vim.lsp.get_active_clients()) do
        for _,v in pairs(client.config.filetypes) do
            if v == "cs" then
                return client.config.root_dir
            end
        end
    end
    return nil
end

function WriteLog(data)
    vim.cmd("echohl Comment")
    local us = require("unitysync.config")
    if us.config.logToFile then
        local logFile = io.open(us.config.logPath.."\\unitysync.log", "a+")
        if logFile ~= nil then
            logFile:write(os.date("[%Y-%m-%d %H:%M:%S]").." "..vim.inspect(data).."\n")
            logFile:close()
        end
    end

    if string.sub(vim.inspect(data), 0, 1) ~= '{' then
        vim.cmd("echom \"" .. data .. "\"")
    end
	
	vim.cmd("echohl None")
end

function AfterSync()
    local created = MetaFileExists()
    if created then
        WriteLog("Synced sucessfully")
        WriteLog("Reload LSP")

		vim.cmd("LspRestart")
        WriteLog("Waiting for LSP to restart")
        local hasRestarted = false
        while not hasRestarted do
            for _, client in pairs(vim.lsp.buf_get_clients()) do
                for _, type in pairs(client.config.filetypes) do
                    if type == "cs" then
						hasRestarted = true
                        break
                    end
                end
            end
        end

        WriteLog("Finished")
    end
end
