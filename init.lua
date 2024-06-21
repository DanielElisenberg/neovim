vim.opt.termguicolors = true

-- CUSTOM keys
vim.g.mapleader = ' '
vim.keymap.set('v', '*y', '"*y')

-- TAB SETTINGS
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.js', '*.svelte', '*.ts', '*.html', '*.tsx', '*.jsx' },
    command = 'setlocal tabstop=2 softtabstop=2 shiftwidth=2',
})

-- lazy.nvim installion
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- THEME
    -- { "folke/tokyonight.nvim" },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        opts = {
            transparent_background = true,
        }
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {}
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local configs = require('nvim-treesitter.configs')
            configs.setup({
                ensure_installed = {
                    'c',
                    'lua',
                    'svelte',
                    'vim',
                    'rust',
                    'python',
                    'typescript',
                    'javascript',
                    'html',
                    'go'
                },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    -- UTILITIES
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local colors = {
                blue   = '#80a0ff',
                cyan   = '#79dac8',
                black  = '#080808',
                white  = '#c6c6c6',
                red    = '#ff5189',
                violet = '#d183e8',
                grey   = '#303030',
            }

            local bubbles_theme = {
                normal = {
                    a = { fg = colors.black, bg = colors.violet },
                    b = { fg = colors.white, bg = colors.grey },
                    c = { fg = colors.white },
                },

                insert = { a = { fg = colors.black, bg = colors.blue } },
                visual = { a = { fg = colors.black, bg = colors.cyan } },
                replace = { a = { fg = colors.black, bg = colors.red } },

                inactive = {
                    a = { fg = colors.white, bg = colors.black },
                    b = { fg = colors.white, bg = colors.black },
                    c = { fg = colors.white },
                },
            }

            require('lualine').setup {
                options = {
                    theme = bubbles_theme,
                    component_separators = '',
                    section_separators = { left = '', right = '' },
                },
                sections = {
                    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
                    lualine_b = { 'filename', 'branch' },
                    lualine_c = {
                        '%=', --[[ add your center compoentnts here in place of this comment ]]
                    },
                    lualine_x = {},
                    lualine_y = { 'filetype', 'progress' },
                    lualine_z = {
                        { 'location', separator = { right = '' }, left_padding = 2 },
                    },
                },
                inactive_sections = {
                    lualine_a = { 'filename' },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = { 'location' },
                },
                tabline = {},
                extensions = {},
            }
        end
    },
    {
        'akinsho/toggleterm.nvim',
        lazy = false,
        version = '*',
        config = true,
        opts = {
            direction = 'float',
            open_mapping = [[<leader>tt]],
        }
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fs', function()
                builtin.grep_string({ search = vim.fn.input('search project > ') });
            end)
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end
    },
    {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        lazy = false,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('nvim-tree').setup {
                actions = {
                    open_file = { quit_on_open = true }
                },
                view = {
                    float = {
                        enable = true,
                        open_win_config = {
                            width = 3000
                        }
                    }
                }
            }
            vim.keymap.set('n', '<leader>nt', vim.cmd.NvimTreeToggle)
        end,
    },

    -- LSP & AUTOCOMPLETION
    { 'L3MON4D3/LuaSnip' },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        init = function()
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_cmp()

            local cmp = require('cmp')
            cmp.setup({
                formatting = lsp_zero.cmp_format(),
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-x>'] = cmp.mapping.close(),
                    ['<C-h>'] = cmp.mapping.complete(),
                    ['<C-y>'] = cmp.mapping.confirm({ selected = true }),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                })
            })
        end
    },
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()
            lsp_zero.on_attach(function(_, bufnr)
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
                vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
                vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
                vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
                vim.keymap.set('n', '<space>lsp', vim.cmd.LspRestart)
                vim.api.nvim_create_autocmd('BufWritePre', {
                    callback = function()
                        vim.lsp.buf.format()
                    end,
                    buffer = bufnr,
                })
            end)

            require('mason-lspconfig').setup({
                ensure_installed = {
                    'eslint',
                    'gopls',
                    'html',
                    'htmx',
                    'lua_ls',
                    'marksman',
                    'pyright',
                    'ruff_lsp',
                    'rust_analyzer',
                    'svelte',
                    'tailwindcss',
                    'tsserver',
                },
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                    ruff_lsp = function()
                        require('lspconfig').ruff_lsp.setup {
                            init_options = {
                                settings = {
                                    formatOnSave = true,
                                    fixAll = true,
                                    args = {},
                                }
                            }
                        }
                    end,
                }
            })
        end
    },
    -- AI assistant
    {
        'Exafunction/codeium.vim',
        config = function()
            vim.g.codeium_disable_bindings = 1;
            vim.g.codeium_manual = true;
            vim.keymap.set(
                'i', '<C-g>',
                function()
                    return vim.fn['codeium#Accept']()
                end,
                { expr = true, silent = true }
            )
            vim.keymap.set(
                'i', '<C-j>',
                function()
                    return vim.fn['codeium#CycleOrComplete']()
                end,
                { expr = true, silent = true }
            )
            vim.keymap.set(
                'i', '<C-k>',
                function()
                    return vim.fn['codeium#CycleCompletions'](-1)
                end,
                { expr = true, silent = true }
            )
            vim.keymap.set(
                'i', '<C-x>',
                function()
                    return vim.fn['codeium#Clear']()
                end,
                { expr = true, silent = true }
            )
        end
    }
})

vim.cmd [[colorscheme catppuccin-macchiato]]
