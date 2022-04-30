local function noremap(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
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
-- telescope stuff
noremap("n", "<Leader>fr", ":Telescope resume<CR>")
noremap("n", "<Leader>fb", ":Telescope buffers<CR>")
noremap("n", "<Leader>ff", ":Telescope find_files<CR>")
noremap("n", "<Leader>fm", ":lua require('telescope.builtin').man_pages({ sections = {\"ALL\"} })<CR>")
noremap("n", "<Leader>fg", ":Telescope live_grep<CR>")
noremap("n", "<Leader>fs", ":Telescope lsp_document_symbols<CR>")
