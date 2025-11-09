---@type vim.lsp.Config
return {
	settings = {
		exportPdf = "onType",
		formatterMode = "typstyle",
		outputPath = "/tmp/typst/$root/$dir/$name"
	}
}
