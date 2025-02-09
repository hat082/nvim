return {
	"folke/snacks.nvim",
	config = function()
		local snacks = require("snacks")
		snacks.setup({

			bigfile = { enabled = true },
			dashboard = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			zen = { enabled = true },

			keys = {},
		})
	end,
}
