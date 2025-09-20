local jdtls = require('jdtls')
local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }) or '.'
local home = os.getenv('HOME')
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local jdtls_install_path = home .. '/sourcecode/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/'
local java_debug_jar = vim.fn.glob(
	home .. "/sourcecode/ms-java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
	true)

local bundles = {
	java_debug_jar,
}
vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/sourcecode/vscode-java-test/server/*.jar", true), "\n"))

local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {

		-- 💀
		'java', -- or '/path/to/java17_or_newer/bin/java'
		-- depends on if `java` is in your $PATH env variable and if it points to the right version.

		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dlog.protocol=true',
		'-Dlog.level=ALL',
		'-Djava.telemetry.enabled=false', -- let's see it that works...
		'-Xmx1g',
		'--add-modules=ALL-SYSTEM',
		'--add-opens', 'java.base/java.util=ALL-UNNAMED',
		'--add-opens', 'java.base/java.lang=ALL-UNNAMED',

		-- 💀
		'-jar', vim.fn.glob(jdtls_install_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),

		-- 💀
		'-configuration', jdtls_install_path .. '/config_linux',

		-- 💀
		-- See `data directory configuration` section in the README
		'-data', workspace_folder,
	},

	-- 💀
	-- One dedicated LSP server & client will be started per unique root_dir
	root_dir = root_dir,

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			format = {
				comments = {
					enabled = false,
				}
			}
		}
	},

	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = bundles,
	},
}

config = vim.tbl_deep_extend(
	"force",
	config,
	require('rpb.lsp').lsp_default_options
)

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
