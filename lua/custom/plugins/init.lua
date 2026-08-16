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

      terminal = Terminal:new(window)
      local silent = { silent = true }

      vim.api.nvim_set_keymap('n', '<leader>t', ':lua terminal:toggle()<cr>', silent)
      vim.api.nvim_set_keymap('n', '<leader>1', ':lua terminal:open(1)<cr>', silent)
      vim.api.nvim_set_keymap('n', '<leader>2', ':lua terminal:open(2)<cr>', silent)
      vim.api.nvim_set_keymap('n', '<leader>3', ':lua terminal:open(3)<cr>', silent)
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
