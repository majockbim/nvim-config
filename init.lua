-- line #'s
vim.opt.number = true
vim.opt.termguicolors = true
-- target directory
if vim.fn.argc() == 0 then
    vim.api.nvim_set_current_dir("C:/Users/pretb/code")
end
-- cursort effect (neovide)
if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "railgun" 
    vim.o.guifont = "0xProto Nerd Font Mono:h12"
end
-- syntax highlighting + cursor smearing + auto close brackets n stuff
-- + secret sauce (aka copilot)
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
    "github/copilot.vim",
    event = "InsertEnter",
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {}
  },
  {
    "sphamba/smear-cursor.nvim",
    event = "VimEnter",
    cond = not vim.g.neovide,  -- only load in Neovim, not Neovide
    opts = {
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      scroll_buffer_space = true,
      legacy_computing_symbols_support = false,
      }
  },
  
   {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ 
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      })
      
      local function apply_transparency()
        local groups = {
          "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer",
          "MsgArea", "TelescopeNormal", "TelescopeBorder", "NvimTreeNormal",
          "TabLine", "TabLineFill", "TabLineSel", "StatusLine", "StatusLineNC",
          "WinBar", "WinBarNC"
        }
        for _, group in ipairs(groups) do
          vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end

        -- Brute force all BufferLine groups
        for _, hl in ipairs(vim.api.nvim_get_hl(0, {})) do
          if hl:find("^BufferLine") or hl:find("^TabLine") then
            vim.api.nvim_set_hl(0, hl, { bg = "NONE", ctermbg = "NONE" })
          end
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          apply_transparency()
          -- Defer to ensure plugins are finished loading
          vim.defer_fn(apply_transparency, 100)
        end
      })

      vim.cmd([[colorscheme tokyonight-night]])
      apply_transparency()
      vim.defer_fn(apply_transparency, 500)
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
   },
   {
    -- gitsigns for line-by-line status
     "lewis6991/gitsigns.nvim",
     event = { "BufReadPre", "BufNewFile" },
     opts = {
       signs = {
         add          = { text = '│' },
         change       = { text = '│' },
         delete       = { text = '_' },
         topdelete    = { text = '‾' },
         changedelete = { text = '~' },
       },
     }
   },
   -- telescope for viewing project-wide git file status
   {
     "nvim-telescope/telescope.nvim",
     branch = "0.1.x",
     dependencies = { "nvim-lua/plenary.nvim" }
   },
   -- vscode-like tabs with icons
   {
     "akinsho/bufferline.nvim",
     version = "*",
     dependencies = "nvim-tree/nvim-web-devicons",
     opts = {
       options = {
         mode = "buffers",
         separator_style = "thin",
         show_buffer_close_icons = true,
         show_close_icon = true,
       },
       highlights = {
         fill = { bg = "NONE" },
         background = { bg = "NONE" },
         tab = { bg = "NONE" },
         tab_selected = { bg = "NONE" },
         buffer_visible = { bg = "NONE" },
         buffer_selected = { bg = "NONE", italic = false },
         indicator_visible = { bg = "NONE" },
         indicator_selected = { bg = "NONE" },
         modified = { bg = "NONE" },
         modified_visible = { bg = "NONE" },
         modified_selected = { bg = "NONE" },
         close_button = { bg = "NONE" },
         close_button_visible = { bg = "NONE" },
         close_button_selected = { bg = "NONE" },
         duplicate_selected = { bg = "NONE" },
         duplicate_visible = { bg = "NONE" },
         duplicate = { bg = "NONE" },
         pick_selected = { bg = "NONE" },
         pick_visible = { bg = "NONE" },
         pick = { bg = "NONE" },
         offset_separator = { bg = "NONE" },
       },
     }
   },
   -- statusline
   {
     "nvim-lualine/lualine.nvim",
     dependencies = { "nvim-tree/nvim-web-devicons" },
     opts = {
       options = {
         theme = "tokyonight",
         component_separators = "|",
         section_separators = { left = "", right = "" },
       }
     }
   },
   -- LSP support
   {
     "neovim/nvim-lspconfig",
     dependencies = {
       "williamboman/mason.nvim",
       "williamboman/mason-lspconfig.nvim",
     },
     config = function()
       require("mason").setup()
       require("mason-lspconfig").setup({
         ensure_installed = { "lua_ls", "pyright", "ts_ls" },
       })

       -- Modern Neovim 0.11+ way: Use LspAttach for keymaps
       vim.api.nvim_create_autocmd("LspAttach", {
         callback = function(args)
           local bufnr = args.buf
           local opts = { buffer = bufnr, silent = true }
           vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
           vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
           vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
           vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
         end,
       })

       -- Enable servers using the native API
       vim.lsp.enable("lua_ls")
       vim.lsp.enable("pyright")
       vim.lsp.enable("ts_ls")
     end
   },
   -- Discord Rich Presence
   {
     'vyfor/cord.nvim',
     event = 'VeryLazy',
     opts = {},
   },
})
-- block cursor in insert mode, blinking
vim.opt.guicursor = "i:block-blinkwait700-blinkon400-blinkoff400"
-- default tab amnt -> 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- map :cd %:p:h to :cd now
vim.cmd([[cnoreabbrev <expr> now (getcmdtype() == ':' && getcmdline() == 'cd now') ? '%:p:h' : 'now']])