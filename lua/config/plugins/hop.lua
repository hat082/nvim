return {
	"smoka7/hop.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("hop").setup({
			keys = "asdfghjklqwertyuiopzxcvbnm",
			multi_windows = true,
		})
	end,
}
