local map = vim.keymap.set
local opts = { silent = true }
local ok_snacks, snacks = pcall(require, 'snacks')
local ok_gitsigns, gitsigns = pcall(require, 'gitsigns')
local ok_aerial = pcall(require, 'aerial')
local ok_oil, oil = pcall(require, 'oil')
local ok_conform, conform = pcall(require, 'conform')
local ok_opencode, opencode = pcall(require, 'opencode')

local function url_in_line_at_col(line, col)
  if not line or line == '' or not col or col < 1 then
    return nil
  end

  local from = 1
  while true do
    local s, e = line:find('https?://%S+', from)
    if not s then
      return nil
    end

    if col >= s and col <= e then
      local url = line:sub(s, e)
      -- Trim punctuation that commonly trails URLs in prose/markdown.
      url = url:gsub('[%]%)%}%.,;:!%?"' .. "'" .. ']+$', '')
      return url ~= '' and url or nil
    end

    from = e + 1
  end
end

-- ============================================================
-- [[ Window Navigation & Resize ]]
-- ============================================================
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus left' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus down' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus up' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus right' })
map('n', '<C-Up>', ':resize -2<CR>', opts)
map('n', '<C-Down>', ':resize +2<CR>', opts)
map('n', '<C-Left>', ':vertical resize -2<CR>', opts)
map('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- ============================================================
-- [[ Buffer & Tab Navigation ]]
-- ============================================================
-- Buffer navigation keys are owned by bufferline.nvim in plugin specs.
map('n', '<S-q>', '<cmd>bdelete!<CR>', { silent = true, desc = 'Close buffer' })

map('n', '<Leader>1', '1gt', { silent = true, desc = 'Go to tab 1' })
map('n', '<Leader>2', '2gt', { silent = true, desc = 'Go to tab 2' })
map('n', '<Leader>3', '3gt', { silent = true, desc = 'Go to tab 3' })
map('n', '<Leader>4', '4gt', { silent = true, desc = 'Go to tab 4' })
map('n', '<Leader>5', '5gt', { silent = true, desc = 'Go to tab 5' })
map('n', '<Leader>t', '<cmd>tabnew<CR>', { silent = true, desc = 'New tab' })
map('n', '<A-q>', '<cmd>tabclose<CR>', { silent = true, desc = 'Close tab' })

-- ============================================================
-- [[ Search ]]
-- ============================================================
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('n', '<leader>nh', '<cmd>nohlsearch<CR>', { desc = '[N]o [H]ighlight — clear search' })
map('n', '<LeftMouse>', function()
  local m = vim.fn.getmousepos()
  if m.winid and m.winid ~= 0 and m.line and m.column and m.line > 0 and m.column > 0 then
    local ok_buf, bufnr = pcall(vim.api.nvim_win_get_buf, m.winid)
    if ok_buf and bufnr then
      local ok_line, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, m.line - 1, m.line, false)
      if ok_line then
        local target = url_in_line_at_col(lines[1] or '', m.column)
        if target then
          vim.ui.open(target)
          return
        end
      end
    end
  end

  -- Non-URL clicks should behave exactly like default Neovim mouse clicks.
  vim.api.nvim_feedkeys(vim.keycode '<LeftMouse>', 'n', false)
end, { desc = 'Click URL to open in browser' })

-- ============================================================
-- [[ Diagnostics ]]
-- ============================================================
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- ============================================================
-- [[ Terminal ]]
-- ============================================================
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ============================================================
-- [[ Editing ]]
-- ============================================================
map('i', 'jj', '<ESC>', { silent = true, desc = 'Exit insert mode' })
map('v', 'p', '"_dP', { silent = true, desc = 'Paste without overwriting clipboard' })
map('v', '<', '<gv', { silent = true, desc = 'Dedent and stay in visual mode' })
map('v', '>', '>gv', { silent = true, desc = 'Indent and stay in visual mode' })
map('n', '<leader>$', '$', { silent = true, desc = 'Jump to end of line' })
map('n', 'S', ':%s//g<Left><Left>', { desc = 'Search and replace in buffer' })
map('n', '<leader>y', function()
  -- Walk up the treesitter tree to find a fenced_code_block node.
  -- The markdown parser is bundled with Neovim 0.10+, no plugin required.
  local node = vim.treesitter.get_node()
  while node and node:type() ~= 'fenced_code_block' do
    node = node:parent()
  end
  if not node then
    vim.notify('Not inside a fenced code block', vim.log.levels.WARN)
    return
  end
  -- The grammar puts the actual code lines in a code_fence_content child.
  for child in node:iter_children() do
    if child:type() == 'code_fence_content' then
      local text = vim.treesitter.get_node_text(child, 0)
      vim.fn.setreg('+', text)
      vim.fn.setreg('"', text)
      vim.notify('Code block copied to clipboard', vim.log.levels.INFO)
      return
    end
  end
  vim.notify('Code block is empty', vim.log.levels.WARN)
end, { desc = '[Y]ank fenced code block to clipboard' })

-- ============================================================
-- [[ Snacks Picker ]]
-- ============================================================
do
  if ok_snacks then
    map('n', '<leader>sh', function()
      snacks.picker.help()
    end, { desc = '[S]earch [H]elp' })
    map('n', '<leader>sk', function()
      snacks.picker.keymaps()
    end, { desc = '[S]earch [K]eymaps' })
    map('n', '<leader>sc', function()
      snacks.picker.commands()
    end, { desc = '[S]earch [C]ommands' })
    map('n', '<leader>sb', function()
      snacks.picker.pickers()
    end, { desc = '[S]earch [B]uiltins' })
    map('n', '<leader>sf', function()
      snacks.picker.files()
    end, { desc = '[S]earch [F]iles' })
    map('n', '<leader>e', function()
      snacks.explorer.open()
    end, { desc = '[E]xplorer open tree' })
    map('n', '<leader>ff', function()
      snacks.picker.smart()
    end, { desc = '[S]earch [F]iles' })
    map('n', '<leader>ss', function()
      snacks.picker.pickers()
    end, { desc = '[S]earch [S]elect Snacks' })
    map({ 'n', 'x' }, '<leader>sw', function()
      snacks.picker.grep_word()
    end, { desc = '[S]earch current [W]ord' })
    map('n', '<leader>fg', function()
      snacks.picker.grep()
    end, { desc = '[S]earch by [G]rep' })
    map('n', '<leader>fp', function()
      snacks.picker.projects()
    end, { desc = '[S]earch [P]rojects' })
    map('n', '<leader>sd', function()
      snacks.picker.diagnostics()
    end, { desc = '[S]earch [D]iagnostics' })
    map('n', '<leader>sr', function()
      snacks.picker.resume()
    end, { desc = '[S]earch [R]esume' })
    map('n', '<leader>s.', function()
      snacks.picker.recent()
    end, { desc = '[S]earch Recent Files ("." for repeat)' })
    map('n', '<leader><leader>', function()
      snacks.picker.buffers()
    end, { desc = '[ ] Find existing buffers' })
    map('n', '<leader>/', function()
      snacks.picker.lines {}
    end, { desc = '[/] Fuzzily search in current buffer' })
    map('n', '<leader>s/', function()
      snacks.picker.grep_buffers()
    end, { desc = '[S]earch [/] in Open Files' })
    map('n', '<leader>sn', function()
      snacks.picker.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
    map('n', '<C-\\>', function()
      snacks.zen()
    end, { desc = 'Toggle [Z]en mode' })
  end
end

-- ============================================================
-- Git: gitsigns.nvim + lazygit.nvim
do
  if ok_gitsigns then
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Stage buffer' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Reset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview hunk' })
    map('n', '<leader>hb', function()
      gitsigns.blame_line { full = true }
    end, { desc = 'Blame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff this' })
    map('n', '<leader>gb', gitsigns.toggle_current_line_blame, { desc = 'Toggle git blame' })
    map('n', '<leader>gw', gitsigns.toggle_word_diff, { desc = 'Toggle word diff' })
  end
end
map('n', '<leader>gg', '<cmd>Lazygit<CR>', { desc = 'Open lazygit' })

-- ============================================================
-- [[ UI: Bufferline, Trouble, Aerial, Oil, ToggleTerm ]]
-- ============================================================
map('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })
map('n', '<leader>d', '<cmd>bdelete<CR>', { desc = 'Close buffer' })
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (Trouble)' })
map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer Diagnostics' })
map('n', '<leader>cs', '<cmd>Trouble symbols toggle<CR>', { desc = 'Symbols (Trouble)' })

do
  if ok_aerial then
    map('n', '<leader>v', '<cmd>AerialToggle!<CR>', { desc = 'Toggle outline [V]iew' })
  end
end

do
  if ok_oil then
    map('n', '<leader>o', oil.open, { desc = 'open oil' })
  end
end

map('n', '<C-`>', function()
  local dir = vim.fn.expand '%:p:h'
  if dir == '' or vim.fn.isdirectory(dir) == 0 then
    local cwd = vim.uv.cwd()
    dir = cwd or '.'
  end
  vim.cmd('ToggleTerm dir=' .. vim.fn.fnameescape(dir))
end, { desc = 'Toggle terminal (buffer directory)' })

-- ============================================================
-- [[ LSP ]]
-- ============================================================
map('', '<leader>=', function()
  if ok_conform then
    conform.format { async = true, lsp_format = 'fallback' }
  end
end, { desc = '[F]ormat buffer' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map_lsp = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map_lsp('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map_lsp('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    if ok_snacks then
      map_lsp('grr', function()
        snacks.picker.lsp_references()
      end, '[G]oto [R]eferences')
      map_lsp('gri', function()
        snacks.picker.lsp_implementations()
      end, '[G]oto [I]mplementation')
      map_lsp('grd', function()
        snacks.picker.lsp_definitions()
      end, '[G]oto [D]efinition')
      map_lsp('gO', function()
        snacks.picker.lsp_symbols()
      end, 'Open Document Symbols')
      map_lsp('gW', function()
        snacks.picker.lsp_workspace_symbols()
      end, 'Open Workspace Symbols')
      map_lsp('grt', function()
        snacks.picker.lsp_type_definitions()
      end, '[G]oto [T]ype Definition')
    end
    map_lsp('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local hl_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end,
})

-- ============================================================
-- [[ C/C++ Build & Run ]]
-- ============================================================
map('n', '<F7>', '<cmd>make<CR>', { desc = 'Build C/C++ with make' })
map('n', '<leader>br', function()
  local filename = vim.fn.expand '%:t'
  local ext = vim.fn.expand '%:e'
  local basedir = vim.fn.expand '%:p:h'
  local cmd
  if ext == 'c' then
    local bin = basedir .. '/' .. filename:gsub('%.c$', '')
    cmd = string.format('gcc -o "%s" "%s" && "%s"', bin, vim.fn.fnameescape(vim.fn.expand '%:p'), bin)
  elseif ext == 'cpp' or ext == 'cc' or ext == 'cxx' then
    local bin = basedir .. '/' .. filename:gsub('%..+$', '')
    cmd = string.format('g++ -o "%s" "%s" && "%s"', bin, vim.fn.fnameescape(vim.fn.expand '%:p'), bin)
  end
  if cmd then
    vim.cmd('ToggleTerm cmd=' .. vim.fn.fnameescape(cmd))
  else
    vim.notify('Not a C/C++ file', vim.log.levels.WARN)
  end
end, { desc = '[B]uild and [R]un current C/C++ file' })

-- ============================================================
-- [[ Tools & Plugins ]]
-- ============================================================
map('n', '<leader>a', ':Alpha<CR>', { silent = true, desc = 'Open [A]lpha dashboard' })
map('n', '<leader>p', '<cmd>PasteImage<CR>', { silent = true, desc = '[P]aste image from clipboard' })
map('n', '<F5>', '<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>', { silent = true, desc = 'Toggle Undotree' })

-- ============================================================
-- [[ OpenCode ]]
-- ============================================================
do
  if ok_opencode then
    map({ 'n', 'x' }, '<leader>oa', function()
      opencode.chat.start()
    end, { desc = '[O]pen[C]ode: [A]sk' })
    map({ 'n', 'x' }, '<leader>og', function()
      opencode.chat.infer()
    end, { desc = '[O]pen[C]ode: [G]enerate' })
  end
end
