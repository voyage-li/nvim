require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- ctrl s 保存 ctrl z undo ctrl y redo
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "file save" })
map({ "n", "i", "v" }, "<C-z>", "<cmd> undo <cr>", { desc = "history undo" })
map({ "n", "i", "v" }, "<C-y>", "<cmd> redo <cr>", { desc = "history redo" })
-- 注释 ctrl /
map("n", "<C-_>", "gcc", { desc = "comment toggle", remap = true })
map("i", "<C-_>", "<Esc>gcc^i", { desc = "comment toggle", remap = true })
map("v", "<C-_>", "gc", { desc = "comment toggle", remap = true })
-- ctrl f 搜索 
map({ "n", "i", "v" }, "<C-f>", function()
  if vim.bo.filetype == "TelescopePrompt" then
    vim.cmd "q!"
  else
    vim.cmd "Telescope current_buffer_fuzzy_find"
  end
end, { desc = "search search in current buffer" })

map("n", "gb", "<C-o>", { desc = "jump jump back" })
map("n", "gh", vim.lsp.buf.hover, { desc = "LSP hover" })
map("n", "ge", vim.diagnostic.open_float, { desc = "LSP show diagnostics" })
map({ "n", "i", "v" }, "<A-.>", vim.lsp.buf.code_action, { desc = "LSP code action" }) 
map({ "n", "i", "v" }, "<F2>", function()
  if vim.bo.filetype == "NvimTree" then
    require("nvim-tree.api").fs.rename()
  else
    require "nvchad.lsp.renamer"()
  end
end, { desc = "LSP rename" })
map({ "n", "i", "v" }, "<F12>", vim.lsp.buf.definition, { desc = "LSP rename" })

map("n", "<leader>gh", function() require("gitsigns").toggle_linehl() end, { desc = "Git show changes" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Git show hunk" })
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "Git Rest this line" })


-- === DAP 调试映射 ===
map("n", "<leader>cc", function()
  local file = vim.fn.expand("%")
  local file_name = vim.fn.expand("%:r")
  local file_type = vim.bo.filetype
  
  vim.cmd("w")

  local cmd_str = ""
  if file_type == "cpp" then
    cmd_str = string.format("clang++ -g -std=c++2b %s -o %s", file, file_name)
  elseif file_type == "c" then
    cmd_str = string.format("clang -g %s -o %s", file, file_name)
  else
    print("Not a C/C++ file")
    return
  end

  -- 1. 先输出正在执行的指令（使用灰色字体以示区分）
  vim.api.nvim_echo({{ "🏗️ Compiling :  " .. cmd_str, "Comment" }}, false, {})

  -- 2. 异步执行编译
  vim.fn.jobstart(cmd_str, {
    on_exit = function(_, exit_code, _)
      if exit_code == 0 then
        -- 3a. 编译成功：无事发生（仅更新状态栏提示）
        -- 使用 redraw 确保之前的指令提示被替换，而不是堆叠
        vim.cmd("redraw")
        vim.api.nvim_echo({{ "✅ Complie success: " .. file_name, "DiagnosticOk" }}, false, {})
      else
        -- 3b. 编译失败：弹出窗口显示报错详情
        vim.cmd("redraw") -- 清除正在执行的指令提示
        vim.cmd("botright 15split")
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(win, buf)
        
        -- 在新窗口再次运行编译命令，显示详细报错
        vim.fn.termopen(cmd_str .. " || echo '\n\27[31m❌ Compile failed, check above\27[0m'")
        vim.cmd("normal! G")
      end
    end
  })
end, { desc = "Compile (Silent & Info)" })

map("n", "<leader>cr", function()
  local file = vim.fn.expand("%")
  local file_name = vim.fn.expand("%:r")
  local file_type = vim.bo.filetype
  
  vim.cmd("w")

  local compile_cmd = ""
  if file_type == "cpp" then
    compile_cmd = string.format("clang++ -g -std=c++2b %s -o %s", file, file_name)
  elseif file_type == "c" then
    compile_cmd = string.format("clang -g %s -o %s", file, file_name)
  else
    print("Not a C/C++ file")
    return
  end

  -- 1. 输出正在编译的指令
  vim.api.nvim_echo({{ "🏗️ Compiling :  " .. compile_cmd, "Comment" }}, false, {})

  -- 2. 异步编译
  vim.fn.jobstart(compile_cmd, {
    on_exit = function(_, exit_code, _)
      vim.cmd("redraw")
      if exit_code == 0 then
        -- 3a. 编译成功：弹出窗口并运行程序
        vim.cmd("botright 15split")
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(win, buf)

        -- 运行程序，运行结束后提示
        local run_cmd = string.format("./%s", file_name)
        vim.fn.termopen(run_cmd)
        vim.cmd("normal! G")
        -- 自动进入插入模式，方便用户直接输入数据
        vim.cmd("startinsert")
      else
        -- 3b. 编译失败：弹出窗口显示报错
        vim.cmd("botright 15split")
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(win, buf)

        vim.fn.termopen(compile_cmd .. " || echo '\n\27[31m❌ Compile failed, check above\27[0m'")
        vim.cmd("normal! G")
      end
    end
  })
end, { desc = "Compile and Run" })

map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
map("n", "<leader>dr", function() require("dap").continue() end, { desc = "Start/Continue Debug" })
map("n", "<leader>do", function() require("dap").step_over() end, { desc = "Step Over" })
map("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
map("n", "<leader>dO", function() require("dap").step_out() end, { desc = "Step Out" })
map("n", "<leader>dq", function() require("dap").terminate() end, { desc = "Terminate Debugging" })
map("n", "<leader>du", function()
  local dapui = require("dapui")
  local nvimtree = require("nvim-tree.api")
  local is_ui_open = false
  
  -- 遍历当前所有窗口，检查是否有 filetype 以 "dapui_" 开头的缓冲区
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft:find("dapui_") then -- 修正点：dapui 使用的是下划线
      is_ui_open = true
      break
    end
  end

  if is_ui_open then
    dapui.close()
    nvimtree.tree.open()
    -- 可选：如果你希望关闭 UI 后光标回到代码区
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>p", true, false, true), "n", false)
  else
    nvimtree.tree.close()
    dapui.open()
  end
end, { desc = "Toggle Debug UI" })