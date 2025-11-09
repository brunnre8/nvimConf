---@type vim.lsp.Config
return {
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vim.fs.normalize(
					"~/.local/opt/npm/lib/node_modules/@vue/language-server"),
				languages = { "javascript", "typescript", "vue" },
			},
		},
	},
	filetypes = {
		"javascript",
		"typescript",
		"vue",
	},
}
