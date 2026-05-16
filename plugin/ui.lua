-- UI: which-key, mini.nvim, alpha dashboard, bufferline, trouble, aerial,
-- oil file manager, toggleterm.

vim.pack.add({
  -- Keybind hint popup
  'https://github.com/folke/which-key.nvim',
  -- mini.nvim (icons + statusline)
  'https://github.com/echasnovski/mini.nvim',
  -- Dashboard / start screen
  'https://github.com/goolord/alpha-nvim',
  -- VSCode-style buffer tab bar
  { src = 'https://github.com/akinsho/bufferline.nvim', version = vim.version.range('*') },
  -- Problems panel (like VSCode Ctrl+Shift+M)
  'https://github.com/folke/trouble.nvim',
  -- Symbol outline sidebar
  'https://github.com/stevearc/aerial.nvim',
  -- File manager as a buffer (edit filesystem like text)
  'https://github.com/stevearc/oil.nvim',
  -- Integrated terminal toggled with Ctrl+`
  { src = 'https://github.com/akinsho/toggleterm.nvim', version = vim.version.range('*') },
})

-- which-key
require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
      C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ',
      CR = '<CR> ', Esc = '<Esc> ', ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ', NL = '<NL> ', BS = '<BS> ',
      Space = '<Space> ', Tab = '<Tab> ',
      F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>', F5 = '<F5>',
      F6 = '<F6>', F7 = '<F7>', F8 = '<F8>', F9 = '<F9>', F10 = '<F10>',
      F11 = '<F11>', F12 = '<F12>',
    },
  },
  spec = {
    { '<leader>s', group = '[S]earch' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
}

-- mini.nvim (only icons + statusline)
require('mini.icons').setup()
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

-- alpha dashboard
local startify = require 'alpha.themes.startify'
startify.file_icons.provider = 'devicons'
require('alpha').setup(startify.config)

-- bufferline
require('bufferline').setup {
  options = {
    mode = 'buffers',
    diagnostics = 'nvim_lsp',
    offsets = { { filetype = 'snacks_layout_box', text = 'Explorer' } },
    separator_style = 'slant',
    always_show_bufferline = true,
    enforce_regular_tabs = true,
  },
  highlights = {
    buffer_selected = { bold = true, italic = false },
    indicator_selected = { bold = true },
  },
}

-- trouble
require('trouble').setup {}

-- aerial
require('aerial').setup {}

-- oil
local oil = require 'oil'
oil.setup {
  columns = { 'icon' },
  keymaps = {
    ['<C-l>'] = false,
    ['<C-j>'] = false,
    ['<M-h>'] = 'actions.select_split',
    ['q'] = 'actions.close',
    ['<Esc>'] = 'actions.close',
  },
  view_options = { show_hidden = true },
}

-- toggleterm
require('toggleterm').setup {
  size = 15,
  direction = 'horizontal',
  shade_terminals = true,
}
