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
		})

		vim.keymap.set("n", "<leader>z", function()
			snacks.zen.zoom({
				toggles = {
					dim = true,
					git_signs = false,
					mini_diff_signs = false,
					diagnostics = false,
					inlay_hints = false,
				},
				win = {
					backdrop = false,
				},
			})
		end)
	end,
}
