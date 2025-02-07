local keymap = vim.keymap

keymap.set("n", "<space><space>x", ":source %<CR>")
keymap.set("n", "<space>x", ":.lua<CR>")
keymap.set("v", "<space>x", ":lua<CR>")
