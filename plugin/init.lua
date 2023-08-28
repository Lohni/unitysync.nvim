require("unitysync.utils")

function UnitySync(metaExists)
    local cwd = GetProjectRootFromLsp()
    if not metaExists and cwd ~= nil then
        WriteLog("No matching .meta file found - Trying to sync Unity project: " .. cwd)
        WriteLog("Started UnitySync on directory: " .. cwd)
            
		local us = require("unitysync.config")
        vim.fn.jobstart(string.format(us.command, us.config.unityHome, cwd), {on_stdout = function(j,d,e) WriteLog(d) end,
                                on_stderr = function (j,d,e) WriteLog(d) end,
                                on_exit = function(j,d,e) AfterSync() end})
    elseif cwd == nil then
		WriteLog("No LSP root_dir defined")
	end
end

vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("UnitySync", {clear = true}),
    pattern = "*.cs",
    callback = function ()
        local metaExists = MetaFileExists()
        UnitySync(metaExists)
    end,
})

vim.api.nvim_create_user_command("UnitySync", function ()
        UnitySync(false)
    end,
{})
