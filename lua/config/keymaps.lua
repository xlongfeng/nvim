-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy file name, line and column to clipboard
vim.keymap.set("n", "gl", function()
  local loc = "@" .. vim.fn.expand("%") .. ":" .. vim.fn.line(".") .. ":" .. vim.fn.col(".")
  vim.fn.setreg("+", loc)
  vim.notify("Copied: " .. loc)
end, { desc = "Copy File Location" })

vim.keymap.set("v", "gl", function()
  local cursor = vim.fn.line(".")
  local anchor = vim.fn.line("v")
  local start_line = math.min(cursor, anchor)
  local end_line = math.max(cursor, anchor)
  local loc = "@" .. vim.fn.expand("%") .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", loc)
  vim.notify("Copied: " .. loc)
end, { desc = "Copy File Location" })
