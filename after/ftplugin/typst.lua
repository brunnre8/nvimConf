vim.api.nvim_create_user_command('TypstPreview',
	function(opts)
		local current = vim.fn.expand('%:p')
		local pdf = current:sub(0, -(string.len(".typ") + 1)) .. ".pdf"
		local path = vim.fs.joinpath("/tmp/typst/", pdf)
		vim.system({ "open", path }, { detach = true })
	end,
	{
		nargs = 0,
		desc = "Open pdf preview"
	})
