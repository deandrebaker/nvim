-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
  },
  {
    's1n7ax/nvim-terminal',
    config = function()
      local Terminal = require 'nvim-terminal.terminal'
      local Window = require 'nvim-terminal.window'
      local window = Window:new {
        position = 'botright',
        split = 'sp',
        width = 50,
        height = 15,
      }

      -- NOTE: `local` matters here. Without it this leaks a global named
      --  `terminal`, which is why the old keymaps could be plain `:lua terminal:...`
      --  command strings. Closures capture the upvalue instead, so nothing global
      --  is needed and a typo becomes a load-time error rather than a silent no-op.
      local terminal = Terminal:new(window)

      -- NOTE: this lives under `<leader>t` (the `[T]oggle` group declared in
      --  init.lua) rather than on `<leader>t` itself. A bare `<leader>t` mapping
      --  shadows the whole group, including the LSP's `<leader>th` inlay hints.
      vim.keymap.set('n', '<leader>tt', function()
        terminal:toggle()
      end, { silent = true, desc = '[T]oggle [T]erminal' })

      for i = 1, 3 do
        vim.keymap.set('n', '<leader>' .. i, function()
          terminal:open(i)
        end, { silent = true, desc = 'Open terminal ' .. i })
      end
    end,
  },
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup {}
    end,
  },
  { 'christoomey/vim-tmux-navigator' },

  {
    -- Rails project navigation: `:A` swaps between a file and its test, the
    --  `:Emodel`/`:Econtroller`/`:Eview` family opens Rails files by name, and `gf`
    --  follows partial renders and route helpers.
    'tpope/vim-rails',
    -- NOTE: deliberately not lazy-loaded on the `ruby` filetype. vim-rails detects
    --  the project as a buffer loads, and its `:E*` commands are most useful
    --  *before* any Ruby file is open -- loading on filetype would make them
    --  missing at exactly the moment you reach for them.
    lazy = false,
  },

  {
    -- Test runner. It picks the runner from the file itself, so `spec/` goes to
    --  RSpec and `test/` to `rails test`, and it prefixes `bundle exec` when the
    --  project has a Gemfile. Nothing here is Ruby-specific -- the same keymaps run
    --  Go, Python and Jest tests in those projects.
    'vim-test/vim-test',
    dependencies = { 'tpope/vim-rails' }, -- supplies the Rails-aware test paths
    -- NOTE: these sit under `<leader>T`, not `<leader>t`, which is already the
    --  `[T]oggle` group (`<leader>tt` terminal, `<leader>th` inlay hints).
    keys = {
      { '<leader>Tn', '<cmd>TestNearest<cr>', desc = '[T]est [N]earest' },
      { '<leader>Tf', '<cmd>TestFile<cr>', desc = '[T]est [F]ile' },
      { '<leader>Ts', '<cmd>TestSuite<cr>', desc = '[T]est [S]uite' },
      { '<leader>Tl', '<cmd>TestLast<cr>', desc = '[T]est [L]ast' },
      { '<leader>Tv', '<cmd>TestVisit<cr>', desc = '[T]est [V]isit last test file' },
    },
    config = function()
      -- Run in a Neovim terminal split. Deliberately not the `vimux` or `dispatch`
      --  strategy: both pull in another plugin, and this keeps the runner
      --  self-contained even though vim-tmux-navigator is already installed.
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#term_position'] = 'botright 15'
      -- Keep the previous run on screen instead of clearing it away.
      vim.g['test#preserve_screen'] = 1
    end,
  },
}
