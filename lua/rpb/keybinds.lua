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

-- dap
local dap = require("dap")
noremap("n", "<F1>", dap.step_into)
noremap("n", "<F2>", dap.step_over)
noremap("n", "<F3>", dap.step_out)
noremap("n", "<F4>", dap.focus_frame)
noremap("n", "<F5>", dap.continue)
noremap("n", "<F6>", dap.terminate)
noremap("n", "<Leader>bb", dap.toggle_breakpoint)
-- Eval var under cursor
noremap("n", "<Leader>bk", function()
	require("dapui").eval(nil, { enter = true })
end)

vim.keymap.set('c', '%%', function()
	if vim.fn.getcmdtype() ~= ":"
	then
		return "%%"
	end
	return vim.fn.expand("%:p:h") .. "/"
end, {
	expr = true,
	desc = "automatically expand %% to folder of current file"
})

vim.keymap.set('i', '<cr>', function()
	return vim.fn.pumvisible() == 1 and '<C-y>' or '<cr>'
end, { expr = true })
