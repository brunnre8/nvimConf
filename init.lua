-- shut deprecation warnings up
function vim.deprecate() end

require("rpb/globals")
require("rpb/plugins")
require("rpb/options")
require("rpb/lsp")
require("rpb/keybinds")
