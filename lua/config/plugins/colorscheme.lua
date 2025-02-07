-- Tokyo Night Theme
return {
  {
    -- https://github.com/folke/tokyonight.nvim
    'folke/tokyonight.nvim', 
    lazy = false, 
    priority = 1000, 
    opts = {
      -- transparent = true,
      style = "storm", -- "storm, night, moon, day"
    },
    config = function(_, opts)
      require('tokyonight').setup(opts) 
      vim.cmd("colorscheme tokyonight")
    end,
  },
  
	-- https://github.com/olimorris/onedarkpro.nvim
  {
    "olimorris/onedarkpro.nvim",
    enabled=false,
    opts = {
      highlights = {
        Comment = { italic = true },
        Directory = { bold = true },
        ErrorMsg = { italic = true, bold = true },
      },
      options = {
        transparency = true,
      },
      styles = {
        comments = "italic",
        keywords = "bold,italic",
        constants = "bold",
        functions = "bold",
        conditionals = "bold,italic",
        methods = "italic",
        -- types = "NONE",
        -- numbers = "NONE",
        -- strings = "NONE",
        -- operators = "NONE",
        -- variables = "NONE",
        -- parameters = "NONE",
        -- virtual_text = "NONE",
      },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts) -- Replace this with your favorite colorscheme
      vim.cmd("colorscheme onedark") -- Replace this with your favorite colorscheme
    end,
  }
}
