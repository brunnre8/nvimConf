local M = {}

-- exported, so that we can use it in lsp overrides in after/lsp
M.capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities({
		-- https://github.com/neovim/neovim/issues/30688
		insertReplaceSupport = false,
	})
)

vim.diagnostic.config({ virtual_text = { source = true } })
vim.lsp.on_type_formatting.enable()
vim.lsp.linked_editing_range.enable()
vim.lsp.inlay_hint.enable()

-- lowest precedence config for all servers
vim.lsp.config('*', {
	capabilities = M.capabilities,
	root_markers = { '.git' } -- bit pointless, gets overridden pretty much every time
})

---@param client vim.lsp.Client
local function mapkeys(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "<leader>D", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("i", "<C-f>", vim.lsp.buf.code_action, opts)
	vim.keymap.set("v", "<C-f>", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)
	vim.keymap.set("n", "<leader>ldl", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "<leader>la", vim.diagnostic.setloclist, opts)

	local pickers = require("telescope.builtin")
	vim.keymap.set("n", "<leader>li", pickers.lsp_implementations, opts)
	vim.keymap.set("n", "<leader>lr", pickers.lsp_references, opts)

	-- TODO: this is shit, but the merge semantics for any of the lsp things
	-- only overwrite completely, we can't add to them.
	-- fixup when https://github.com/neovim/neovim/issues/33577 has a solution

	if client.name == "clangd" then
		vim.keymap.set("n", "<leader>ga", vim.cmd.ClangdSwitchSourceHeader, opts)
	end
end

local lsp_au = vim.api.nvim_create_augroup("rpb.lsp", {})

---@param client vim.lsp.Client
local function fixup_ts(client, bufnr)
	-- disable tsserver formatting done via null-ls
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
	-- client.server_capabilities.documentOnTypeFormattingProvider = false

	local ts_utils = require("nvim-lsp-ts-utils")
	ts_utils.setup({
		filter_out_diagnostics_by_code = {
			80001, -- require js module warning
		},
	})
	-- required to fix code action ranges and filter diagnostics
	ts_utils.setup_client(client)
end

M.on_attach = function(client, bufnr)
	require("lsp_signature").on_attach({
		hint_prefix = "",
		hint_enable = false,
		floating_window = true,
		doc_lines = 0,
		zindex = 50 -- bottom of other things
	})

	-- TODO: this is shit, but the merge semantics for any of the lsp things
	-- only overwrite completely, we can't add to them.
	-- fixup when https://github.com/neovim/neovim/issues/33577 has a solution

	if client.name == "volar" then
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end

	if client.name == "ts_ls" then
		fixup_ts(client, bufnr)
	end

	-- if server supports "willSaveWaitUntil" it probably has a way to tell it to format on save
	if not client:supports_method('textDocument/willSaveWaitUntil')
		and client:supports_method('textDocument/formatting') then
		vim.api.nvim_create_autocmd('BufWritePre', {
			group = lsp_au,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 5000 })
			end,
		})
	end

	if client:supports_method('textDocument/codeLens') then
		local function refresh_codelens()
			vim.lsp.codelens.refresh({
				bufnr = bufnr,
			})
		end
		vim.api.nvim_create_autocmd({ 'BufEnter', "CursorHold", "InsertLeave" }, {
			buffer = bufnr,
			group = lsp_au,
			callback = refresh_codelens,
		})
		refresh_codelens() -- immediately refresh once
	end

	mapkeys(client, bufnr)

	-- TODO: enable nvim native completion
	-- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|

	-- if client:supports_method('textDocument/completion') then
	-- Optional: trigger autocompletion on EVERY keypress. May be slow!
	-- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
	-- client.server_capabilities.completionProvider.triggerCharacters = chars

	-- vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
	-- end
end

vim.api.nvim_create_autocmd('LspAttach', {
	group = lsp_au,
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		M.on_attach(client, args.buf)
	end,
})


vim.lsp.enable({
	"volar",
	"lua_ls",
	"html",
	"tinymist",
	"clangd",
	"pylsp",
	"texlab",
	"gopls",
	"bashls",
	"cssls",
	"eslint",
	"mesonlsp",
})

-- =================
-- FORMATTING AUCMDS
-- =================

vim.filetype.add({
	extension = {
		gohtml = "gohtml.html",
	},
})

local lsp_au = vim.api.nvim_create_augroup("rpb.lspFormat", {})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = lsp_au,
	callback = function(ev)
		vim.lsp.buf.format({
			filter = function(client_)
				return client_.name ~= "ts_ls"
			end,
			bufnr = ev.buf,
			timeout_ms = nil,
		})
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = lsp_au,
	pattern = { "*.js", "*.ts", "*.vue" },
	command = "LspEslintFixAll",
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = lsp_au,
	pattern = { "*.go" },
	callback = function()
		local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding(0))
		params.context = { only = { "source.organizeImports" } }

		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		for _, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding(0))
				else
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
	end,
})

-- this seems roundabout, but passing the position
-- doesn't work with normal LSP, so nvim cheats
-- in the TexlabBuild command.
-- Hence prefer that over build.onSave = true
vim.api.nvim_create_autocmd("BufWritePost", {
	group = lsp_au,
	pattern = { '*.tex', '*.plaintex', '*.bib' },
	command = "LspTexlabBuild",
})

-- java lsp uses it...
M.lsp_default_options = {
	on_attach = M.on_attach,
	capabilities = M.capabilities,
}


return M
