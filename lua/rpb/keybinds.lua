local function noremap(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

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
noremap("n", "]q", ":cnext<CR>")
noremap("n", "[q", ":cprev<CR>")
-- telescope stuff
local pickers = require("telescope.builtin")
noremap("n", "<Leader>fr", pickers.resume)
noremap("n", "<Leader>fb", pickers.buffers)
noremap("n", "<Leader>ff", function()
	pickers.find_files({ hidden = true })
end)
noremap("n", "<Leader>fj", pickers.jumplist)
noremap("n", "<Leader>fc", pickers.command_history)
noremap("n", "<Leader>fh", pickers.help_tags)
noremap("n", "<Leader>fm", function()
	pickers.man_pages({ sections = { "ALL" } })
end)
noremap("n", "<Leader>fg", pickers.live_grep)
noremap("n", "<Leader>fs", pickers.lsp_workspace_symbols)
