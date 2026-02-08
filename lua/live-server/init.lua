---@diagnostic disable: undefined-global
local M = {}
_G.live_servers = _G.live_servers or {}

local function notify(msg, level)
  vim.notify(msg, level, { title = "Live Server" })
end

function M.get_lualine_status()
  if #_G.live_servers == 0 then
    return "󰖟 Offline"
  end
  local status_parts = {}
  for _, s in ipairs(_G.live_servers) do
    table.insert(status_parts, string.format("%s:%s", s.port, s.file))
  end
  return " " .. table.concat(status_parts, " | ")
end

function M.stop_all()
  for _, s in ipairs(_G.live_servers) do
    vim.fn.jobstop(s.id)
  end
  _G.live_servers = {}
  vim.fn.system("pkill -f live-server")
  notify("All servers stopped", vim.log.levels.WARN)
end

function M.stop_specific()
  if #_G.live_servers == 0 then
    notify("No active servers", vim.log.levels.INFO)
    return
  end

  local options = {}
  for _, s in ipairs(_G.live_servers) do
    table.insert(options, string.format("Port: %s | File: %s", s.port, s.file))
  end
  table.insert(options, "🛑 STOP ALL SERVERS")

  vim.ui.select(options, { prompt = "Select server to stop:" }, function(choice, idx)
    if not choice then return end
    if choice == "🛑 STOP ALL SERVERS" then
      M.stop_all()
    else
      local server = _G.live_servers[idx]
      vim.fn.jobstop(server.id)
      table.remove(_G.live_servers, idx)
      notify("Stopped server on port " .. server.port, vim.log.levels.WARN)
    end
  end)
end

function M.start(file, port)
  local target_file = file or vim.fn.expand("%:p")
  local target_port = port or tostring(8080 + #_G.live_servers)

  for _, s in ipairs(_G.live_servers) do
    if s.port == target_port then
      notify("Port " .. target_port .. " is busy", vim.log.levels.ERROR)
      return
    end
  end

  local job_id = vim.fn.jobstart({ "live-server", target_file, "--port=" .. target_port, "--quiet" }, {
    detach = true,
    on_exit = function()
      for i, s in ipairs(_G.live_servers) do
        if s.id == job_id then
          table.remove(_G.live_servers, i)
          break
        end
      end
    end,
  })

  if job_id > 0 then
    table.insert(_G.live_servers, {
      id = job_id,
      port = target_port,
      file = vim.fn.fnamemodify(target_file, ":t")
    })
    notify(string.format("Started %s on port %s", vim.fn.fnamemodify(target_file, ":t"), target_port),
      vim.log.levels.INFO)
  end
end

function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_create_user_command("LiveServer", function() M.menu() end, {})

  local key = opts.key or "<leader>ls"
  vim.keymap.set("n", key, function() M.menu() end, { silent = true, desc = "Live Server Manager" })

  if opts.lualine ~= false then
    local status_ok, lualine = pcall(require, "lualine")
    if status_ok then
      local config = lualine.get_config()
      table.insert(config.sections.lualine_x, {
        function() return M.get_lualine_status() end,
        color = function()
          local active = #_G.live_servers > 0
          return { fg = active and "#98be65" or "#5c6370" }
        end,
      })
      lualine.setup(config)
    end
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function() M.stop_all() end
  })
end

function M.menu()
  local title = #_G.live_servers > 0 and ("Active: " .. #_G.live_servers) or "No Servers"
  local options = {
    "🚀 Start Current File",
    "📂 Pick File & Start",
    "🛑 Manage/Stop Servers",
    "💥 Kill Everything"
  }

  vim.ui.select(options, { prompt = "Live Server Panel | " .. title }, function(choice)
    if choice == options[1] then
      M.start()
    elseif choice == options[2] then
      local files = vim.fn.globpath(vim.fn.getcwd(), "**/*.html", false, true)
      if #files == 0 then
        notify("No HTML files found", vim.log.levels.ERROR)
        return
      end
      vim.ui.select(files, { prompt = "Pick Entry Point:" }, function(f) if f then M.start(f) end end)
    elseif choice == options[3] then
      M.stop_specific()
    elseif choice == options[4] then
      M.stop_all()
    end
  end)
end

return M
