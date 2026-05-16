-- Git: gitsigns for hunk navigation, staging, blame, and diff.
vim.pack.add({
  'https://github.com/lewis6991/gitsigns.nvim',
})

require('gitsigns').setup()

-- lazygit.nvim: lazygit integration via :LazyGit command.
vim.pack.add({
  'https://github.com/kdheepak/lazygit.nvim',
})
