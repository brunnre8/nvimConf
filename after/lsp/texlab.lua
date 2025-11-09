---@type vim.lsp.Config
return {
	settings = {
		texlab = {
			build = {
				forwardSearchAfter = true,
				-- onSave = true -- doesn't actually work, see above
			},
			auxDirectory = nil,
			chktex = {
				onEdit = false,
				onOpenAndSave = true
			},
			forwardSearch = {
				executable = "zathura",
				args = { "--synctex-forward", "%l:1:%f", "%p" },
			},
			formatterLineLength = 120,
		},
	},
}
