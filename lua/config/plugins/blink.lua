return {
  'saghen/blink.cmp',
  event = {"BufReadPre","BufNewFile"},
  dependencies = {
    'rafamadriz/friendly-snippets',
	"L3MON4D3/LuaSnip",
},
  version = '*',
  opts = {
    keymap = { preset = 'default' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer'},
    },
  },
  opts_extend = { "sources.default" }
}
