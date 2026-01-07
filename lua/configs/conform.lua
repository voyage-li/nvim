---@module "conform.init"
---@diagnostic disable-next-line: assign-type-mismatch
local conform = require "conform"

---@type conform.setupOpts
local options = {
  formatters = {
    beautysh = {
      prepend_args = { "--indent-size", "2" },
    },
    clang_format = {
      prepend_args = {
        "--style=file",        -- 关键：从项目根目录查找 .clang-format 文件
        "--fallback-style=google" -- 备选方案：若无配置文件，使用 LLVM 风格
      }
    }
  },
  formatters_by_ft = {
    astro = { "stylelint", "prettierd", "eslint_d" },
    bash = { "shellcheck", "shfmt" },
    c = { "clang-format", lsp_format = "last" },
    clojure = { "zprint" },
    cpp = { "clang-format", lsp_format = "last" },
    cs = { "csharpier" }, -- C#
    csh = { "shellcheck", "beautysh" },
    css = { "stylelint", "prettierd" },
    elm = { "elm_format" },
    go = { "goimports", "gofmt" },
    haskell = { "ormolu" },
    html = { "prettierd" },
    java = { "google-java-format" },
    javascript = { "stylelint", "prettierd", "eslint_d" },
    javascriptreact = { "stylelint", "prettierd", "eslint_d" },
    ksh = { "shellcheck", "beautysh" },
    lua = { "stylua" }, -- Stylua is already configured as the default formatter for Lua in NvChad, but keeping it here for reference
    mksh = { "shellcheck", "shfmt" },
    python = function(bufnr)
      if conform.get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
    ruby = { "rubocop" },
    rust = { "rustfmt" },
    sh = { "shellcheck", "shfmt" },
    svelte = { "stylelint", "prettierd", "eslint_d" },
    tcsh = { "shellcheck", "beautysh" },
    typescript = { "stylelint", "prettierd", "eslint_d" },
    typescriptreact = { "stylelint", "prettierd", "eslint_d" },
    vue = { "stylelint", "prettierd", "eslint_d" },
    zsh = { "shellcheck", "beautysh" },
  },

  format_on_save = {
    timeout_ms = 2000,
    lsp_format = "fallback",
  },
}

return options

