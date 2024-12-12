-- Abbreviations used in this article and the LuaSnip docs
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

-- ----------------------------------------------------------------------------
-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
--
-- Some LaTeX-specific conditional expansion functions (requires VimTeX)

local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex_utils.in_text = function()
	return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
	return vim.fn["vimtex#syntax#in_comment"]() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
	return tex_utils.in_env("equation")
end
tex_utils.in_itemize = function() -- itemize environment detection
	return tex_utils.in_env("itemize")
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
	return tex_utils.in_env("tikzpicture")
end

-------------------------------------------------------------------------------

local get_visual = function(args, parent)
	if #parent.snippet.env.LS_SELECT_RAW > 0 then
		return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
	else -- If LS_SELECT_RAW is empty, return a blank insert node
		return sn(nil, i(1))
	end
end

------------------------------------------------------------------------------

-- Function to create a LuaSnip snippet
local function create_snippet(shortcut, snippet_text)
	-- Create a snippet node with the given shortcut and text
	local snippet = s({ trig = shortcut, snippetType = "autosnippet" }, {
		t(snippet_text),
	}, { condition = tex_utils.in_mathzone })
	return snippet
end

-------------------------------------------------------------------------------
--
return {
	-- snippet to insert alpha beta gamma in math mode
	-- using autosnippet doesn't need to enter expand
	create_snippet("al ", "\\alpha "),
	create_snippet("be ", "\\beta"),
	create_snippet("ga ", "\\gamma "),
	create_snippet("de ", "\\delta "),
	create_snippet("ep ", "\\epsilon "),
	create_snippet("ze ", "\\zeta "),
	create_snippet("et ", "\\eta "),
	create_snippet("th ", "\\theta "),
	create_snippet("io ", "\\iota "),
	create_snippet("ka ", "\\kappa "),
	create_snippet("la ", "\\lambda "),
	create_snippet("mu ", "\\mu "),
	create_snippet("nu ", "\\nu "),
	create_snippet("xi ", "\\xi "),
	create_snippet("pi ", "\\pi "),
	create_snippet("rh ", "\\rho "),
	create_snippet("si ", "\\sigma "),
	create_snippet("ta ", "\\tau "),
	create_snippet("up ", "\\upsilon "),
	create_snippet("ph ", "\\phi "),
	create_snippet("ch ", "\\chi "),
	create_snippet("ps ", "\\psi "),
	create_snippet("om ", "\\omega "),

	create_snippet("cd ", "\\cdot "),
	create_snippet("ti ", "\\times "),

	-- fraction using fmt
	s(
		{ trig = "//", dscr = "Create a frac", snippetType = "autosnippet" },
		-- Example: using fmt's `delimiters` key to manually specify angle brackets
		fmt(
			"\\frac{<>}{<>}",
			{
				i(1),
				i(2),
			},
			{ delimiters = "<>" } -- manually specifying angle bracket delimiters
		)
	),

	-- fraction using fmta
	s(
		{ trig = "^sec", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
     \section{<>}
     \label{sec:<>}

   ]],
			{ i(1), rep(1) }
		)
	),

	-- subsection
	s(
		{ trig = "^sub", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
     \subsection{<>}
     \label{sub:<>}

   ]],
			{ i(1), rep(1) }
		)
	),

	-- subsubsection
	s(
		{ trig = "^ssub", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
     \subsubsection{<>}
     \label{ssub:<>}

   ]],
			{ i(1), rep(1) }
		)
	),

	-- scientific notation \times 10^{}
	s(
		{ trig = "en", snippetType = "autosnippet" },
		-- Using a multiline string for the equation snippet
		fmta([[\times 10^{<>} ]], { i(1) }),
		{ condition = tex_utils.in_mathzone }
	),

	-- units: \,\mathrm{(<>)}
	s(
		{ trig = "rm", snippetType = "autosnippet" },
		-- Using a multiline string for the equation snippet
		fmta([[\,\mathrm{<>} ]], { i(1) }),
		{ condition = tex_utils.in_mathzone }
	),

	-- a custom listing cmd \lst{}
	s(
		{ trig = "^ls", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
      \lst{<>}

   ]],
			{ i(1) }
		)
	),

	-- a custom figure command \fig{}
	s(
		{ trig = "^fi", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
      \fig[<>]{<>}

   ]],
			{ i(1), i(2) }
		)
	),

	-- a custom figure command that prints figures side by side \sbs{}
	s(
		{ trig = "^sb", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
      \sbs{<>}

   ]],
			{ i(1) }
		)
	),

	-- create \begin{} \end{} snippet
	s(
		{ trig = "^beg", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		fmta(
			[[
      \begin{<>}
          <>
      \end{<>}
    ]],
			{
				i(1),
				i(2),
				rep(1), -- this node repeats insert node i(1)
			}
		)
	),

	-- create \begin{equation} snippet
	s(
		{ trig = "^dm", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		fmta(
			[[
      \begin{equation}
      <>
      \end{equation}

      ]],
			{
				i(1),
			}
		)
	),

	-- create \begin{equation} snippet
	s(
		{ trig = "^eq", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		fmta(
			[[
      \begin{equation*}
      <>
      \end{equation*}

      ]],
			{
				i(1),
			}
		)
	),

	-- Example use of insert node placeholder text
	-- creating a hyperref href{}{}
	s(
		{ trig = "hr", dscr = "The hyperref package's href{}{} command (for url links)" },
		fmta([[\href{<>}{<>}]], {
			i(1, "url"),
			i(2, "display name"),
		})
	),

	-- Example: italic font implementing visual selection
	-- textit{}
	s(
		{ trig = "ti", dscr = "Expands 'ti' into LaTeX's textit{} command." },
		fmta("\\textit{<>}", {
			-- dynamic_node: see :help luasnip-dynamicnode
			d(1, get_visual),
		})
	),

	-- texttt{}
	s(
		{ trig = "tt", dscr = "Expands 'tt' into LaTeX's texttt{} command." },
		fmta("\\texttt{<>}", {
			-- dynamic_node: see :help luasnip-dynamicnode
			d(1, get_visual),
		})
	),

	-- Cref{}
	s(
		{ trig = "re", dscr = "Expands 're' into LaTeX's Cref command." },
		fmta("\\Cref{<>}", {
			-- dynamic_node: see :help luasnip-dynamicnode
			d(1, get_visual),
		})
	),

	-- cite{}
	s(
		{ trig = "ci", dscr = "Expands 'ci' into LaTeX's cite{} command." },
		fmta("\\cite{<>}", {
			-- dynamic_node: see :help luasnip-dynamicnode
			d(1, get_visual),
		})
	),

	-- inline math block, but activates only if there are no characters directly connected to ma.
	s(
		{ trig = "([^%a])mk", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		fmta("<>$<>$", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		})
	),

	-- expands into pi@raspberrypi:~ $
	s(
		{ trig = "^pi", wordTrig = false, regTrig = true },
		-- Using a multiline string for the equation snippet
		fmta(
			[[
      pi@raspberrypi:~ $
      ]],
			{}
		)
	),

	-- create subscripts
	s(
		{ trig = "([%a%d%)%]%}])_", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		})
	),
	-- create superscripts
	s(
		{ trig = "([%a%d%)%]%}])pw", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		})
	),
}
