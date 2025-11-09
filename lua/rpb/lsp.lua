local M = {}

M.capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities({
		-- https://github.com/neovim/neovim/issues/30688
		insertReplaceSupport = false,
	})
)

M.on_attach = function(client, bufnr)
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

	require("lsp_signature").on_attach({
		hint_prefix = "",
		hint_enable = false,
		floating_window = true,
		doc_lines = 0,
		zindex = 50 -- bottom of other things
	})
end

M.lsp_default_options = {
	on_attach = M.on_attach,
	capabilities = M.capabilities,
}

return M
