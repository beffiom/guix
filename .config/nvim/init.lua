-- =============================================================================
-- Global Options
-- =============================================================================

-- General Neovim settings
vim.opt.nu = true               -- Line numbers
vim.opt.relativenumber = false  -- Relative line numbers

vim.opt.tabstop = 4             -- Tab width
vim.opt.softtabstop = 4         -- Soft tab stops for editing
vim.opt.shiftwidth = 4          -- Indent width
vim.opt.expandtab = true        -- Use spaces instead of tabs

vim.opt.incsearch = true        -- Incremental search
vim.opt.hlsearch = true         -- Highlight search results
vim.opt.termguicolors = true    -- Enable true color support in terminal

vim.opt.scrolloff = 8           -- Lines to keep above/below cursor when scrolling
vim.opt.signcolumn = "yes"      -- Always show sign column

vim.opt.updatetime = 300        -- Time in ms to wait before writing swap file (for LSP)

-- Prevent issues with remote sessions or specific terminal emulators
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- System-wide Copy/Paste with wl-clipboard
vim.o.clipboard = "unnamedplus"

if vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = {
    name = 'wl-clipboard',
    copy = { ['+'] = 'wl-copy', ['*'] = 'wl-copy', },
    paste = { ['+'] = 'wl-paste', ['*'] = 'wl-paste', }, -- Fixed: was 'wl-copy'
    cache_enabled = 0,
  }
else
  print("Warning: wl-clipboard executables not found. System clipboard integration may be limited.")
end

-- Set leader key (e.g., Space)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- =============================================================================
-- Lazy.nvim Plugin Manager Setup
-- =============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Auto-reload Config on Save
-- =============================================================================
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('LazyReloadConfig', { clear = true }),
  pattern = {
    vim.fn.stdpath('config') .. '/init.lua',
    vim.fn.stdpath('config') .. '/lua/**/*.lua',
  },
  callback = function()
    if pcall(require, 'lazy') then
      -- Method 1: Reload all plugins (safest approach)
      -- vim.cmd('Lazy reload')
      
      -- Alternative Method 2: Just reload the config without Lazy reload
      dofile(vim.env.MYVIMRC)
      
      vim.notify("Neovim config reloaded!", vim.log.levels.INFO)
    end
  end,
  desc = "Automatically reload Neovim config on save",
})
-- Initialize Lazy.nvim and load plugins
require("lazy").setup({
  -- CORE INFRASTRUCTURE PLUGINS (lazy = false, loaded immediately)
  -- These MUST be loaded early for everything else to function
  { 'nvim-lua/plenary.nvim', lazy = false },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', lazy = false, priority = 1000,
    opts = { -- Use 'opts' to pass config, lazy.nvim will call .setup()
      ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "json", "yaml",
        "markdown", "markdown_inline", "clojure", "bash", "python", },
      highlight = { enable = true, additional_vim_regex_highlighting = false, },
      indent = { enable = true, },
      autotag = { enable = true, enable_close_on_slash = false, },
    },
  },
  { 'kyazdani42/nvim-web-devicons', lazy = false, opts = {} }, -- Needs Nerd Font, load early for icons

  -- MASON & LSPCONFIG (MUST load after Plenary, but often before or alongside nvim-cmp)
  {
    'williamboman/mason.nvim', lazy = false, build = ':MasonUpdate',
    opts = { -- Use 'opts' for Mason config
      ensure_installed = {
        "sumneko_lua", "ltex", "clojure_lsp", "bashls", "pyright", "java_debug_adapter", "vscode_java",
      },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim', lazy = false,
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = { -- Use 'opts' for Mason-Lspconfig config
      -- All handlers go here now
      handlers = {
        -- Default handler for setting up LSP servers
        function(server_name) require('lspconfig')[server_name].setup { capabilities = require('cmp_nvim_lsp').default_capabilities(), } end,
        ltex = function() require('lspconfig').ltex.setup { settings = { ltex = { language = "en-US", diagnosticSeverity = "information", checkCompoundWords = true, trace = { server = "verbose" }, enabled = { "markdown", "latex", "tex", "rst", "org" }, dictionary = { ["en-US"] = {"Neovim", "lazy.nvim", "Guix", "NixOS", "dwl-guile", "Btrfs", "LUKS", "Tofi", "rmpc", "lf", "Atuin", "Nushell", "Qutebrowser", "wl-copy", "wl-paste", "wtype", "cliphist", "Zoxide", "Entangled", "Zk", "mkdwn", "ltex-ls", "Clojure", "JVM", "Pyright"} } }, }, capabilities = require('cmp_nvim_lsp').default_capabilities(), } end,
        clojure_lsp = function() require('lspconfig').clojure_lsp.setup { capabilities = require('cmp_nvim_lsp').default_capabilities(), settings = {}, } end,
        bashls = function() require('lspconfig').bashls.setup { capabilities = require('cmp_nvim_lsp').default_capabilities(), } end,
        pyright = function() require('lspconfig').pyright.setup { capabilities = require('cmp_nvim_lsp').default_capabilities(), settings = { python = { analysis = {}, }, }, } end,
        ['jdtls'] = function() require('lspconfig').jdtls.setup { root_dir = require('lspconfig.util').root_pattern('.git', 'pom.xml', '.project', 'build.gradle'), capabilities = require('cmp_nvim_lsp').default_capabilities(), } end,
      }
    },
  },
  { 'neovim/nvim-lspconfig', lazy = false, }, -- LSP client configuration. Load always after Mason.lspconfig

  -- AUTOCOMPLETION (Needs to load after LSP for capabilities)
  { 'L3MON4D3/LuaSnip', lazy = false, opts = { enable = true, }, config = function() require('luasnip.loaders.from_vscode').lazy_load() end }, -- Snippet engine, load always
  {
    'hrsh7th/nvim-cmp', lazy = false, -- Autocompletion plugin. Load always.
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end, },
        sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'buffer' }, { name = 'path' }, }),
        completion = { completeopt = 'menu,menuone,noinsert', },
        mapping = cmp.mapping.preset.insert({ 
          ['<C-b>'] = cmp.mapping.scroll_docs(-4), 
          ['<C-f>'] = cmp.mapping.scroll_docs(4), 
          ['<C-Space>'] = cmp.mapping.complete(), 
          ['<C-e>'] = cmp.mapping.abort(), 
          ['<CR>'] = cmp.mapping.confirm({ select = true }), 
        }),
      })
    end,
  },

  -- Other IDE helpers
  {
    'windwp/nvim-autopairs', event = "InsertEnter", config = true
  },
  {
    'numToStr/Comment.nvim', event = "BufReadPost", config = function() require('Comment').setup() end,
  },
  {
    'nomnivore/ollama.nvim', -- Your new repo!
    ft = { "markdown", "txt", "lua", "clojure", "python" },
    config = function()
      require('ollama').setup({
        server_url = "http://localhost:11434", model = "llama3", commands = { ollama = { { cmd = 'OllamaPrompt', args = { template = "You are a helpful assistant. Provide concise answer: {{.input}}", prompt = "Ask Ollama:", selection_prompt = "Ask Ollama about selection:", }, }, { cmd = 'OllamaCode', args = { template = "Please improve the following code: {{.input}}", prompt = "Improve code:", selection_prompt = "Improve selected code:", }, }, }, }, })
    end,
  },
  {
    'Olical/conjure',
    ft = { "clojure", "fennel", "scheme", "guile" },
    config = function()
      vim.cmd [[ let g:conjure#mapping#prefix = "<localleader>"]]
      require('conjure.main').setup {}
    end,
  },

  -- =========================================================================
  -- Status Line
  -- =========================================================================
  {
    'nvim-lualine/lualine.nvim', event = "BufReadPost", dependencies = { 'kyazdani42/nvim-web-devicons' }, config = function() require('lualine').setup { options = { icons_enabled = true, theme = 'auto', component_separators = { left = '', right = ''}, section_separators = { left = '', right = ''}, disabled_filetypes = { 'NvimTree', 'lazy' }, always_last_status = 0, }, sections = { lualine_a = {'mode'}, lualine_b = {'branch', 'diff', 'diagnostics'}, lualine_c = {'filename'}, lualine_x = {'encoding', 'fileformat', 'filetype'}, lualine_y = {'progress'}, lualine_z = {'location'} }, inactive_sections = { lualine_a = {}, lualine_b = {}, lualine_c = {'filename'}, lualine_x = {'location'}, lualine_y = {}, lualine_z = {} }, tabline = {}, extensions = {'nvim-tree', 'lazy'} } end,
  },

  -- =========================================================================
  -- Fuzzy Finder (Telescope)
  -- =========================================================================
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.6', dependencies = { 'nvim-lua/plenary.nvim' }, keys = { { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = 'Find Files' }, { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = 'Live Grep' }, { '<leader>fb', '<cmd>Telescope buffers<CR>', desc = 'Buffers' }, { '<leader>fh', '<cmd>Telescope help_tags<CR>', desc = 'Help Tags' }, }, config = function() require('telescope').setup({ defaults = { vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', }, sorting_strategy = "ascending", layout_strategy = "vertical", layout_config = { vertical = { width = 0.9, height = 0.9, preview_cutoff = 100, prompt_position = "top", mirror = false, }, }, file_sorter = require('telescope.sorters').get_fuzzy_file_sorter, file_ignore_patterns = { "%.git/", "%.cache/", "%.local/", "node_modules/" }, color_devicons = true, set_env = { ['COLORTERM'] = 'truecolor' }, }, pickers = { find_files = { hidden = true, }, }, extensions = {}, }) end,
  },

  -- =========================================================================
  -- Markdown-Specific Workflow
  -- =========================================================================
  {
    'jbyuki/ntangle.nvim', -- Your new Entangle plugin
    ft = 'markdown',
    dependencies = { 'nvim-treesitter' },
    config = function()
      require('ntangle').setup({})
    end,
  },
  {
    'mickael-menu/zk-nvim', cmd = { "Zk", "ZkNotes" }, ft = 'markdown', dependencies = { 'nvim-treesitter', 'nvim-lspconfig' }, config = function() require('zk').setup({ notes_dir = os.getenv("HOME") .. "/Notes", mappings = { ['<leader>zn'] = { action = 'ZkNew', description = 'Create new note', opts = { title = vim.fn.input('Note title: ') } }, ['<leader>zf'] = { action = 'ZkNotes', description = 'Search notes' }, ['<leader>zl'] = { action = 'ZkLinks', description = 'Show note links' }, } }) end,
  },
  {
    'nvim-orgmode/orgmode', ft = { 'org', 'markdown' }, config = function() require('orgmode').setup({ org_agenda_files = { os.getenv("HOME") .. "/Notes" }, org_default_notes_file = os.getenv("HOME") .. "/Notes/inbox.org", }) end
  },
  {
    'folke/trouble.nvim', cmd = "TroubleToggle", dependencies = { "nvim-tree/nvim-tree.lua", "nvim-web-devicons" }, config = function() require("trouble").setup({}) end
  },
  {
    'nvim-tree/nvim-tree.lua', keys = { { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" } }, config = function() require('nvim-tree').setup({ filters = { dotfiles = true, }, renderer = { group_empty = true, }, view = { side = 'left', width = 30, hide_root_folder = false, adaptive_size = false, mappings = { custom_only = false, list = {}, }, }, filesystem_watchers = { enable = true, debounce_delay = 50, }, actions = { open_file = { quit_on_open = true, }, }, }) end
  },
  {
    'preservim/tagbar', cmd = 'TagbarToggle', config = function() vim.g.tagbar_autofocus = 1 end
  },

  -- Markdown Folding (simple foldexpr + keymaps)
  {
    'folke/zen-mode.nvim', -- Added a real plugin instead of empty string
    ft = 'markdown', 
    config = function() 
      require('zen-mode').setup({})
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt.foldlevel = 99
      vim.opt.conceallevel = 2
      vim.opt.concealcursor = 'n'
      vim.keymap.set('n', 'za', 'za', { desc = 'Toggle fold' })
      vim.keymap.set('n', 'zA', 'zA', { desc = 'Open all folds recursively' })
      vim.keymap.set('n', 'zc', 'zc', { desc = 'Close fold' })
      vim.keymap.set('n', 'zC', 'zC', { desc = 'Close all folds recursively' })
      vim.keymap.set('n', 'zi', 'zi', { desc = 'Toggle folds enabled/disabled' })
    end
  },
  {
    'hedyhli/outline.nvim', cmd = 'Outline', dependencies = { 'nvim-treesitter' }, config = function() require('outline').setup({ symbols = { 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'task', }, guides = { enabled = true, priority = 500, }, }); vim.keymap.set('n', '<leader>o', '<cmd>Outline<CR>', { desc = 'Toggle Outline' }) end,
  },

}) -- End of lazy.setup calls

-- =============================================================================
-- Colorscheme (Choose one and install it via lazy.nvim if not built-in)
-- =============================================================================
vim.cmd("colorscheme default")
