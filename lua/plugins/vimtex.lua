return {
	"lervag/vimtex",
	event = { "BufReadPre", "BufNewFile" },
	init = function()
		vim.opt.syntax = "enable"
		vim.g.vimtex_view_method = "zathura"
		vim.g["vimtex_quickfix_mode"] = 0 -- suppress error reporting on save and build
		vim.g["vimtex_mappings_enabled"] = 1 -- Ignore mappings
		vim.g["vimtex_indent_enabled"] = 1 -- Auto Indent
		vim.g["tex_flavor"] = "latex" -- how to read tex files
		vim.g["tex_indent_items"] = 1 -- turn off enumerate indent
		vim.g["tex_indent_brace"] = 1 -- turn off brace indent
		vim.g["vimtex_context_pdf_viewer"] = "zathura" -- external PDF viewer run from vimtex menu command

		vim.g["vimtex_format_enabled"] = 1
		vim.g["vimtex_log_ignore"] = { -- Error suppression:
			"Underfull",
			"Overfull",
			"specifier changed to",
			"Token not allowed in a PDF string",
		}
		vim.g["vimtex_compiler_latexmk"] = { out_dir = "build" }

		vim.opt.conceallevel = 2
		vim.g["tex_conceal"] = "abdgms"
		vim.g["vimtex_syntax_conceal"] = {
			["sections"] = 0,
			["accents"] = 0,
			["ligatures"] = 0,
			["cites"] = 0,
			["fancy"] = 0,
			["spacing"] = 0,
			["greek"] = 0,
			["math_bounds"] = 0,
			["math_delimiters"] = 0,
			["math_fracs"] = 0,
			["math_super_sub"] = 0,
			["math_symbols"] = 0,
			["styles"] = 0,
		}
	end,
}
