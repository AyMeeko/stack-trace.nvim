local utils = require("stack-trace.windows")
local M = {
  stops = {}
}

M.setup = function(opts)
  opts = opts or {}
end

local function _find_parent_node_with_type(node, t)
  while node do
    if node:type() == t then
      break
    end
    node = node:parent()
  end

  if node then
    return vim.treesitter.get_node_text(node:child(1), 0)
  end
  return ""
end

local function _pre_fill_parents(node)
  local func = _find_parent_node_with_type(node, "function_definition")
  local class = _find_parent_node_with_type(node, "class_definition")

  if class then
    table.insert(M.stops, class)
  end

  if func then
    table.insert(M.stops, func)
  end
end

M.add_stop = function()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()

  if next(M.stops) == nil then
    _pre_fill_parents(node)
  end

  local prev_sibling = node:prev_sibling()
  local entry
  if (prev_sibling) then
    local prev_sib_text = vim.treesitter.get_node_text(prev_sibling, 0)
    if (prev_sib_text == ".") then
      local parent_node = node:parent()
      entry = vim.treesitter.get_node_text(parent_node, 0)
    end
  end
  if (entry == nil) then
    entry = vim.treesitter.get_node_text(node, 0)
  end
  table.insert(M.stops, entry:match("[^\n]*"))
end

M.return_stop = function()
  table.insert(M.stops, "stacktracereturnstacktrace")
end

M.clear_stops = function()
  M.stops = {}
end

M.show_stops = function()
  utils.open_window()
  M.set_mappings()
  utils.update_view(M.stops)
end

M.print = function(s)
  vim.cmd("echo '" .. tostring(s):match("[^\n]*") .. "'")
end

M.close_window = utils.close_window

M.set_mappings = function()
  vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>lua require('stack-trace').close_window()<CR>", {
    nowait = true, noremap = true, silent = true
  })

  vim.api.nvim_buf_set_keymap(0, "n", "w", ":w ", {nowait = true, noremap = true})
end

return M
