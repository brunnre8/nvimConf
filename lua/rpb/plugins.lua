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

	use("scrooloose/nerdtree")

	-- Highlight, edit, and navigate code using a fast incremental parsing library
	use("nvim-treesitter/nvim-treesitter")
	use("nvim-treesitter/playground")
	use("lewis6991/spellsitter.nvim") -- treesitter messes up the spell detection of nvim
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

require("gitsigns").setup({
	signs = {
		add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
		change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
		delete = { hl = "GitSignsDelete", text = "|", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		topdelete = { hl = "GitSignsDelete", text = "|", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		changedelete = { hl = "GitSignsChange", text = "|", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
	},
	keymaps = {
		["n ]c"] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'" },
		["n [c"] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'" },
	},
})

require("nvim-treesitter.configs").setup({
	ensure_installed = "maintained",
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

require("spellsitter").setup()

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

function _G.goimports(timeout_ms)
	local context = { only = { "source.organizeImports" } }
	vim.validate({ context = { context, "t", true } })

	local params = vim.lsp.util.make_range_params()
	params.context = context

	-- See the implementation of the textDocument/codeAction callback
	-- (lua/vim/lsp/handler.lua) for how to do this properly.
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
	if not result or next(result) == nil then
		return
	end
	local actions = result[1].result
	if not actions then
		return
	end
	local action = actions[1]

	-- textDocument/codeAction can return either Command[] or CodeAction[]. If it
	-- is a CodeAction, it can have either an edit, a command or both. Edits
	-- should be executed first.
	if action.edit or type(action.command) == "table" then
		if action.edit then
			vim.lsp.util.apply_workspace_edit(action.edit)
		end
		if type(action.command) == "table" then
			vim.lsp.buf.execute_command(action.command)
		end
	else
		vim.lsp.buf.execute_command(action)
	end
end

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
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<leader>ldl",
		"<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>",
		opts
	)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

	if client.resolved_capabilities.document_formatting then
		vim.cmd("augroup lspFormat")
		vim.cmd("autocmd!")
		-- keepjumps prevents the change- and jump-list from being modified among other things
		-- keeppatterns prevents things from modifying search patterns, not that it should matter here
		vim.cmd("autocmd BufWritePre <buffer> keepjumps keeppatterns lua vim.lsp.buf.formatting_sync(nil, 1000)")
		vim.cmd("augroup end")
		vim.cmd([[ command! -buffer LspFormat execute 'keepjumps keeppatterns lua vim.lsp.buf.formatting()' ]])
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
capabilities.textDocument.completion.completionItem.snippetSupport = true

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
lsp_server("pylsp")
lsp_server("bashls")
lsp_server("tsserver", nil, function(client, bufnr)
	-- disable tsserver formatting done via null-ls
	client.resolved_capabilities.document_formatting = false
	client.resolved_capabilities.document_range_formatting = false

	local ts_utils = require("nvim-lsp-ts-utils")
	ts_utils.setup({
		filter_out_diagnostics_by_code = {
			80001, -- require js module warning
		},
	})
	-- required to fix code action ranges and filter diagnostics
	ts_utils.setup_client(client)
end)

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
-- table.insert(runtime_path,vim.fn.expand('$VIMRUNTIME/lua'))
-- table.insert(runtime_path,vim.fn.expand('$VIMRUNTIME/lua/vim/lsp'))
lsp_server("sumneko_lua", {
	cmd = { "/usr/bin/lua-language-server" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT", -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				path = runtime_path, -- Setup your lua path
			},
			diagnostics = {
				globals = { "vim" }, -- Get the language server to recognize the `vim` global
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
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
		null_ls.builtins.diagnostics.eslint_d,
	},
	on_attach = on_attach,
	diagnostics_format = "[#{c}] #{m} [#{s}]", -- #{m}: message, #{s}: source name, #{c}: code (if available)
})

-- lsp_server("

vim.cmd([[
augroup formatters
    au!
    au BufWritePre *.go lua goimports(1000)
augroup END
]])

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
