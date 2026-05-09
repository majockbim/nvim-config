-- line #'s
vim.opt.number = true

-- target directory
if vim.fn.argc() == 0 then
    vim.api.nvim_set_current_dir("C:/Users/pretb/code")
end

-- cursort effect (neovide)
if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "railgun" 
end

-- syntax highlighting
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = { "c", "cpp", "go", "lua", "vim", "vimdoc",
			     "python", "javascript", "html", "css", "typescript", "tsx"},
        
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true, 
	  additional_vim_regex_highlighting = false,
        },
      }
   }

})
