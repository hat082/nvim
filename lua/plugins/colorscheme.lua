-- Tokyo Night Theme
return {

	-- -- https://github.com/folke/tokyonight.nvim
	-- 'folke/tokyonight.nvim', -- You can replace this with your favorite colorscheme
	-- lazy = false, -- We want the colorscheme to load immediately when starting Neovim
	-- priority = 1000, -- Load the colorscheme before other non-lazy-loaded plugins
	-- opts = {
	--   -- Replace this with your scheme-specific settings or remove to use the defaults
	--   transparent = true,
	--   style = "night", -- other variations "storm, night, moon, day"
	-- },
	-- config = function(_, opts)
	--   require('tokyonight').setup(opts) -- Replace this with your favorite colorscheme
	--   vim.cmd("colorscheme tokyonight") -- Replace this with your favorite colorscheme
	-- end,

	-- https://github.com/olimorris/onedarkpro.nvim
	"olimorris/onedarkpro.nvim",
	priority = 1000, -- Ensure it loads first

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
