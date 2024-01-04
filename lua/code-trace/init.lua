--[=====[
-- expand('%p') == foo.py

# file.method: line-contents
FooHandler.post: return foo_service.a()
    foo_service.a: return bar_service.b()
        bar_service.b: return baz_service.c()
            baz_service.c: return 0

--]=====]

local buf, win

local function center(str)
  local width = vim.api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

local function open_window()
  buf = vim.api.nvim_create_buf(false, true)
  local border_buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'code_trace')

  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local border_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1
  }

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
  local middle_line = '║' .. string.rep(' ', win_width) .. '║'
  for i=1, win_height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
  vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

  local border_win = vim.api.nvim_open_win(border_buf, true, border_opts)
  win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

  vim.api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it

  -- we can add title already here, because first line will never change
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { center("Code Tracing"), '', ''})
  vim.api.nvim_buf_add_highlight(buf, -1, 'CodeTraceHeader', 0, 0, -1)
end

local function update_view()
  local formatted_stops = {}
  local padding = ""

  for k,v in pairs(stops) do
    formatted_stops[k] = padding .. stops[k]
    padding = padding .. "    "
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_stops)
end

local M = {}

stops = {}

function M.setup(opts)
  opts = opts or {}
end

function M.show_stops()
  position = 0
  open_window()
  vim.api.nvim_win_set_cursor(win, {2, 0})
  update_view()

  --local pickers = require("telescope.pickers")
  --local finders = require("telescope.finders")
  --local config = require("telescope.config")

  --pickers.new(opts, {
    --prompt_title = "Tracing Code",
    --finder = finders.new_table({
      --results = stops,
    --}),
    --sorter = config.values.file_sorter(ops),
  --}):find()
end

function M.add_stop()
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
  table.insert(stops, entry)
end

function M.clear_stops()
  stops = {}
end

return M
