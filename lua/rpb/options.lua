-- vim.cmd([[
-- 	augroup My_group
-- 	autocmd!
-- 	autocmd FileType c setlocal cindent
-- 	augroup END
-- ]])
local cmd = vim.cmd
local opt = vim.opt

cmd("filetype plugin on")
cmd("filetype indent on")
cmd("syntax enable")

cmd("autocmd ColorScheme * highlight ExtraWhitespace cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828")

opt.background = "dark" -- or "light" for light mode
cmd([[colorscheme gruvbox]])
-- override some things of the colorscheme
cmd([[
hi! link SignColumn Default
hi! link GitSignsAdd GruvboxGreenBold
hi! link GitSignsChange GruvboxAquaBold
hi! link GitSignsDelete GruvboxRedBold
hi! link TSError Normal
]])

-- Highlight on yank
vim.api.nvim_exec(
  [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]],
  false
)

opt.formatoptions = opt.formatoptions
  - "t" -- Auto-wrap text using textwidth
  - "o" -- O and o, don't continue comments
  - "r" -- Automatically insert the current comment leader after hitting <Enter> in Insert mode.
  + "n" -- Indent past the formatlistpat, not underneath it. Makes a paragraph after a numbered list for example
  + "j" -- Auto-remove comments if possible.

opt.modeline = false
opt.linebreak = true
opt.number = true
opt.relativenumber = true
opt.list = true

-- formatting stuff
opt.tabstop = 4
opt.shiftwidth = 0 -- use tabstop value
opt.softtabstop = -1 -- use shiftwidth

opt.spell = true
opt.termguicolors = true
opt.autoindent = true
opt.hlsearch = true
opt.showmatch = true -- show the matching part of the pair for [] {} and ()
opt.backspace = {'indent', 'eol', 'start'}
opt.wildmode = {'longest:full'} -- complete max common prefix, don't override unless told to do so
opt.completeopt = {'menuone', 'noselect'} -- pretty much required by compe
opt.autoread = true -- auto reload a file if it changes
opt.ignorecase = true
opt.smartcase = true -- case insensitive search except one uses uppercase letters
opt.hidden = true -- modified buffers can be hidden
opt.wrapscan = true
opt.signcolumn = 'yes' -- needed by git, else it constantly flashes in and out
