return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        go = { 'golangcilint' },
        javascript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescript = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        -- NOTE: no `python` entry on purpose. The Ruff language server already
        --  publishes these diagnostics, so linting here would duplicate every one.
        --
        -- NOTE: no `ruby` or `eruby` entry either, for the same reason -- ruby-lsp
        --  runs the project's own bundled RuboCop and publishes its offences.
      }

      -- markdownlint-cli resolves `.markdownlint.json` from the current working
      --  directory only. It does not walk up to the project root, and `--stdin`
      --  leaves it no file path to search from anyway, so a config file on its own
      --  would apply only when Neovim happened to be cd'd to the right directory.
      --  Pass one explicitly instead: the project's own when it has one, and
      --  otherwise the fallback in this repo, which turns off the rules Prettier
      --  already owns -- Prettier formats Markdown on save, so those rules would
      --  otherwise fire on Prettier's own output.
      local markdownlint_fallback = vim.fs.joinpath(vim.fn.stdpath 'config', '.markdownlint.json')
      lint.linters.markdownlint.args = {
        '--stdin',
        '--config',
        function()
          local bufname = vim.api.nvim_buf_get_name(0)
          local project_config = vim.fs.find({
            '.markdownlint.json',
            '.markdownlint.jsonc',
            '.markdownlint.yaml',
            '.markdownlint.yml',
          }, {
            upward = true,
            path = bufname ~= '' and vim.fs.dirname(bufname) or vim.fn.getcwd(),
            stop = vim.uv.os_homedir(),
          })[1]
          return project_config or markdownlint_fallback
        end,
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
