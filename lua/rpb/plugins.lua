---@diagnostic disable: missing-fields
-- auto fetch the package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"brunnre8/gruvbox.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			-- load the colorscheme here
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
	"tpope/vim-repeat",
	"tpope/vim-surround",
	"tpope/vim-fugitive",
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
	},
	"nvim-telescope/telescope-ui-select.nvim",

	"scrooloose/nerdtree",

	-- Highlight, edit, and navigate code using a fast incremental parsing library
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- can't cope
		branch = "main",
		build = ':TSUpdate'
	},
	-- Additional textobjects for treesitter
	-- TODO: fancy textobjects
	-- "nvim-treesitter/nvim-treesitter-textobjects",
	"neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
	"ray-x/lsp_signature.nvim",
	{
		"lewis6991/gitsigns.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	{
		"jose-elias-alvarez/nvim-lsp-ts-utils",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
	},

	-- "dcampos/nvim-snippy",
	"stevearc/conform.nvim",

	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-emoji",
	"hrsh7th/cmp-buffer",
	-- "dcampos/cmp-snippy",
	"windwp/nvim-autopairs",
	"windwp/nvim-ts-autotag",

	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
	},

	'nvim-lualine/lualine.nvim',
	'nvim-tree/nvim-web-devicons', -- telescope and lualine need it
	'arkav/lualine-lsp-progress',

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"brunnre8/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
			{ "rcarriga/nvim-dap-ui", dependencies = "nvim-neotest/nvim-nio", },
		},
	},


	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
		}
	}
})

local gitsigns = require("gitsigns")
gitsigns.setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "|" },
		topdelete = { text = "|" },
		changedelete = { text = "|" },
	},
	on_attach = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gitsigns.nav_hunk("next")
			end)
			return "<Ignore>"
		end, { expr = true })

		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gitsigns.nav_hunk("prev")
			end)
			return "<Ignore>"
		end, { expr = true })
	end,
})

local ts_parsers = {
	"bash",
	"c",
	"comment",
	"cpp",
	"css",
	"elixir",
	"go",
	"gomod",
	"gowork",
	"graphql",
	"html",
	"http",
	"java",
	"javascript",
	"json",
	"json5",
	"latex",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"ruby",
	"rust",
	"scss",
	"toml",
	"typescript",
	"vim",
	"vimdoc",
	"vue",
	"yaml",

}

require('nvim-treesitter').install(ts_parsers):wait(300000) -- wait max. 5 minutes
local ts_au = vim.api.nvim_create_augroup("rpb.treesitter", {})
vim.api.nvim_create_autocmd('FileType', {
	group = ts_au,
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
		if not vim.tbl_contains(ts_parsers, lang) then
			return
		end
		vim.treesitter.start(ev.buf)
		vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
})

-- https://github.com/nvim-telescope/telescope.nvim/issues/559
-- essentially the pickers don't work with folds if the selection is done from insert mode
local function stopinsert(callback)
	return function(prompt_bufnr)
		vim.cmd.stopinsert()
		vim.schedule(function()
			callback(prompt_bufnr)
		end)
	end
end

local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<CR>"] = stopinsert(actions.select_default),
				["<C-x>"] = stopinsert(actions.select_horizontal),
				["<C-v>"] = stopinsert(actions.select_vertical),
				["<C-t>"] = stopinsert(actions.select_tab),
			},
		},
		-- don't put anything in ignore that you ever want to see in any picker... LSP included
		-- so adding node_modules etc is a terrible idea
		file_ignore_patterns = {
			"^%.git/",
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- even more opts
			}),

			-- pseudo code / specification for writing custom displays, like the one
			-- for "codeactions"
			-- specific_opts = {
			--   [kind] = {
			--     make_indexed = function(items) -> indexed_items, width,
			--     make_displayer = function(widths) -> displayer
			--     make_display = function(displayer) -> function(e)
			--     make_ordinal = function(e) -> string
			--   },
			--   -- for example to disable the custom builtin "codeactions" display
			--      do the following
			--   codeactions = false,
			-- }
		},
	},
})
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")

-- local snippy = require("snippy")
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		-- { name = "snippy" },
		{ name = "path" },
		{ name = "nvim_lua" },
		{ name = "emoji" },
		-- { name =  "buffer"}, -- can be slow
	},
	mapping = {
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-g>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		-- ["<CR>"] = cmp.mapping.confirm({
		-- 	behavior = cmp.ConfirmBehavior.Insert,
		-- 	select = false,
		-- }),
	},
	preselect = cmp.PreselectMode.None,
})
-- If you want insert `(` after select function or method item
-- cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())


-- snippy.setup({
-- 	mappings = {
-- 		is = {
-- 			["<Tab>"] = "expand_or_advance",
-- 			["<S-Tab>"] = "previous",
-- 		},
-- 		-- nx = {
-- 		-- 	["<leader>x"] = "cut_text",
-- 		-- },
-- 	},
-- })

require("nvim-autopairs").setup({
	disable_in_macro = true,
})
require("nvim-ts-autotag").setup()

local function diff_source()
	local status = vim.b.gitsigns_status_dict
	if status then
		return {
			added = status.added,
			modified = status.changed,
			removed = status.removed
		}
	end
end

local lualine_gruvbox = require('lualine.themes.gruvbox')

require('lualine').setup({
	options = {
		-- icons_enabled = true,
		-- component_separators = { left = '', right = '' },
		-- section_separators = { left = '', right = '' },
		disabled_filetypes = {
			-- statusline = {},
			-- winbar = {},
		},
		-- ignore_focus = {},
		-- always_divide_middle = true,
		-- globalstatus = false,
		-- refresh = {
		-- 	statusline = 1000,
		-- 	tabline = 1000,
		-- 	winbar = 1000,
		-- }
		theme = lualine_gruvbox,
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { { 'b:gitsigns_head', icon = '' }, { 'diff', source = diff_source }, 'diagnostics' },
		lualine_c = {
			{ 'filename', path = 1 },
			{
				'lsp_progress',
				-- TODO: need to escape the message here
				-- display_components = { 'lsp_client_name', { 'title', 'percentage', 'message' } },
				display_components = { 'lsp_client_name', { 'title', 'percentage' } },
				timer = { progress_enddelay = 1000, spinner = 1000, lsp_client_name_enddelay = 0 },
			},
		},
		lualine_x = { 'encoding', 'fileformat', 'filetype', },
		lualine_y = { 'progress' },
		lualine_z = { 'location' }
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{ 'filename', path = 1 },
		},
		lualine_x = { 'location' },
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = { "quickfix", "nerdtree", "lazy", "fugitive", "man" }
}
)

-- require("nvim-highlight-colors").setup({
-- 	render = "first_column", -- 'background' or 'foreground' or 'first_column'
-- 	enable_named_colors = true,
-- 	enable_tailwind = false,
-- })

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- Use a sub-list to run only the first available formatter
		javascript = { "prettier" },
		typescript = { "prettier" },
		vue = { "prettier" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("rpb.conform", {}),
	pattern = { "*.js", "*.ts", "*.vue" },
	callback = function(ev)
		require("conform").format({
			bufnr = ev.buf,
		})
	end,
})

vim.g.NERDTreeShowHidden = 1

local dap = require("dap")
local dapui = require("dapui")

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
	-- dapui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
	-- dapui.close()
end

require("dapui").setup({
	controls = {
		element = "repl",
		enabled = false,
	}
})
require("dap-go").setup()
---@diagnostic disable-next-line: missing-parameter
require("nvim-dap-virtual-text").setup()

-- dap.set_log_level('TRACE')
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}
dap.configurations.c = {
	{
		name = "Launch",
		type = "gdb",
		request = "launch",
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = "${workspaceFolder}",
		stopAtBeginningOfMainSubprogram = true,
	},
	-- {
	-- 	name = "Select and attach to process",
	-- 	type = "gdb",
	-- 	request = "attach",
	-- 	program = function()
	-- 		return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
	-- 	end,
	-- 	pid = function()
	-- 		local name = vim.fn.input('Executable name (filter): ')
	-- 		return require("dap.utils").pick_process({ filter = name })
	-- 	end,
	-- 	cwd = '${workspaceFolder}'
	-- },
	{
		name = 'Attach to gdbserver :1234',
		type = 'gdb',
		request = 'attach',
		target = 'localhost:1234',
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = '${workspaceFolder}'
	},
}

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = '', numhl = '' })
