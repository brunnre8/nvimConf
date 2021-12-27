local M = {}

local function noremap(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local has_only_whitespace_before_cursor = function()
	local col = vim.fn.col(".") - 1
	local sub = vim.fn.getline("."):sub(1, col)
	if col == 0 or sub:match("%s") then
		return true
	else
		return false
	end
end

-- local snippy = require("snippy")
-- local cmp = require("cmp")
-- local t = require("rpb.globals").t

-- function _G.tab_complete()
-- 	if cmp.visible() then
-- 		cmp.select_next_item()
-- 		return ""
-- 		-- elseif snippy.can_expand() then
-- 		-- 	snippy.expand()
-- 		-- 	return ""
-- 		-- elseif snippy.can_jump(1) then
-- 		-- 	snippy.next()
-- 		-- 	return ""
-- 	elseif has_only_whitespace_before_cursor() then
-- 		return t("<Tab>")
-- 	else
-- 		cmp.complete()
-- 		return ""
-- 	end
-- end

-- function _G.s_tab_complete()
-- 	if false then
-- 		if cmp.visible() then
-- 			cmp.select_prev_item()
-- 			return ""
-- 		elseif snippy.can_jump(-1) then
-- 			snippy.previous()
-- 			return ""
-- 		elseif has_only_whitespace_before_cursor() then
-- 			return t("<S-Tab>")
-- 		else
-- 			cmp.complete()
-- 			return ""
-- 		end
-- 	end
-- 	return t("<S-Tab>")
-- end

vim.g.mapleader = ","

-- INSERT --
noremap("i", "jk", "<Esc>")

-- Terminal --
noremap("t", "<Esc>", [[<C-\><C-n>]])

-- NORMAL --
noremap("n", "<C-n>", ":NERDTreeToggle<CR>")
noremap("n", "<Leader>a", "<C-a>") -- numbers increment / decrement
noremap("n", "<Leader>x", "<C-x>")
noremap("n", "<Leader>c", ":ccl <bar> lcl<CR>")
noremap("n", "<Leader>nn", ":nohl<CR>")
noremap("n", "<Leader>q", ":q<CR>")
noremap("n", "<Leader>z", ":tab split<CR>")
noremap("n", "<Leader>m", ":silent make<CR>")
noremap("n", "<Leader>gs", ":Gtabedit :<CR>")
-- telescope stuff
noremap("n", "<Leader>fb", ":Telescope buffers<CR>")
noremap("n", "<Leader>ff", ":Telescope find_files<CR>")
noremap("n", "<Leader>fm", ":Telescope man_pages<CR>")
noremap("n", "<Leader>fg", ":Telescope live_grep<CR>")
noremap("n", "<Leader>fs", ":Telescope lsp_document_symbols<CR>")
M.noremap = noremap
return M
