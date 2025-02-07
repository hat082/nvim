require("config.core.keymaps")
require("config.core.options")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
