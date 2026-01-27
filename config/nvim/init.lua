-- Neovim init.lua

-- Basic options
vim.opt.number = true                  -- enable absolute line numbers
vim.opt.relativenumber = true          -- enable relative line numbers
vim.opt.clipboard = "unnamedplus"     -- use system clipboard
vim.opt.mouse = "a"                   -- enable mouse
vim.opt.termguicolors = true           -- true color support
vim.opt.signcolumn = "yes"            -- always show signcolumn
vim.opt.showmode = false               -- don't show mode (we use statusline)
vim.opt.cursorline = true              -- highlight current line
vim.opt.hidden = true                  -- allow buffer switching without saving

-- Indentation
vim.opt.expandtab = true               -- spaces instead of tabs
vim.opt.shiftwidth = 2                 -- size of an indent
vim.opt.tabstop = 2                    -- number of spaces tabs count for
vim.opt.softtabstop = 2                -- spaces when hitting <Tab>

-- Searching
vim.opt.ignorecase = true              -- ignore case
vim.opt.smartcase = true               -- unless uppercase present
vim.opt.incsearch = true               -- incremental search
vim.opt.hlsearch = false               -- no persistent highlight

-- Splits & Windows
vim.opt.splitbelow = true              -- horizontal splits go below
vim.opt.splitright = true              -- vertical splits go right
vim.opt.equalalways = true             -- auto-resize splits

-- Backups & Undo
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true                -- enable persistent undo
vim.opt.undodir = vim.fn.stdpath('state') .. '/undo'

-- Timing
vim.opt.updatetime = 300               -- faster CursorHold
vim.opt.timeoutlen = 500               -- faster mapped sequences

-- Leader Key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require('lazy').setup({
  -- lazy.nvim manager
  { 'folke/lazy.nvim', version = '*' },

  -- Lualine statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators   = { left = '', right = '' },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'},
        },
      }
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          accept = false,
        },
        panel = {
          enabled = false
        },
        filetypes = {
          markdown = true,
          help = true,
          html = true,
          javascript = true,
          typescript = true,
          ["*"] = true
        },
      })

      vim.keymap.set("i", '<Tab>', function()
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, {
          silent = true,
        })
    end,
  },
  -- Telescope fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          layout_strategy = 'flex',
          file_ignore_patterns = {'node_modules'}
        }
      }
    end,
  },

  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup {
        view = { width = 30 },
        update_focused_file = { enable = true },
      }
    end,
  },

  -- Treesitter for syntax
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'lua', 'python', 'javascript', 'go', 'rust' },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  -- Mason LSP installer
  { 'williamboman/mason.nvim', cmd = 'Mason', config = true },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = 'neovim/nvim-lspconfig',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = { 'pyright', 'ts_ls', 'lua_ls' },
        automatic_enable = false,
      }
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = {'vim'} },
            workspace = { library = vim.api.nvim_get_runtime_file('', true) },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable({ 'pyright', 'ts_ls', 'lua_ls' })
    end,
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup {
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        sources = cmp.config.sources({{ name = 'nvim_lsp' },{ name = 'path' },{ name = 'luasnip' }}),
      }
    end,
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    config = function() require('gitsigns').setup {} end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function() require('nvim-autopairs').setup {} end,
  },

  -- Commenting
  {
  'numToStr/Comment.nvim',
  keys = {
    { '<Leader>/', function() require('Comment.api').toggle.linewise.current() end, desc = 'Toggle comment (line)' },
    { '<Leader>/', '<Esc><cmd>lua require("Comment.api").toggle.blockwise(vim.fn.visualmode())<CR>', mode = 'v', desc = 'Toggle comment (block)' },
  },
  config = function()
    require('Comment').setup({
      -- Add any custom config here; these are the defaults:
      padding = true,         -- add a space b/w comment and line
      sticky = true,          -- cursor stays put
      mappings = {
        basic = false,        -- disable builtin mappings because we're using our own
        extra = false,
      },
      toggler = {
        line   = '<Leader>/', -- won't be set by default since basic=false
        block  = '<Leader>/', -- same here
      },
    })
  end,
  },


  -- Which-key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function() require('which-key').setup {} end,
  },

  -- Bufferline
  {
    'akinsho/bufferline.nvim',
    event = 'BufWinEnter',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('bufferline').setup { options = { separator_style = 'thick' } }
    end,
  },

  -- Hop
  {
    'phaazon/hop.nvim',
    branch = 'v2',
    keys = { 'f', 'F', 't', 'T' },
    config = function() require('hop').setup {} end,
  },

  {
  'akinsho/toggleterm.nvim',              -- terminal toggling plugin
  version = '*',
  keys = { { '<Leader>t', '<cmd>ToggleTerm<CR>', desc = 'Toggle floating terminal' } },
  opts = {
    size           = 20,                  -- height of split if not floating
    open_mapping   = [[<Leader>t]],       -- map <Leader>t to toggle
    direction      = 'float',             -- open as floating window
    float_opts     = {
      border       = 'curved',            -- single, double, rounded, curved, or none
      winblend     = 0,
      width        = function() return math.floor(vim.o.columns * 0.8) end,
      height       = function() return math.floor(vim.o.lines * 0.8) end,
      -- row and col will center the float
      row          = 0.5,
      col          = 0.5,
    },
    -- hide line numbers and start in insert mode
    hide_numbers   = true,
    start_in_insert= true,
    persist_size   = true,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)    -- apply settings
  end,
  },
})

local map = vim.keymap.set
local opts = { silent = true, noremap = true }

-- Better window navigation
map('n', '<Leader>h', '<C-w>h', { desc = 'Move to left split',    unpack(opts) })
map('n', '<Leader>j', '<C-w>j', { desc = 'Move to below split',   unpack(opts) })
map('n', '<Leader>k', '<C-w>k', { desc = 'Move to above split',   unpack(opts) })
map('n', '<Leader>l', '<C-w>l', { desc = 'Move to right split',   unpack(opts) })

-- Resize splits with arrows
map('n', '<Leader><Up>',    ':resize -2<CR>',                   { desc = 'Decrease split height', unpack(opts) })
map('n', '<Leader><Down>',  ':resize +2<CR>',                   { desc = 'Increase split height', unpack(opts) })
map('n', '<Leader><Left>',  ':vertical resize -2<CR>',          { desc = 'Decrease split width',  unpack(opts) })
map('n', '<Leader><Right>', ':vertical resize +2<CR>',          { desc = 'Increase split width',  unpack(opts) })

-- Buffer navigation
map('n', '<Leader>bn', ':bnext<CR>',                              { desc = 'Next buffer',           unpack(opts) })
map('n', '<Leader>bp', ':bprevious<CR>',                          { desc = 'Previous buffer',       unpack(opts) })
map('n', '<Leader>bc', ':bdelete<CR>',                             { desc = 'Close buffer',          unpack(opts) })

-- Quick save & quit
map('n', '<Leader>w', ':write<CR>',                               { desc = 'Save current file',     unpack(opts) })
map('n', '<Leader>q', ':quit<CR>',                                { desc = 'Quit current window',   unpack(opts) })
map('n', '<Leader>WQ', ':wqall<CR>',                              { desc = 'Save all and quit',     unpack(opts) })

-- Move lines up/down in visual mode
map('v', '<Leader>j', ":m '>+1<CR>gv=gv",                         { desc = 'Move selection down',   unpack(opts) })
map('v', '<Leader>k', ":m '<-2<CR>gv=gv",                         { desc = 'Move selection up',     unpack(opts) })

-- Yank to system clipboard
map('n', '<Leader>y', '"+y',                                      { desc = 'Yank to system clipboard',           unpack(opts) })
map('v', '<Leader>y', '"+y',                                      { desc = 'Yank selection to system clipboard', unpack(opts) })
map('n', '<Leader>Y', '"+Y',                                      { desc = 'Yank entire line to clipboard',      unpack(opts) })

-- Paste over visual selection without losing register
map('v', '<Leader>p', '"_dP',                                     { desc = 'Paste over selection',    unpack(opts) })

-- Clear search highlights
map('n', '<Leader>c', ':nohlsearch<CR>',                          { desc = 'Clear search highlights',unpack(opts) })

-- Quick Telescope pickers
map('n', '<Leader>ff', '<cmd>Telescope find_files<CR>',           { desc = 'Find files',            unpack(opts) })
map('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>',            { desc = 'Live grep',             unpack(opts) })
map('n', '<Leader>fb', '<cmd>Telescope buffers<CR>',              { desc = 'List open buffers',     unpack(opts) })
map('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>',            { desc = 'Find help tags',        unpack(opts) })

-- Toggle NvimTree
map('n', '<Leader>e', ':NvimTreeToggle<CR>',                      { desc = 'Toggle file explorer',  unpack(opts) })

-- Make ESC faster (jk/ kj in insert mode)
map('i', 'jk', '<Esc>',                                           { desc = 'Exit insert mode',      unpack(opts) })
map('i', 'kj', '<Esc>',                                           { desc = 'Exit insert mode',      unpack(opts) })

-- Quick comment toggling (using Comment.nvim)
-- map('n', '<Leader>/', '<cmd>CommentToggle<CR>', opts)
-- map('v', '<Leader>/', '<esc><cmd>CommentToggle<CR>', opts)


-- End of init.lua
