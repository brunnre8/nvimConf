---@type vim.lsp.Config
return {
	filetypes = { "go", "gomod", "gowork", "gohtml.html" },
	init_options = {
		completeUnimported = true,
		hoverKind = "FullDocumentation",
		analyses = {
			composites = false,
			fillreturns = true,
			nonewvars = true,
			unusedparams = true,
			shadow = true,
			QF1008 = false,
			ST1000 = false, -- package comment nag
			ST1003 = false, -- all caps names
		},
		linksInHover = false,
		staticcheck = true,
		usePlaceholders = false,
		templateExtensions = { "gohtml" },
		hints = {
			constantValues = true,
		},
	}
}
