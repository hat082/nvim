-- Tokyo Night Theme
return {
  -- https://github.com/folke/tokyonight.nvim
  'folke/tokyonight.nvim', -- You can replace this with your favorite colorscheme
  lazy = false, -- We want the colorscheme to load immediately when starting Neovim
  priority = 1000, -- Load the colorscheme before other non-lazy-loaded plugins
  opts = {
    -- Replace this with your scheme-specific settings or remove to use the defaults
    transparent = true,
    style = "night", -- other variations "storm, night, moon, day"
  },
  config = function(_, opts)
    require('tokyonight').setup(opts) -- Replace this with your favorite colorscheme
    vim.cmd("colorscheme tokyonight") -- Replace this with your favorite colorscheme
  end
}
