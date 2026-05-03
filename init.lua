vim.opt.number = true

if vim.fn.argc() == 0 then
    vim.api.nvim_set_current_dir("C:/Users/pretb/code")
end

if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "railgun" 
end
