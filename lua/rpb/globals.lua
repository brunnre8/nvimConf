local M = {}
-- Pretty print thing to the console
function M.P(thing)
	print(vim.inspect(thing))
	return thing
end

-- Replace a Termcode string to the internal representation
-- Use this say for returning "C-t" or "<TAB>" for mappings
function M.t(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return M
