" vundle plugin manager
set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" color theme
Plugin 'NLKNguyen/papercolor-theme'

Plugin 'ConradIrwin/vim-bracketed-paste'

Plugin 'Yggdroot/indentLine'

Plugin 'rust-lang/rust.vim'

Plugin 'neoclide/coc.nvim', {'branch': 'release'}

Plugin 'dense-analysis/ale'

Plugin 'github/copilot.vim'

call vundle#end()

syntax enable
filetype plugin indent on
" end vundle

" PaperColor settings
set background=dark
colorscheme PaperColor

" autoindent
:set autoindent
:set cindent


" An example vimrc file, adapted from /usr/share/vim/vim82/vimrc_example.vim.
" Please adapt further for your personal use.
"
" When in doubt, :h is your friend.  For example, to look up what the shiftwidth
" setting does, run:
"
"   :h 'shiftwidth'
"
" Written by John Hui, with inspiration from Bram Moolenaar, Jae Woo Lee, and
" Timothy Pope.

" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

"""""""" Appearance

" enable basic features, voiding compatability with arcane Vim distributions
syntax enable
filetype plugin indent on

set encoding=utf-8  " insist on utf-8 encoding
set number          " show line numbers
set relativenumber  " Show relative line numbers
set laststatus=2    " always show status line
set ruler           " show line and column numbers
set wildmenu        " allow command-line completion

set scrolloff=5     " leave 5 lines of breathing room at the top and botom
set sidescrolloff=5 " leave 5 characters of breathing room at the side

" display literal characters for tabs, trailing spaces, last visible column,
" first visible column, non-breakable spaces
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
" to see these characters, run :set list


""""""""" Backup and undo

set backup          " keep a backup file (restore to previous version)
set undofile        " keep an undo file (undo changes after closing)

" Run mkdir to make sure ~/.backup exists first
silent! !mkdir -p ~/.backup

" Prepend ~/.backup to backupdir so that Vim will look for that directory
" before littering the current dir with backups.
set backupdir^=~/.backup

" Also use ~/.backup for undo files.
set undodir^=~/.backup

" Also use ~/.backup for swap files. The trailing // tells Vim to incorporate
" full path into swap file names.
set dir^=~/.backup//


""""""""" Search

set hlsearch        " highlight all terms matching / and ? search
set incsearch       " start searching and highlighting as you type
set smartcase       " case-insensitive search by default, but opt into
                    " case-sensitive search when you include capital characters

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif


"""""""" Indentation and spelling

set textwidth=80    " start wrapping lines longer than 80 characters
set shiftwidth=4    " auto-indent by 4 spaces, just as K&R decreed
set expandtab       " expand tabs to spaces...
set tabstop=4       " ...4 spaces to be precise

" To forcibly insert a tab character, type <C-V><Tab> (ctrl-v followed by TAB)

" Per-filetype indentation settings.
" We put these in an autocmd group, so that we can delete them easily.
augroup FiletypeIndentation
  autocmd!

  " Don't expand tabs in Makefiles
  autocmd FileType make setlocal noexpandtab

  " Don't do spell-checking on Vim help files
  autocmd FileType help setlocal nospell

  " My settings when editing *.txt files
  "   - automatically indent lines according to previous lines
  "   - replace tab with 8 spaces
  "   - when I hit tab key, move 2 spaces instead of 8
  "   - wrap text if I go longer than 76 columns
  "   - check spelling
  autocmd FileType text setlocal autoindent expandtab softtabstop=2 textwidth=76 spell spelllang=en_us
augroup END

"""""""""" rust stuff, from https://blog.logrocket.com/configuring-vim-rust-development/

let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

""""" quick function definitions

" the following two functions take multi-byte characters into account.
" from https://github.com/LucHermitte/lh-vim-lib/blob/02764e0e87f85fa13e0d6a0e38ac6605f806d560/autoload/lh/encoding.vim#LL119

function PreviousCharacter() abort
    return matchstr(getline('.'), '.\%'.col('.').'c')
endfunction

function CurrentCharacter() abort
    return matchstr(getline('.'), '\%'.col('.').'c.')
endfunction

function CursorIsBetweenBrackets(bracketSets = ["{}"])
    let prev = PreviousCharacter()
    let curr = CurrentCharacter()

    for str in a:bracketSets
        if prev . curr == str
            return 1
        endif
    endfor
    return 0
endfunction

"""""""" coc settings (https://github.com/neoclide/coc.nvim/#example-vim-configuration)

" coc.nvim calculates byte offset by count utf-8 byte sequence
set encoding=utf-8
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" autocomplete with <TAB>
inoremap <silent><expr> <tab> coc#pum#visible() ? coc#pum#confirm() : "\<c-g>u\<TAB>"
" remap enter (<CR> in vimscript) to just enter, not autocomplete. Also if between brackets, add line
" <C-g>u breaks up undo so you can cleanly undo this with one stroke.
inoremap <silent><expr> <CR> CursorIsBetweenBrackets() ? "\<c-g>u\<cr>\<Up>\<End>\<cr>" : "\<cr>"

" close popup with <Esc>
inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#stop() : "<Esc>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>


"""""""" Misc.

" disable the bell (it's so annoying)
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

" The matchit plugin makes the % command work better, and comes bundled with
" most Vim distributions.
packadd! matchit

set ttimeout        " for escaped terminal codes, only wait for...
set ttimeoutlen=100 " ...100ms

set autoread        " automatically detect external changes to open file

" don't highlight json comments in CoC
autocmd FileType json syntax match Comment +\/\/.\+$+
