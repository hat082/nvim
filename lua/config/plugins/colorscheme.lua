-- Tokyo Night Theme
return {
	--

	{
		"shaunsingh/nord.nvim",
		enabled = true,
		priority = 1000,
		config = function()
			-- Example config in lua
			vim.g.nord_contrast = false
			vim.g.nord_borders = false
			vim.g.nord_disable_background = false
			vim.g.nord_italic = true
			vim.g.nord_uniform_diff_background = true
			vim.g.nord_bold = false
			vim.cmd("colorscheme nord")
		end,
	},

	{
		-- https://github.com/folke/tokyonight.nvim
		"folke/tokyonight.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			style = "storm", -- "storm, night, moon, day"
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd("colorscheme tokyonight")
		end,
	},

	-- https://github.com/olimorris/onedarkpro.nvim
	{
		"olimorris/onedarkpro.nvim",
		enabled = false,
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
	},
}
