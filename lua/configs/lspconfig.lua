-- 1. 加载 NvChad 的默认设置（包含快捷键绑定和补全能力）
require("nvchad.configs.lspconfig").defaults()

-- 2. 获取 NvChad 预设的 on_attach 和 capabilities
-- 这些是让 NvChad 各种功能（如弹窗、代码操作）正常运作的核心
local nvlsp = require "nvchad.configs.lspconfig"

-- 3. 定义需要启用的服务器
local servers = { "html", "cssls" }

-- 4. 适配 Neovim 0.11 的最新写法配置基础服务器
for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    install = true, -- 如果 Mason 没装，会自动处理（取决于插件支持）
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
  -- 显式启用
  vim.lsp.enable(lsp)
end

-- 5. 专门配置 clangd (包含自定义参数)
vim.lsp.config("clangd", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  -- 添加以下 init_options 内容
  init_options = {
    base46 = {
      hl_groups = { "LspInlayHint" },
    },
    setup = {
      -- 这一块是针对 clangd 的具体提示设置
      clangd = {
        hints = {
          arguments = true,          -- 显示函数形参名称
          parameterNames = true,     -- 显示参数名
          deducedTypes = true,       -- 显示推导类型 (如 auto)
          labelPredictions = true,
          thisPointer = true,
        },
      },
    },
  },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--function-arg-placeholders",
  },
})
vim.lsp.enable("clangd")

-- 创建一个自动命令，在 LSP 附加到缓冲区时开启 Inlay Hints
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    
    -- 检查服务器是否支持 inlayHint
    if client and client.server_capabilities.inlayHintProvider then
      -- 默认开启
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})