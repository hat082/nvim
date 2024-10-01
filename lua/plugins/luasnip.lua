return {
	"L3MON4D3/LuaSnip",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		-- require("luasnip.loaders.from_snipmate").load({ paths = "~/.config/nvim/snippets/" })

		require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/snippets/" } })

		require("luasnip").setup({
			-- enable autotriggerd snippets
			enable_autosnippets = true,

			-- use tab to store selection
			store_selection_keys = "<Tab>",

			update_events = { "TextChanged", "TextChangedI" },
		})

		vim.keymap.set(
			"n",
			"<Leader>ll",
			'<Cmd>lua require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets/"}) print("Snippets Reloaded")<CR>',
			{ noremap = true, silent = true, desc = "Reload LuaSnip Snippets" }
		)
	end,
}
