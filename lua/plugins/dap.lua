-- lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local nt_api = require("nvim-tree.api") -- 引入 nvim-tree API

      dapui.setup()

      -- === 核心自动化逻辑 (使用 API 替代指令) ===

      -- 1. 当调试开始时：关闭 NvimTree，打开 DAP UI
      dap.listeners.before.attach.dapui_config = function()
        nt_api.tree.close() -- 使用 API 关闭
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        nt_api.tree.close() -- 使用 API 关闭
        dapui.open()
      end

      -- 2. 当调试结束时：关闭 DAP UI，重新打开 NvimTree
      local function stop_debugging()
        dapui.close()
        nt_api.tree.open() -- 使用 API 重新开启
      end

      dap.listeners.before.event_terminated.dapui_config = stop_debugging
      dap.listeners.before.event_exited.dapui_config = stop_debugging

      -- === LLDB 配置保持不变 ===
      dap.adapters.lldb = {
        type = 'executable',
        command = 'lldb-vscode', 
        name = 'lldb'
      }

      local lldb_config = {
        {
          name = 'Launch',
          type = 'lldb',
          request = 'launch',
          program = function()
            local exe = vim.fn.expand("%:r")
            if vim.fn.executable(exe) == 1 then
              return exe
            else
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }

      dap.configurations.cpp = lldb_config
      dap.configurations.c = lldb_config
      dap.configurations.rust = lldb_config
    end,
  }
}