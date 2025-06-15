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
