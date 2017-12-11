set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plug
call plug#begin()
Plug 'bling/vim-airline'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-vinegar'
Plug 'kien/ctrlp.vim', { 'on': 'CtrlP' }

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'tpope/vim-surround'
Plug 'michaeljsmith/vim-indent-object'
Plug 'nestorsalceda/vim-strip-trailing-whitespaces'

Plug 'scrooloose/syntastic'

Plug 'klen/python-mode', { 'for': 'python' }
Plug 'fatih/vim-go', { 'for': 'go' }
let g:go_fmt_command = "goimports"
Plug 'chase/vim-ansible-yaml', { 'for': 'ansible' }

call plug#end()

let mapleader=","

highlight clear SignColumn

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.whitespace = 'Ξ'

let NERDTreeIgnore=['\.pyc$', '\.orig$']
map <C-x> :NERDTreeToggle<CR>

nmap <leader>e :CtrlP<CR>

cmap w!! w !sudo tee % >/dev/null

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=0

let g:pymode_warnings = 0
let g:pymode_folding = 0
let g:pymode_lint = 0
let g:pymode_breakpoint = 0
let g:pymode_rope = 0

set hlsearch
set list
set listchars=tab:▸\ ,eol:¬
set number
set showmatch
set wildignore+=*.pyc,node_modules,*.egg-info
set wildmode=list:longest
set mouse=a


set runtimepath^=~/.vim/bundle/ctrlp.vim

set cursorline
syntax on

imap jj <Esc>

if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

" Syntax coloring and filetype detection
syntax on
filetype plugin indent on

" Indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set autoindent

" utf-8 encoding
set encoding=utf-8

" Remove all trailing spaces on save
" http://vimcasts.org/episodes/tidying-whitespace
function! Preserve(command)
    let _s=@/
    let l = line(".")
    let c = col(".")
    execute a:command
    let @/=_s
    call cursor(l, c)
endfunction

autocmd BufWritePre * :call Preserve("%s/\\s\\+$//e")
