local M = {
  buf = nil,
  win = nil
}

M.center = function(str)
  local width = vim.api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

M.open_window = function()
  M.buf = vim.api.nvim_create_buf(false, true)
  local border_buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(M.buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(M.buf, 'filetype', 'code_trace')

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
  M.win = vim.api.nvim_open_win(M.buf, true, opts)
  vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

  vim.api.nvim_win_set_option(M.win, 'cursorline', true) -- it highlight line with the cursor on it

  -- we can add title already here, because first line will never change
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { M.center("Code Tracing"), '', ''})
  vim.api.nvim_buf_add_highlight(M.buf, -1, 'CodeTraceHeader', 0, 0, -1)

  vim.api.nvim_win_set_cursor(M.win, {2, 0})
end

M.update_view = function(stops)
  local formatted_stops = {}
  local padding = ""

  for k,v in pairs(stops) do
    if (v == "return") then
      padding = padding:sub(1, -3)
    else
      table.insert(formatted_stops, padding .. v)
      padding = padding .. "  "
    end
  end

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, formatted_stops)
end

M.close_window = function()
  vim.api.nvim_win_close(M.win, true)
end

return M
