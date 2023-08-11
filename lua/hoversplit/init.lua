local M = {}

local config = require("hoversplit.config")

local hover_bufnr = nil
local hover_winid = nil
local orig_winid = nil

local function update_hover_content()
	if not hover_winid or not vim.api.nvim_win_is_valid(hover_winid) then
		return
	end

	-- Check the current buffer and cursor position
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_pos[1] - 1, cursor_pos[1], false)[1] or ""

	-- Validate the cursor position
	if cursor_pos[1] < 1 or cursor_pos[1] > line_count or cursor_pos[2] < 0 or cursor_pos[2] > #current_line then
		print("Invalid cursor position detected. Skipping hover content update.")
		return
	end

	vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(err, result)
		if err or not result or not result.contents then
			return
		end

		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		vim.api.nvim_buf_set_option(hover_bufnr, "modifiable", true)
		vim.api.nvim_buf_set_lines(hover_bufnr, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(hover_bufnr, "modifiable", false)
	end)
end

local function create_hover_split(command, remain_focused)
	if hover_winid and vim.api.nvim_win_is_valid(hover_winid) then
		M.close_hover_split()
		return
	end

	orig_winid = vim.api.nvim_get_current_win()
	hover_bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_command(command)
	hover_winid = vim.api.nvim_get_current_win()
	vim.api.nvim_set_current_buf(hover_bufnr)
	vim.api.nvim_buf_set_name(hover_bufnr, "hoversplit")
	vim.api.nvim_buf_set_option(hover_bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(hover_bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(hover_bufnr, "filetype", "markdown")
	vim.api.nvim_buf_set_var(hover_bufnr, "is_lsp_hover_split", true)

	update_hover_content()

	if remain_focused == false then -- added the comparison to false
		vim.api.nvim_set_current_win(orig_winid)
	end
end

M.split = function()
	create_hover_split("sp", true) -- reversed the logic, now true
end

M.vsplit = function()
	create_hover_split("vsp", true) -- reversed the logic, now true
end

M.split_remain_focused = function()
	create_hover_split("sp", false) -- reversed the logic, now false
end

M.vsplit_remain_focused = function()
	create_hover_split("vsp", false) -- reversed the logic, now false
end

M.close_hover_split = function()
	if hover_bufnr and vim.api.nvim_buf_is_valid(hover_bufnr) then
		vim.api.nvim_buf_delete(hover_bufnr, { force = true })
		hover_bufnr = nil
		hover_winid = nil
	end
end

M.update_hover_content = update_hover_content

function M.setup(options)
	if options == nil then
		options = {}
	end

	for k, v in pairs(options) do
		config.options[k] = v
	end

	vim.cmd([[ autocmd CursorMoved,CursorMovedI * lua require('hoversplit').update_hover_content() ]])

	if config.options.key_bindings_disabled then
		return
	end

	vim.api.nvim_set_keymap(
		"n",
		config.options.key_bindings["split"],
		":lua require('hoversplit').split_remain_focused()<CR>",
		{ noremap = true, silent = true }
	)

	vim.api.nvim_set_keymap(
		"n",
		config.options.key_bindings["vsplit"],
		":lua require('hoversplit').vsplit_remain_focused()<CR>",
		{ noremap = true, silent = true }
	)
end

return M
