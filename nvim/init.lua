local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
--vim.api.nvim_set_keymap('n', '<C-q>', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-c>', 'ygv', {noremap = true, silent = true})

local function confirm_quit()
    -- Check if the current buffer is modified
    if vim.api.nvim_buf_get_option(0, 'modified') then
        local choice = vim.fn.confirm("Save changes?", "&Yes\n&No", 2)
        if choice == 1 then
            -- Save and quit
            vim.cmd('wq!')
        elseif choice == 2 then
            -- Quit without saving
            vim.cmd('q!')
        end
    else
        -- Quit directly if there are no unsaved changes
        vim.cmd('q')
    end
end

-- Separate keymap for Visual mode
vim.keymap.set('v', '<C-q>', confirm_quit, { noremap = true, silent = true })
vim.keymap.set('i', '<C-q>', function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', true); confirm_quit() end, { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F7>', [[:%!clang-format -style=file<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F8>', [[:%!shfmt -i 4 -w %<CR>]], { noremap = true, silent = true })

-- require("lazy").setup(plugins, opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--vim.api.nvim_set_keymap('n', '^X@sq', ':startinsert<CR>', {noremap = true, silent = true})
vim.api.nvim_create_autocmd("ExitPre", {
	group = vim.api.nvim_create_augroup("Exit", { clear = true }),
	command = "set guicursor=a:ver90",
	desc = "Set cursor back to beam when leaving Neovim."
})
-- Plugin management
require('lazy').setup({
    {'nvim-lualine/lualine.nvim'},
    {'navarasu/onedark.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}},
    {'nvim-tree/nvim-tree.lua'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-lua/plenary.nvim'}, 
    'github/copilot.vim', 
    'tpope/vim-fugitive', {
    'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    { 'folke/which-key.nvim', opts = {} },
    { 'neovim/nvim-lspconfig'},
    "williamboman/mason.nvim"
    -- 'ms-jpq/coq_nvim',
    -- 'ms-jpq/coq.artifacts',
    -- 'ms-jpq/coq.thirdparty',
})

--require'lspconfig'.ruff.setup{}
require'lspconfig'.ruff_lsp.setup{}
require'lspconfig'.clangd.setup{}
--require("coq_3p") {
--  { src = "copilot", short_name = "COP", accept_key = "<c-f>" },
--}
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',

        component_separators = {
            left = '',
            right = ''
        },
        section_separators = {
            left = '',
            right = ''
        },
        disabled_filetypes = {
            statusline = {},
            winbar = {}
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000
        }
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
require("ibl").setup()
require('onedark').setup {
    style = 'darker'
}
require('onedark').load()


-- Completion key mappings
vim.api.nvim_set_keymap('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], {
    expr = true
})
vim.api.nvim_set_keymap('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], {
    expr = true
})
vim.api.nvim_set_keymap('i', '<C-space>', [[coc#refresh()]], {
    silent = true,
    expr = true
})
-- Other key mappings
vim.api.nvim_set_keymap('n', '<C-o>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Settings
-- vim.g.deoplete#enable_at_startup = 1

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


-- Map ';' to open fzf Files
-- vim.api.nvim_set_keymap('n', ';', [[<Cmd>Files<CR>]], {})
local builtin = require('telescope.builtin')
vim.keymap.set('n', ';', builtin.find_files, {})
vim.keymap.set('n', '.', builtin.live_grep, {})

local keymap = vim.api.nvim_set_keymap
local set = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<F2>', ':NvimTreeOpen<CR>', { noremap = true, silent = true })
local function close_all_nvim_tree()
    local current_tab = vim.api.nvim_get_current_tabpage()
    local tabs = vim.api.nvim_list_tabpages()

    for _, tab in ipairs(tabs) do
        vim.api.nvim_set_current_tabpage(tab)
        -- Replace 'NvimTreeClose' with the appropriate command to close NvimTree
        vim.cmd('NvimTreeClose')
    end

    vim.api.nvim_set_current_tabpage(current_tab)
end
vim.api.nvim_set_keymap('n', '<F3>', '', {expr = true, noremap = true, callback = close_all_nvim_tree})

-- Cut, copy, and paste using Ctrl-X/C/V
set('v', '<C-x>', '"+x', opts)  -- Cut to clipboard
set('v', '<C-c>', '"+y', opts)  -- Copy to clipboard

-- In visual mode, overwrite the selected text with clipboard contents
set('v', '<C-v>', '"_dP', opts)
-- In normal mode, paste from clipboard at cursor position
set('n', '<C-v>', '"+p', opts)
-- In insert mode, paste from clipboard
set('i', '<C-v>', '<C-R>+', opts)

-- Ctrl-Z for undo
set('n', '<C-z>', 'u', opts)
set('i', '<C-z>', '<C-O>u', opts)
-- Ctrl-S for save
set('n', '<C-s>', ':update<CR>', opts)
set('v', '<C-s>', '<C-C>:update<CR>', opts)
set('i', '<C-s>', '<Esc>:update<CR>gi', opts)

-- Ctrl-Q for block visual mode
set('n', '<C-Q>', '<C-V>', opts)

-- Ctrl-A for select all
set('n', '<C-A>', 'ggVG', opts)
set('i', '<C-A>', '<Esc>ggVG', opts)
set('v', '<C-A>', 'ggVG', opts)

-- Shift Arrow keys for visual selection
set('n', '<S-Up>', 'v<Up>', opts)
set('n', '<S-Down>', 'v<Down>', opts)
set('n', '<S-Left>', 'v<Left>', opts)
set('n', '<S-Right>', 'v<Right>', opts)
set('v', '<S-Up>', '<Up>', opts)
set('v', '<S-Down>', '<Down>', opts)
set('v', '<S-Left>', '<Left>', opts)
set('v', '<S-Right>', '<Right>', opts)
set('i', '<S-Up>', '<Esc>v<Up>', opts)
set('i', '<S-Down>', '<Esc>v<Down>', opts)
set('i', '<S-Left>', '<Esc>v<Left>', opts)
set('i', '<S-Right>', '<Esc>v<Right>', opts)

-- In terminal, Ctrl-Shift is not distinguishable, so it's often mapped as 'g' prefix
set('n', '<C-d>', ':redo<CR>', opts)
-- Backspace to delete whole selection in Visual mode
set('v', '<BS>', 'd', opts)

local function smart_left_arrow_insert()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up><End>', true, true, true), 'n', true)
        return ''
    else
        return vim.api.nvim_replace_termcodes('<Left>', true, true, true)
    end
end

local function smart_left_arrow_normal()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end

local function smart_right_arrow_insert()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()

    if col >= #line then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down><Home>', true, true, true), 'n', true)
        return ''
    else
        return vim.api.nvim_replace_termcodes('<Right>', true, true, true)
    end
end

local function smart_right_arrow_normal()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local line = vim.api.nvim_get_current_line()

    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end
-- Insert Mode: Left Arrow
vim.api.nvim_set_keymap('i', '<Left>', '', {expr = true, noremap = true, callback = smart_left_arrow_insert})
-- Normal Mode: Left Arrow
vim.api.nvim_set_keymap('n', '<Left>', '', {noremap = true, callback = smart_left_arrow_normal})

-- Insert Mode: Right Arrow
vim.api.nvim_set_keymap('i', '<Right>', '', {expr = true, noremap = true, callback = smart_right_arrow_insert})

-- Normal Mode: Right Arrow
vim.api.nvim_set_keymap('n', '<Right>', '', {noremap = true, callback = smart_right_arrow_normal})

-- Basic settings
vim.o.nocompatible = true
vim.o.showmatch = true
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.hlsearch = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.autoindent = true
-- vim.o.number = true
vim.o.wildmode = "longest,list"
vim.o.backup = false
vim.o.swapfile = false
vim.o.wrap = true
vim.o.number = true
vim.o.relativenumber = false
vim.o.clipboard = ''
vim.o.breakindent=true
vim.o.showbreak='↳ '

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, {
    desc = 'Search [G]it [F]iles'
})
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, {
    desc = '[S]earch [F]iles'
})
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, {
    desc = '[S]earch [H]elp'
})
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, {
    desc = '[S]earch current [W]ord'
})
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, {
    desc = '[S]earch by [G]rep'
})
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', {
    desc = '[S]earch by [G]rep on Git Root'
})
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, {
    desc = '[S]earch [D]iagnostics'
})
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, {
    desc = '[S]earch [R]esume'
})

vim.api.nvim_create_user_command('GrepCurrentFile', function()
    require('telescope.builtin').current_buffer_fuzzy_find()
end, {})


vim.api.nvim_set_keymap('n', '<C-f>', ':GrepCurrentFile<CR>', {
    noremap = true,
    silent = true
})
vim.api.nvim_set_keymap('i', '<C-f>', '<Esc>:GrepCurrentFile<CR>i', {
    noremap = true,
    silent = true
})


-- require('neodev').setup()

-- Uncomment the next line to set an 80 column border for good coding style
-- vim.o.colorcolumn = "80"

-- Filetype and syntax settings
vim.cmd [[filetype plugin indent on]]
vim.cmd [[syntax enable]]

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {"c", "lua", "vim", "vimdoc", "query", "markdown", "latex", "python"},
    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)
