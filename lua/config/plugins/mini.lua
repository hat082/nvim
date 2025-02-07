return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.statusline").setup({ use_icons = true })
		require("mini.ai").setup()
		require("mini.surround").setup()
		require("mini.pairs").setup()
		require("mini.files").setup({
			mappings = {
				trim_left = "H",
				trim_right = "L",
			},
			windows = {
				width_focus = 30,
				width_nofocus = 30,
			},
		})
		vim.keymap.set("n", "<leader>e", ":lua MiniFiles.open()<CR>")

		-- [ ( { } ) ]
	end,
}
