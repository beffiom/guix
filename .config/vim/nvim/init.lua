vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

---------------
--- OPTIONS ---
---------------
-- See `:help vim.opt`

vim.cmd("colorscheme quiet")
vim.opt.background = dark
vim.opt.tabstop = 6
vim.opt.shiftwidth = 6
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 252
vim.opt.timeoutlen = 302
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 12

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-------------------
--- KEYBINDINGS ---
-------------------
--  See `:help vim.keymap.set()`

vim.keymap.set('n', '<C-a>', "<esc>ggVG<CR>")
vim.keymap.set('i', '<C-a>', "<esc>ggVG<CR>")

--------------------
--- AUTOCOMMANDS ---
--------------------
--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd( { "BufWritePost" }, { pattern = { "~/.config/nvim/init.lua" }, command = [[ !source % ]], })
vim.api.nvim_create_autocmd( { "BufWritePost" }, { pattern = { "~/.config/home-manager/home.nix" }, command = [[ !home-manager switch --flake ~/.config/home-manager --impure ]], })
vim.api.nvim_create_autocmd( { "BufWritePost" }, { pattern = { "/etc/nixos/configuration.nix" }, command = [[ !sudo nixos-rebuild switch ]], })
vim.api.nvim_create_autocmd( { "BufWritePost" }, { pattern = { "/etc/nixos/hardware-configuration.nix" }, command = [[ !sudo nixos-rebuild switch ]], })
vim.api.nvim_create_autocmd( { "BufWritePost" }, { pattern = { "config.h" }, command = [[ !sudo make install ]], })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

----------------------
--- PLUGIN MANAGER ---
----------------------
-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 2 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

---------------
--- PLUGINS ---
---------------
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'romainl/vim-cool', -- set nohlsearch when anything other than n or N is pressed

  -----------------
  --- TELESCOPE ---
  -----------------
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -----------
  --- OIL ---
  -----------
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },

  -----------
  --- ZEN ---
  -----------
  {
    "folke/zen-mode.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  }

}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
