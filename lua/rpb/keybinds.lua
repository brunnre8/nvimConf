local function noremap(mode, lhs, rhs, opts)
	  local options = {noremap = true}
	    if opts then options = vim.tbl_extend('force', options, opts) end
		  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
	  end

vim.g.mapleader = ','

-- INSERT --
noremap('i', 'jk', '<Esc>')

-- NORMAL --
noremap('n', '<C-n>', ':NERDTreeToggle<CR>')
noremap('n', '<Leader>a', '<C-a>') -- numbers increment / decrement
noremap('n', '<Leader>x', '<C-x>')
noremap('n', '<Leader>c', ':ccl <bar> lcl<CR>')
noremap('n', '<Leader>nn', ':nohl<CR>')
noremap('n', '<Leader>q', ':q<CR>')
noremap('n', '<Leader>z', ':tab split<CR>')
noremap('n', '<Leader>m', ':silent make<CR>')
noremap('n', '<Leader>gs', ':Gtabedit :<CR>')
-- telescope stuff
noremap('n', '<Leader>fb', ':Telescope buffers<CR>')
noremap('n', '<Leader>ff', ':Telescope find_files<CR>')
noremap('n', '<Leader>fm', ':Telescope man_pages<CR>')
noremap('n', '<Leader>fg', ':Telescope live_grep<CR>')
noremap('n', '<Leader>fs', ':Telescope lsp_document_symbols<CR>')

noremap('i', '<C-Space>', 'compe#complete()', {silent=true, expr=true})
noremap('i', '<CR>', 'compe#confirm(\'<CR>\')', {silent=true, expr=true})
noremap('i', '<C-e>', 'compe#close(\'<C-e>\')', {silent=true, expr=true})
noremap('i', '<C-f>', 'compe#scroll({ \'delta\': +4 })', {silent=true, expr=true})
noremap('i', '<C-d>', 'compe#scroll({ \'delta\': -4 })', {silent=true, expr=true})

-- nmap <leader>rn <Plug>(coc-rename)
-- " Remap keys for gotos
-- nmap <silent> <leader>d <Plug>(coc-definition)
-- nmap <silent> <leader>gy <Plug>(coc-type-definition)
-- nmap <silent> <leader>gi <Plug>(coc-implementation)
-- nmap <silent> <leader>gr <Plug>(coc-references)
-- nmap <silent> <leader>gc :<C-u>CocListResume<cr>
-- " navigate diagnostics
-- nmap <silent> <leader>ep <Plug>(coc-diagnostic-prev)
-- nmap <silent> <leader>en <Plug>(coc-diagnostic-next)
