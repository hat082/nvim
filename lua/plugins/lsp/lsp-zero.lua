return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",

	dependencies = {
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/nvim-cmp" },
		{ "L3MON4D3/LuaSnip" },
	},

	config = function()
		local lsp_zero = require("lsp-zero")

		lsp_zero.on_attach(function(client, bufnr)
			-- see :help lsp-zero-keybindings
			-- to learn the available actions
			lsp_zero.default_keymaps({ buffer = bufnr })
			local opts = { buffer = bufnr }
			--   l = { "<cmd>lua vim.diagnostic.open_float()<CR>", "line diagnostics" },
			--   n = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "next diagnostic" },
			--   p = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "previous diagnostic" },
			--   R = { "<cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
			--   b = { "<cmd>Telescope diagnostics bufnr=0<CR>", "buffer diagnostics" },
			--   c = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "code action" },
			--   d = { "<cmd>Telescope lsp_definitions<CR>", "definition" },
			--   D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "declaration" },
			--   h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "help" },
			--   i = { "<cmd>Telescope lsp_implementations<CR>", "implementations" },
			--   k = { "<cmd>LspStop<CR>", "kill lsp" },
			--   l = { "<cmd>lua vim.diagnostic.open_float()<CR>", "line diagnostics" },
			--   n = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "next diagnostic" },
			--   p = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "previous diagnostic" },
			--   r = { "<cmd>Telescope lsp_references<CR>", "references" },
			--   s = { "<cmd>LspRestart<CR>", "restart lsp" },
			--   t = { "<cmd>LspStart<CR>", "start lsp" },
			--   R = { "<cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
			--   T = { "<cmd>Telescope lsp_type_definitions<CR>", "type definition" },
		end)

		lsp_zero.set_sign_icons({
			error = "✘",
			warn = "▲",
			hint = "⚑",
			info = "»",
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
		local servers = {
			clangd = {
				cmd = { "clangd", "--query-driver=/nix/store/*gcc-wrapper*/bin/g++" },
			},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs

			lua_ls = {
				-- cmd = {...},
				-- filetypes = { ...},
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						-- diagnostics = { disable = { 'missing-fields' } },
					},
				},
			},
		}

		-- to learn how to use mason.nvim
		-- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guide/integrate-with-mason-nvim.md
		require("mason").setup({})
		require("mason-lspconfig").setup({

			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,

				-- clangd = function()
				-- 	require("lspconfig").clangd.setup({
				-- 		cmd = { "clangd" },
				-- 		capabilities = {
				-- 			offsetEncoding = "utf-8",
				-- 		},
				-- 	})
				-- end,
			},
		})

		-- Globally configure all LSP floating preview popups (like hover, signature help, etc)
		local open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded" -- Set border to rounded
			return open_floating_preview(contents, syntax, opts, ...)
		end
	end,
}
