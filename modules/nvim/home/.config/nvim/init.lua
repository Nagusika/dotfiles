-- init.lua — Neovim autonome, sans gestionnaire de plugins. LSP natif léger.
-- Exige nvim >= 0.11 (API vim.lsp.config / vim.lsp.enable). Portable, lisible.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options ------------------------------------------------------------------
local o = vim.opt
o.number = true
o.relativenumber = true
o.mouse = 'a'
o.clipboard = 'unnamedplus'
o.breakindent = true
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = 'yes'
o.updatetime = 250
o.timeoutlen = 400
o.splitright = true
o.splitbelow = true
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.inccommand = 'split'
o.cursorline = true
o.scrolloff = 8
o.termguicolors = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true
o.wrap = false
o.completeopt = 'menuone,noselect,popup'

pcall(vim.cmd.colorscheme, 'habamax')

-- Keymaps ------------------------------------------------------------------
local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Sauver' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quitter' })
map('n', '<leader>e', '<cmd>Explore<CR>', { desc = 'Explorateur' })
map('n', '<C-h>', '<C-w><C-h>')
map('n', '<C-j>', '<C-w><C-j>')
map('n', '<C-k>', '<C-w><C-k>')
map('n', '<C-l>', '<C-w><C-l>')
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Sortir du terminal' })

-- Diagnostics --------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = 'rounded', source = true },
})
map('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Diagnostic ligne' })

-- LSP natif léger : un serveur n'est activé QUE si son binaire est présent.
-- Aucun téléchargement automatique (pas de Mason) : on reste portable et prévisible.
local servers = {
  luals   = { cmd = { 'lua-language-server' },            filetypes = { 'lua' },          root_markers = { '.luarc.json', '.git' } },
  bashls  = { cmd = { 'bash-language-server', 'start' },  filetypes = { 'sh', 'bash' },   root_markers = { '.git' } },
  pyright = { cmd = { 'pyright-langserver', '--stdio' },  filetypes = { 'python' },       root_markers = { 'pyproject.toml', 'setup.py', '.git' } },
  gopls   = { cmd = { 'gopls' },                          filetypes = { 'go' },           root_markers = { 'go.mod', '.git' } },
  ts_ls   = { cmd = { 'typescript-language-server', '--stdio' }, filetypes = { 'typescript', 'javascript' }, root_markers = { 'package.json', '.git' } },
}
for name, cfg in pairs(servers) do
  if vim.fn.executable(cfg.cmd[1]) == 1 then
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
  end
end

-- Raccourcis + complétion natifs, actifs seulement quand un LSP s'attache.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local b = { buffer = ev.buf }
    map('n', 'gd', vim.lsp.buf.definition, b)
    map('n', 'gr', vim.lsp.buf.references, b)
    map('n', 'gi', vim.lsp.buf.implementation, b)
    map('n', 'K', vim.lsp.buf.hover, b)
    map('n', '<leader>rn', vim.lsp.buf.rename, b)
    map('n', '<leader>ca', vim.lsp.buf.code_action, b)
    map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, b)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
