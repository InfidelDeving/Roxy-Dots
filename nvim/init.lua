local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug('folke/tokyonight.nvim')
Plug('kyazdani42/nvim-tree.lua')
Plug('kyazdani42/nvim-web-devicons')
Plug('romgrk/barbar.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-nvim-lsp-signature-help')
Plug('hrsh7th/vim-vsnip')
Plug('rafamadriz/friendly-snippets')
Plug('hrsh7th/vim-vsnip-integ')
Plug('akinsho/toggleterm.nvim')

vim.call('plug#end')

-- Ensure Neovim looks in the lua folder for custom config
package.path = vim.fn.stdpath('config') .. "/lua/?.lua;" .. package.path

-- Load Lua modules from the lua/ directory
dofile("/home/infidel/.config/nvim/common.lua")
dofile("/home/infidel/.config/nvim/theme.lua")
dofile("/home/infidel/.config/nvim/vimtree.lua")
dofile("/home/infidel/.config/nvim/barbar.lua")
dofile("/home/infidel/.config/nvim/lua_line.lua")
dofile("/home/infidel/.config/nvim/lsp.lua")
dofile("/home/infidel/.config/nvim/cmp.lua")
dofile("/home/infidel/.config/nvim/toggleterm.lua")
