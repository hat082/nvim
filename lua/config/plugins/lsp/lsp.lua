return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			require("mason").setup({})
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls" },
			})
			local lsp = require("lspconfig")
			local capabilites = require("blink.cmp").get_lsp_capabilities()
			lsp.lua_ls.setup({ capabilites = capabilites })
			lsp.clangd.setup({
				capabilities = capabilites,
				cmd = {
					"clangd",
					"--background-index", -- Index in the background
					"--clang-tidy", -- Enable clang-tidy diagnostics
					"--header-insertion=never", -- Disable auto-inserting headers
					"--query-driver=/nix/store/*-gcc-wrapper-*/bin/gcc",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			})
		end,
	},
}
