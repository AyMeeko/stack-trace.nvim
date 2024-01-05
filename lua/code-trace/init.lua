--[=====[
-- expand('%p') == foo.py

# file.method: line-contents
FooHandler.post: return foo_service.a()
    foo_service.a: return bar_service.b()
        bar_service.b: return baz_service.c()
            baz_service.c: return 0

--]=====]

local utils = require('code-trace.windows')
local M = {
  stops = {}
}

M.setup = function(opts)
  opts = opts or {}
end

M.add_stop_one = function()
  --local fp = vim.fn.expand("%p")
  local path = vim.fn["nvim_treesitter#statusline"](opts)
  local line = vim.fn.getline("."):gsub("^%s*(.-)%s*$", "%1")
  local entry = ""
  if (path == "") then
    entry = line
  elseif (path:find(line, 1, true)) then
    entry = path
  else
    entry = path .. " -> " .. line
  end
  table.insert(M.stops, entry)
end

M.add_stop = function(opts)
  opts = opts or {}
  if (opts.return_stop == true) then
    table.insert(M.stops, "return")
  else
    -- vim.treesitter.get_node_text(require("nvim-treesitter.ts_utils").get_node_at_cursor():parent(), 0)
    -- vim.treesitter.get_node_text(require("nvim-treesitter.ts_utils").get_node_at_cursor(), 0)
    -- require("nvim-treesitter.ts_utils").get_node_at_cursor():type()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local node = ts_utils.get_node_at_cursor()
    local entry = vim.treesitter.get_node_text(node, 0)
    table.insert(M.stops, entry)
    --vim.cmd("echo '" .. entry .. "'")
  end
end

M.clear_stops = function()
  M.stops = {}
end

M.show_stops = function()
  utils.open_window()
  utils.update_view(M.stops)
end

M.print = function(s)
  vim.cmd("echo '" .. tostring(s) .. "'")
end

M.debug_stop = function()
  -- vim.treesitter.get_node_text(require("nvim-treesitter.ts_utils").get_node_at_cursor(), 0)
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()

  local prev_sibling = node:prev_sibling()
  local node_text
  if (prev_sibling) then
    local prev_sib_text = vim.treesitter.get_node_text(prev_sibling, 0)
    if (prev_sib_text == ".") then
      local parent_node = node:parent()
      node_text = vim.treesitter.get_node_text(parent_node, 0):match("[^\n]*")
    end
  end
  if (node_text == nil) then
    node_text = vim.treesitter.get_node_text(node, 0)
  end

  M.print("node_text: " .. node_text .. ", node type: " .. node:type())
end

return M
