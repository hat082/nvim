local map = vim.keymap.set
local opts = { silent = true }
local ok_snacks, snacks = pcall(require, 'snacks')
local ok_gitsigns, gitsigns = pcall(require, 'gitsigns')
local ok_aerial = pcall(require, 'aerial')
local ok_oil, oil = pcall(require, 'oil')
local ok_conform, conform = pcall(require, 'conform')
local ok_opencode, opencode = pcall(require, 'opencode')

local function hover_in_vsplit()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params(0, 'utf-8')

  vim.lsp.buf_request(bufnr, 'textDocument/hover', params, function(err, result, ctx)
    if err or not result or not result.contents then
      vim.notify('No hover information', vim.log.levels.INFO)
      return
    end

    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    if vim.tbl_isempty(lines) then
      vim.notify('No hover information', vim.log.levels.INFO)
      return
    end

    vim.cmd 'vnew'
    local hover_buf = vim.api.nvim_get_current_buf()
    vim.bo[hover_buf].buftype = 'nofile'
    vim.bo[hover_buf].bufhidden = 'wipe'
    vim.bo[hover_buf].swapfile = false
    vim.bo[hover_buf].modifiable = true
    vim.bo[hover_buf].filetype = 'markdown'
    vim.api.nvim_buf_set_lines(hover_buf, 0, -1, false, lines)
    vim.bo[hover_buf].modifiable = false

    local name = 'lsp-hover'
    if ctx and ctx.client_id then
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client then
        name = name .. '-' .. client.name
      end
    end
    vim.api.nvim_buf_set_name(hover_buf, name)
  end)
end

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
map('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { desc = 'Move focus left' })
map('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { desc = 'Move focus down' })
map('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { desc = 'Move focus up' })
map('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { desc = 'Move focus right' })
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
map('n', '<leader>lq', vim.diagnostic.setqflist, { desc = 'Open [L]SP diagnostics [Q]uickfix list' })

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
-- [[ Find & Search ]]
-- ============================================================
do
  if ok_snacks then
    map('n', '<leader><space>', function()
      snacks.picker.files()
    end, { desc = '[F]ind [F]iles' })
    map('n', '<leader>ff', function()
      snacks.picker.files()
    end, { desc = '[F]ind [F]iles' })
    map('n', '<leader>fs', function()
      snacks.picker.smart()
    end, { desc = '[F]ind [S]mart' })
    map('n', '<leader>fb', function()
      snacks.picker.buffers()
    end, { desc = '[F]ind [B]uffers' })
    map('n', '<leader>fr', function()
      snacks.picker.recent()
    end, { desc = '[F]ind [R]ecent files' })
    map('n', '<leader>fp', function()
      snacks.picker.projects()
    end, { desc = '[F]ind [P]rojects' })
    map('n', '<leader>fn', function()
      snacks.picker.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[F]ind [N]eovim files' })
    map('n', '<leader>sh', function()
      snacks.picker.help()
    end, { desc = '[S]earch [H]elp' })
    map('n', '<leader>sk', function()
      snacks.picker.keymaps()
    end, { desc = '[S]earch [K]eymaps' })
    map('n', '<leader>sc', function()
      snacks.picker.commands()
    end, { desc = '[S]earch [C]ommands' })
    map('n', '<leader>sp', function()
      snacks.picker.pickers()
    end, { desc = '[S]earch [P]ickers' })
    map('n', '<leader>e', function()
      snacks.explorer.open()
    end, { desc = '[E]xplorer open tree' })
    map('n', '<leader>ss', function()
      snacks.picker.grep()
    end, { desc = '[S]earch [S]tring in project' })
    map({ 'n', 'x' }, '<leader>sw', function()
      snacks.picker.grep_word()
    end, { desc = '[S]earch current [W]ord' })
    map('n', '<leader>sd', function()
      snacks.picker.diagnostics()
    end, { desc = '[S]earch [D]iagnostics' })
    map('n', '<leader>sr', function()
      snacks.picker.resume()
    end, { desc = '[S]earch [R]esume' })
    map('n', '<leader>/', function()
      snacks.picker.lines {}
    end, { desc = '[/] Fuzzily search in current buffer' })
    map('n', '<leader>so', function()
      snacks.picker.grep_buffers()
    end, { desc = '[S]earch [O]pen buffers' })
    map('n', '<C-\\>', function()
      snacks.zen()
    end, { desc = 'Toggle [Z]en mode' })
  end
end

-- ============================================================
-- Git: gitsigns.nvim + lazygit.nvim
do
  if ok_gitsigns then
    map('n', '<leader>gs', gitsigns.stage_hunk, { desc = '[G]it [S]tage hunk' })
    map('n', '<leader>gr', gitsigns.reset_hunk, { desc = '[G]it [R]eset hunk' })
    map('n', '<leader>gS', gitsigns.stage_buffer, { desc = '[G]it [S]tage buffer' })
    map('n', '<leader>gR', gitsigns.reset_buffer, { desc = '[G]it [R]eset buffer' })
    map('n', '<leader>gp', gitsigns.preview_hunk, { desc = '[G]it [P]review hunk' })
    map('n', '<leader>gb', function()
      gitsigns.blame_line { full = true }
    end, { desc = '[G]it [B]lame line' })
    map('n', '<leader>gd', gitsigns.diffthis, { desc = '[G]it [D]iff this' })
    map('n', '<leader>gB', gitsigns.toggle_current_line_blame, { desc = '[G]it toggle [B]lame' })
    map('n', '<leader>gw', gitsigns.toggle_word_diff, { desc = '[G]it [W]ord diff' })
  end
end
map('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = '[G]it lazy[G]it' })

-- ============================================================
-- [[ UI: Bufferline, Trouble, Aerial, Oil, ToggleTerm ]]
-- ============================================================
map('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })
map('n', '<leader>d', '<cmd>bdelete<CR>', { desc = 'Close buffer' })
map('n', '<leader>xe', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>xp', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
map('n', '<leader>xn', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<leader>xq', '<cmd>copen<CR>', { desc = 'Open quickfix list' })
map('n', '<leader>xl', '<cmd>lopen<CR>', { desc = 'Open location list' })
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (Trouble)' })
map('n', '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer Diagnostics' })
map('n', '<leader>xs', '<cmd>Trouble symbols toggle<CR>', { desc = 'Symbols (Trouble)' })

do
  if ok_aerial then
    map('n', '<leader>v', '<cmd>AerialToggle!<CR>', { desc = 'Toggle outline [V]iew' })
  end
end

do
  if ok_oil then
    map('n', '<leader>o', oil.toggle_float, { desc = 'Toggle [O]il float' })
  end
end

local function toggle_terminal()
  local dir = vim.fn.expand '%:p:h'
  if dir == '' or vim.fn.isdirectory(dir) == 0 then
    local cwd = vim.uv.cwd()
    dir = cwd or '.'
  end
  vim.cmd('ToggleTerm dir=' .. vim.fn.fnameescape(dir))
end

map({ 'n', 't' }, '<C-_>', toggle_terminal, { desc = 'Toggle terminal (buffer directory)' })
map({ 'n', 't' }, '<C-/>', toggle_terminal, { desc = 'Toggle terminal (buffer directory)' })

-- ============================================================
-- [[ LSP ]]
-- ============================================================
map('', '<leader>lf', function()
  if ok_conform then
    conform.format { async = true, lsp_format = 'fallback' }
  end
end, { desc = '[L]SP [F]ormat buffer' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map_lsp = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map_lsp('<leader>lr', vim.lsp.buf.rename, '[L]SP [R]ename')
    map_lsp('<leader>la', vim.lsp.buf.code_action, '[L]SP code [A]ction', { 'n', 'x' })
    map_lsp('<leader>lk', hover_in_vsplit, '[L]SP hover in vertical split')
    if ok_snacks then
      map_lsp('gr', function()
        snacks.picker.lsp_references()
      end, '[G]oto [R]eferences')
      map_lsp('gI', function()
        snacks.picker.lsp_implementations()
      end, '[G]oto [I]mplementation')
      map_lsp('gd', function()
        snacks.picker.lsp_definitions()
      end, '[G]oto [D]efinition')
      map_lsp('gy', function()
        snacks.picker.lsp_type_definitions()
      end, '[G]oto t[Y]pe definition')
      map_lsp('<leader>lR', function()
        snacks.picker.lsp_references()
      end, '[L]SP [R]eferences')
      map_lsp('<leader>li', function()
        snacks.picker.lsp_implementations()
      end, '[L]SP [I]mplementation')
      map_lsp('<leader>ld', function()
        snacks.picker.lsp_definitions()
      end, '[L]SP [D]efinition')
      map_lsp('<leader>ls', function()
        snacks.picker.lsp_symbols()
      end, '[L]SP document [S]ymbols')
      map_lsp('<leader>lS', function()
        snacks.picker.lsp_workspace_symbols()
      end, '[L]SP workspace [S]ymbols')
      map_lsp('<leader>lt', function()
        snacks.picker.lsp_type_definitions()
      end, '[L]SP [T]ype definition')
    else
      map_lsp('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
      map_lsp('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      map_lsp('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      map_lsp('gy', vim.lsp.buf.type_definition, '[G]oto t[Y]pe definition')
    end
    map_lsp('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map_lsp('<leader>lD', vim.lsp.buf.declaration, '[L]SP [D]eclaration')

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
-- [[ Python ]]
-- ============================================================
map('n', '<F5>', function()
  local ext = vim.fn.expand '%:e'
  if ext ~= 'py' then
    vim.notify('Not a Python file', vim.log.levels.WARN)
    return
  end
  local fpath = vim.fn.fnameescape(vim.fn.expand '%:p')
  local cmd
  -- Prefer uv run if in a project with pyproject.toml or uv.lock
  if vim.fn.filereadable 'pyproject.toml' == 1 or vim.fn.filereadable 'uv.lock' == 1 then
    cmd = 'uv run python ' .. fpath
  else
    cmd = 'python3 ' .. fpath
  end
  vim.cmd('ToggleTerm cmd=' .. cmd)
end, { desc = 'Run Python file' })

-- ============================================================
-- [[ Tools & Plugins ]]
-- ============================================================
map('n', '<leader>a', ':Alpha<CR>', { silent = true, desc = 'Open [A]lpha dashboard' })
map('n', '<leader>p', '<cmd>PasteImage<CR>', { silent = true, desc = '[P]aste image from clipboard' })
map('n', '<F6>', '<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>', { silent = true, desc = 'Toggle Undotree' })

-- ============================================================
-- [[ OpenCode ]]
-- ============================================================
do
  if ok_opencode then
    map({ 'n', 'x' }, '<leader>ca', function()
      opencode.chat.start()
    end, { desc = '[C]hat [A]sk' })
    map({ 'n', 'x' }, '<leader>cg', function()
      opencode.chat.infer()
    end, { desc = '[C]hat [G]enerate' })
  end
end
