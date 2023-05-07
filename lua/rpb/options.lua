-- vim.cmd([[
-- 	augroup My_group
-- 	autocmd!
-- 	autocmd FileType c setlocal cindent
-- 	augroup END
-- ]])
local cmd = vim.cmd
local opt = vim.opt

cmd([[colorscheme gruvbox]])

local yank_au = vim.api.nvim_create_augroup("YankHighlight", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_au,
	callback = function()
		vim.highlight.on_yank()
	end,
})

local fo_au = vim.api.nvim_create_augroup("FormatOpts", {})
vim.api.nvim_create_autocmd("FileType", {
	group = fo_au,
	callback = function()
		opt.formatoptions = opt.formatoptions
			- "t" -- Auto-wrap text using textwidth
			- "c" -- Auto-wrap comments using textwidth
			- "o" -- O and o, don't continue comments
			- "r" -- Automatically insert the current comment leader after hitting <Enter> in Insert mode.
			+ "n" -- Indent past the formatlistpat, not underneath it. Makes a paragraph after a numbered list for example
			+ "j" -- Auto-remove comments if possible.
	end,
})

opt.modeline = false
opt.linebreak = true
opt.number = true
opt.relativenumber = true
opt.list = true

-- formatting stuff
opt.tabstop = 4
opt.shiftwidth = 0 -- use tabstop value
opt.softtabstop = -1 -- use shiftwidth

opt.spell = true
opt.termguicolors = true
opt.autoindent = true
opt.hlsearch = true
opt.showmatch = true -- show the matching part of the pair for [] {} and ()
opt.backspace = { "indent", "eol", "start" }
opt.wildmode = { "longest:full" } -- complete max common prefix, don't override unless told to do so
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.autoread = true -- auto reload a file if it changes
opt.ignorecase = true
opt.smartcase = true -- case insensitive search except one uses uppercase letters
opt.hidden = true -- modified buffers can be hidden
opt.wrapscan = true
opt.signcolumn = "yes" -- needed by git, else it constantly flashes in and out

opt.foldmethod = "expr"
opt.foldnestmax = 3
opt.foldenable = false
opt.foldlevel = 0
opt.fillchars = {
	fold = " ",
}
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
