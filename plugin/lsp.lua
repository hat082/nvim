-- LSP: server configuration, Mason installer, formatter (conform), linting.

vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/mason-org/mason.nvim', version = 'main' },
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  { src = 'https://github.com/j-hui/fidget.nvim', version = 'main' },
  'https://github.com/stevearc/conform.nvim',
}

-- Mason
require('mason').setup {}

-- Fidget: LSP progress notifications
require('fidget').setup {}

-- Conform: autoformat
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    typst = { 'typstfmt' },
    python = { 'ruff_format' },
  },
}

-- LSP servers to configure
local servers = {
  clangd = {
    cmd = { 'clangd' },
    rootMarkers = { '.git', 'CMakeLists.txt', 'compile_commands.json', '.clangd' },
  },
  tinymist = {
    init_options = {
      exporter = vim.fn.has 'win32' == 1 and 'pdf' or 'svg',
    },
    settings = {
      formatterMode = 'typstyle',
      semanticTokens = 'disable',
    },
  },
  lua_ls = {
    settings = { Lua = { completion = { callSnippet = 'Replace' } } },
  },
  ruff = {
    cmd = { 'ruff', 'server' },
    rootMarkers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  },
  basedpyright = {
    cmd = { vim.fn.exepath 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyrightconfig.json', 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'recommended',
          diagnosticSeverityOverrides = {
            reportUnannotatedClassAttribute = 'none',
            reportUnknownMemberType = 'none',
            reportUnusedCallResult = 'none',
          },
        },
      },
    },
  },
}

-- Map LSP server names to Mason package names where they differ
local lsp_to_mason = {
  lua_ls = 'lua-language-server',
}
local ensure_installed = vim.tbl_keys(servers)
for i, name in ipairs(ensure_installed) do
  if lsp_to_mason[name] then
    ensure_installed[i] = lsp_to_mason[name]
  end
end
vim.list_extend(ensure_installed, { 'stylua', 'clangd', 'tinymist', 'ruff', 'basedpyright' })
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

-- Apply server configs and enable them
local capabilities = require('blink.cmp').get_lsp_capabilities()
for name, cfg in pairs(servers) do
  local server = vim.tbl_deep_extend('force', {}, cfg)
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  vim.lsp.config[name] = server
  vim.lsp.enable(name)
end

-- Add filetype detection for Typst if Neovim doesn't already know .typ
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.typ',
  callback = function()
    if vim.bo.filetype == '' then
      vim.bo.filetype = 'typst'
    end
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(d)
      return d.message
    end,
  },
}
