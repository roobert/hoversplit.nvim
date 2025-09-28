local M = {}

local config = require("hoversplit.config")

M.hover_bufnr = nil ---@type integer|nil
M.hover_winid = nil ---@type integer|nil
M.orig_winid = nil ---@type integer|nil

function M.update_hover_content()
	if not (M.hover_winid and vim.api.nvim_win_is_valid(M.hover_winid)) then
		return
	end

	-- Check the current buffer and cursor position
	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_pos[1] - 1, cursor_pos[1], false)[1] or ""

	-- Validate the cursor position
	if cursor_pos[1] < 1 or cursor_pos[1] > line_count or cursor_pos[2] < 0 or cursor_pos[2] > #current_line then
		vim.notify("Invalid cursor position detected. Skipping hover content update.", vim.log.levels.WARN)
		return
	end

	vim.lsp.buf_request(bufnr, "textDocument/hover", vim.lsp.util.make_position_params(win, "utf-16"), function(err, result)
		if err or not (result and result.contents) then
			return
		end

		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		vim.api.nvim_set_option_value("modifiable", true, { buf = M.hover_bufnr })
		vim.api.nvim_buf_set_lines(M.hover_bufnr, 0, -1, false, lines)
		vim.api.nvim_set_option_value("modifiable", false, { buf = M.hover_bufnr })
	end)
end

---@param vertical boolean
---@param remain_focused boolean
function M.create_hover_split(vertical, remain_focused)
	if M.hover_winid and vim.api.nvim_win_is_valid(M.hover_winid) then
		M.close_hover_split()
		return
	end

	M.orig_winid = vim.api.nvim_get_current_win()
	M.hover_bufnr = vim.api.nvim_create_buf(false, true)
	-- vim.cmd(command)
    M.hover_winid = vim.api.nvim_open_win(M.hover_bufnr, remain_focused, {
        focusable = true,
        vertical = vertical,
        style = "minimal",
    })
	vim.api.nvim_win_set_buf(M.hover_winid, M.hover_bufnr)
	vim.api.nvim_buf_set_name(M.hover_bufnr, "hoversplit")
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.hover_bufnr })
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.hover_bufnr })
	vim.api.nvim_set_option_value("filetype", "markdown", { buf = M.hover_bufnr })
	vim.api.nvim_set_option_value("wrap", true, { win = M.hover_winid })
	vim.b[M.hover_bufnr].is_lsp_hover_split = true

	M.update_hover_content()
end

function M.split()
	M.create_hover_split(false, true) -- reversed the logic, now true
end

function M.vsplit()
	M.create_hover_split(true, true) -- reversed the logic, now true
end

function M.split_remain_focused()
	M.create_hover_split(false, false) -- reversed the logic, now false
end

function M.vsplit_remain_focused()
	M.create_hover_split(true, false) -- reversed the logic, now false
end

function M.close_hover_split()
	if M.hover_bufnr and vim.api.nvim_buf_is_valid(M.hover_bufnr) then
		vim.api.nvim_buf_delete(M.hover_bufnr, { force = true })
		M.hover_bufnr = nil
		M.hover_winid = nil
	end
end

function M.setup(options)
	options = options or {}

	for k, v in pairs(options) do
		config.options[k] = v
	end

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = vim.api.nvim_create_augroup("HoverSplit", { clear = true }),
		callback = function()
			M.update_hover_content()
		end,
	})
	-- vim.cmd([[ autocmd CursorMoved,CursorMovedI * lua require("hoversplit").update_hover_content() ]])

	if config.options.key_bindings_disabled then
		return
	end

	vim.keymap.set(
		"n",
		config.options.key_bindings["split_remain_focused"],
		M.split_remain_focused,
		{ noremap = true, silent = true, desc = 'HoverSplit split (Remain Focused)' }
	)

	vim.keymap.set(
		"n",
		config.options.key_bindings["vsplit_remain_focused"],
		M.vsplit_remain_focused,
		{ noremap = true, silent = true, desc = 'HoverSplit vsplit (Remain Focused)' }
	)

	vim.keymap.set(
		"n",
		config.options.key_bindings["split"],
		M.split,
		{ noremap = true, silent = true, desc = 'HoverSplit split' }
	)

	vim.keymap.set(
		"n",
		config.options.key_bindings["vsplit"],
		M.vsplit,
		{ noremap = true, silent = true, desc = 'HoverSplit vsplit' }
	)
end

return M
