return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	config = function()
		vim.g.vimtex_view_method = "zathura" -- Use zathura for PDF viewing
		vim.g.vimtex_quickfix_mode = 0 -- Disable quickfix mode
		vim.g.vimtex_compiler_latexmk = {
			executable = "latexmk",
			options = {
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
				"-output-directory=build", -- Output to the build directory
			},
			on_save = 1, -- Compile on save
		}
		vim.g.vimtex_compiler_latexrun = {
			executable = "latexrun",
			options = {
				"--max-runs=3",
				"--output-dir=build", -- Output to the build directory
			},
		}
		vim.g.vimtex_complete_enabled = 1 -- Enable completion
	end,
}
