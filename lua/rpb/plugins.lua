require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	--use "wbthomason/lsp-status.nvim"
	use({ "brunnre8/gruvbox.nvim", requires = { "rktjmp/lush.nvim" } })

	use("tpope/vim-repeat")
	use("tpope/vim-surround")
	use("tpope/vim-commentary")
	use("tpope/vim-fugitive")

	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },
		},
	})
	use({ "nvim-telescope/telescope-ui-select.nvim" })

	use("scrooloose/nerdtree")

	-- Highlight, edit, and navigate code using a fast incremental parsing library
	use("nvim-treesitter/nvim-treesitter")
	use("nvim-treesitter/playground")
	-- Additional textobjects for treesitter
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("neovim/nvim-lspconfig") -- Collection of configurations for built-in LSP client
	use("ray-x/lsp_signature.nvim")
	use({
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
	})

	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
	})
	use({
		"jose-elias-alvarez/nvim-lsp-ts-utils",
		requires = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
	})

	use({ "dcampos/nvim-snippy" })

	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/cmp-path" })
	use({ "hrsh7th/cmp-nvim-lua" })
	use({ "hrsh7th/cmp-emoji" })
	use({ "hrsh7th/cmp-buffer" })
	use("dcampos/cmp-snippy")

	use({ "windwp/nvim-autopairs" })
end)

local gitsigns = require("gitsigns")
gitsigns.setup({
	signs = {
		add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
		change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
		delete = { hl = "GitSignsDelete", text = "|", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		topdelete = { hl = "GitSignsDelete", text = "|", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		changedelete = { hl = "GitSignsChange", text = "|", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
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
				gitsigns.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true })

		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gitsigns.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true })
	end,
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
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
		"jsonc",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"python",
		"regex",
		"ruby",
		"rust",
		"scss",
		"toml",
		"typescript",
		"vim",
		"vue",
		"yaml",
	},
	highlight = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gni",
			node_incremental = "gnn",
			node_decremental = "gnm",
			scope_incremental = "gns",
		},
	},
})

require("telescope").setup({
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

local snippy = require("snippy")
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			snippy.expand_snippet(args.body)
			return nil
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "snippy" },
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

snippy.setup({
	mappings = {
		is = {
			["<Tab>"] = "expand_or_advance",
			["<S-Tab>"] = "previous",
		},
		-- nx = {
		-- 	["<leader>x"] = "cut_text",
		-- },
	},
})

require("nvim-autopairs").setup({
	disable_in_marcro = true,
})
-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
-- cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done())

-- LSP settings
vim.diagnostic.config({ virtual_text = { source = true } })

local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	local opts = { noremap = true, silent = true }
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>D", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>d", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev({float = false})<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next({float = false})<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ldl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

	if client.server_capabilities.documentFormattingProvider then
		local lsp_au = vim.api.nvim_create_augroup("LspFormatting", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = lsp_au,
			buffer = bufnr,
			callback = function(ev)
				vim.lsp.buf.format({
					filter = function(client_)
						return client_.name ~= "tsserver"
					end,
					bufnr = ev.buf,
					timeout_ms = nil,
				})
			end,
		})
	end

	require("lsp_signature").on_attach({
		hint_prefix = "",
		hint_enable = false,
		floating_window = true,
		doc_lines = 1,
	})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local function lsp_server(lsp, opts, on_attach_pre)
	local on_attach_func = on_attach
	if on_attach_pre then
		on_attach_func = function(client, bufnr)
			on_attach_pre(client, bufnr)
			on_attach(client, bufnr)
		end
	end
	local options = {
		on_attach = on_attach_func,
		capabilities = capabilities,
	}
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	lspconfig[lsp].setup(options)
end

lsp_server("gopls", {
	init_options = {
		completeUnimported = true,
		hoverKind = "FullDocumentation",
		buildFlags = { "-tags", "notmuch" },
		analyses = {
			composites = false,
			fillreturns = true,
			nonewvars = true,
			unusedparams = true,
			shadow = true,
		},
		linksInHover = false,
		staticcheck = true,
		usePlaceholders = false,
	},
})
vim.cmd("au BufRead,BufNewFile *.gotmpl setlocal filetype=gotmpl")

lsp_server("ccls")
lsp_server("pylsp", {
	settings = {
		pylsp = {
			configurationSources = { "pyflakes" },
		},
	},
})
lsp_server("bashls")
lsp_server("tsserver", nil, function(client, bufnr)
	-- disable tsserver formatting done via null-ls
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
	client.server_capabilities.documentOnTypeFormattingProvider = false

	local ts_utils = require("nvim-lsp-ts-utils")
	ts_utils.setup({
		filter_out_diagnostics_by_code = {
			80001, -- require js module warning
		},
	})
	-- required to fix code action ranges and filter diagnostics
	ts_utils.setup_client(client)
end)

lsp_server("sumneko_lua", {
	cmd = { "/usr/bin/lua-language-server" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT", -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				path = vim.split(package.path, ";"), -- Setup your lua path
			},
			diagnostics = {
				globals = { "vim" }, -- Get the language server to recognize the `vim` global
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier.with({
			prefer_local = "node_modules/.bin",
		}),
		null_ls.builtins.formatting.goimports,
		null_ls.builtins.diagnostics.eslint_d.with({
			prefer_local = "node_modules/.bin",
		}),
	},
	on_attach = on_attach,
	diagnostics_format = "[#{c}] #{m} [#{s}]", -- #{m}: message, #{s}: source name, #{c}: code (if available)
})

vim.cmd([[
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
map gm :call SynStack()<CR>
]])

vim.g.NERDTreeShowHidden = 1
