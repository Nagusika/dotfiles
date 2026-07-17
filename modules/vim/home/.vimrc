" ~/.vimrc — vimrc portable, sans plugin. Déployable tel quel sur n'importe quel serveur.
set nocompatible
syntax on
filetype plugin indent on

" Affichage
set number relativenumber
set ruler laststatus=2
set showcmd wildmenu wildmode=longest:full,full
set scrolloff=5
set cursorline
set background=dark
set display=lastline
set list listchars=tab:»·,trail:·,nbsp:␣

" Recherche
set ignorecase smartcase
set incsearch hlsearch

" Indentation
set expandtab tabstop=2 shiftwidth=2 softtabstop=2
set autoindent smartindent shiftround

" Comportement
set hidden autoread
set backspace=indent,eol,start
set mouse=a
set encoding=utf-8
set nowrap
set splitright splitbelow
set updatetime=300

" Fichiers d'état regroupés (pas de bruit à côté des sources)
set undofile
set undodir=~/.local/state/vim/undo//
set directory=~/.local/state/vim/swap//
set backupdir=~/.local/state/vim/backup//
if !isdirectory(expand('~/.local/state/vim/undo'))
  call mkdir(expand('~/.local/state/vim/undo'),   'p')
  call mkdir(expand('~/.local/state/vim/swap'),   'p')
  call mkdir(expand('~/.local/state/vim/backup'), 'p')
endif

" Statusline sobre
set statusline=%f\ %m%r%=%y\ %l:%c\ %P

" Leader + raccourcis
let mapleader=" "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>e :Explore<CR>

" Navigation entre splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
