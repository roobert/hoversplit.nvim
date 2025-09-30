---@class HoverSplit.Config
local M = {}

---@class HoverSplit.Opts
M.options = {
	---@type 0|1|2|3
	conceallevel = 3,
	---@type boolean
	key_bindings_disabled = false,
	---@type { split: string, vsplit: string, split_remain_focused: string, vsplit_remain_focused: string }
	key_bindings = {
		split = "<leader>hS",
		vsplit = "<leader>hV",
		split_remain_focused = "<leader>hs",
		vsplit_remain_focused = "<leader>hv",
	},
}

return M
-- vim:ts=4:sts=4:noet:ai:si:sta:
