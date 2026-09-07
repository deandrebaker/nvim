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
}
