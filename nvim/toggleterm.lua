-- toggleterm.lua
local toggleterm = require("toggleterm")

-- General Settings
toggleterm.setup({
  size = 20, -- Set the size of the terminal when opened
  open_mapping = [[<c-\>]], -- Default keybinding for toggling terminal
  direction = "float", -- Set the terminal direction ('horizontal', 'vertical', 'float')
  close_on_exit = true, -- Close terminal automatically when exit
  shell = "/bin/bash", -- Set your preferred shell (bash, zsh, fish, etc.)
  shade_filetypes = {},
  highlights = {
    FloatBorder = {
      guifg = "#c5c5c5",
      guibg = "#1e1e1e",
    },
    NormalFloat = {
      guifg = "#c5c5c5",
      guibg = "#1e1e1e",
    },
  },
})

-- Keybindings to open terminal in specific directions
vim.api.nvim_set_keymap("n", "<C-t>", ":ToggleTerm direction=horizontal<CR>", { noremap = true, silent = true })


