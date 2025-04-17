local cmd = vim.cmd
local opt = vim.opt

local au_group_opts = vim.api.nvim_create_augroup("rpb_options", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = au_group_opts,
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = au_group_opts,
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

vim.api.nvim_create_autocmd("FileType", {
	group = au_group_opts,
	pattern = "man",
	callback = function()
		vim.opt_local.spell = false
	end,
})

-- we want to navigate backwards, not forwards usually
vim.api.nvim_create_autocmd("TabClosed", {
	group = au_group_opts,
	callback = function(ev)
		local nr = vim.fn.tabpagenr("$") -- last
		if nr < tonumber(ev.match) then
			return                 -- last tab was closed, don't want to mess with that
		end
		-- else navigate backwards
		vim.cmd.tabprev()
	end,
})

opt.modeline = false
opt.linebreak = true
opt.number = true
opt.relativenumber = true
opt.list = true

-- make the current line highlighted
opt.cursorlineopt = "number"
opt.cursorline = true

-- formatting stuff
opt.tabstop = 4
opt.shiftwidth = 0   -- use tabstop value
opt.softtabstop = -1 -- use shiftwidth

opt.spell = true
opt.termguicolors = true
opt.autoindent = true
opt.hlsearch = true
opt.showmatch = true              -- show the matching part of the pair for [] {} and ()
opt.backspace = { "indent", "eol", "start" }
opt.wildmode = { "longest:full" } -- complete max common prefix, don't override unless told to do so
opt.completeopt = { "menuone", "noselect" }
opt.autoread = true               -- auto reload a file if it changes
opt.ignorecase = true
opt.smartcase = true              -- case insensitive search except one uses uppercase letters
opt.hidden = true                 -- modified buffers can be hidden
opt.wrapscan = true
opt.signcolumn = "yes"            -- needed by git, else it constantly flashes in and out
opt.jumpoptions = { "stack" }     -- make it so that the jumplist is a stack rather than the dynamic thing
opt.title = true                  -- set the window title according to the open file

opt.foldmethod = "expr"
opt.foldnestmax = 3
opt.foldenable = false
opt.foldtext = ""
opt.foldlevel = 0
opt.fillchars = {
	fold = " ",
}
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.lsp.inlay_hint.enable()
