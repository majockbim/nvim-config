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
          "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeSignColumn", "NeoTreeWinSeparator",
          "NeoTreeEndOfBuffer", "NeoTreeFloatNormal", "NeoTreeFloatBorder",
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
         offsets = {
           {
             filetype = "neo-tree",
             text = "File Explorer",
             text_align = "center",
             separator = true,
           }
         },
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
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      keys = {
        { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "NeoTree toggle" },
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = true,
          window = {
            width = 30,
            mappings = {
              ["<space>"] = "none",
            },
          },
          filesystem = {
            filtered_items = {
              visible = true,
              hide_dotfiles = false,
              hide_gitignored = false,
            },
            follow_current_file = {
              enabled = true,
            },
            use_libuv_file_watcher = true,
          },
        })
      end,
    },
    {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        -- Define Sharingan custom highlight colors
        vim.api.nvim_set_hl(0, "SharinganRed", { fg = "#ff2a2a", bold = true })
        vim.api.nvim_set_hl(0, "SharinganWhite", { fg = "#e6e6e6" })
        vim.api.nvim_set_hl(0, "SharinganBlue", { fg = "#3d59a1", bold = true })
        vim.api.nvim_set_hl(0, "SharinganBlack", { fg = "#1a1a1a", bold = true })
        
        dashboard.section.header.val = {
          "⠤⣤⣤⣤⣄⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣠⣤⠤⠤⠴⠶⠶⠶⠶",
          "⢠⣤⣤⡄⣤⣤⣤⠄⣀⠉⣉⣙⠒⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠴⠘⣉⢡⣤⡤⠐⣶⡆⢶⠀⣶⣶⡦",
          "⣄⢻⣿⣧⠻⠇⠋⠀⠋⠀⢘⣿⢳⣦⣌⠳⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠞⣡⣴⣧⠻⣄⢸⣿⣿⡟⢁⡻⣸⣿⡿⠁",
          "⠈⠃⠙⢿⣧⣙⠶⣿⣿⡷⢘⣡⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣷⣝⡳⠶⠶⠾⣛⣵⡿⠋⠀⠀",
          "⠀⠀⠀⠀⠉⠻⣿⣶⠂⠘⠛⠛⠛⢛⡛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠛⠀⠉⠒⠛⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⠀⠀⢻⡁⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀ ⠀⠀⠀⠿",
        }
        
        dashboard.section.header.opts.hl = {
          { { "SharinganWhite", 0, 30 }, { "SharinganWhite", 117, 150 } },
          { { "SharinganWhite", 0, 45 }, { "SharinganWhite", 105, 150 } },
          { { "SharinganWhite", 0, 51 }, { "SharinganWhite", 102, 150 } },
          { { "SharinganWhite", 0, 51 }, { "SharinganWhite", 99, 144 } },
          {
            { "SharinganWhite", 12, 18 },
            { "SharinganRed",   18, 24 },
            { "SharinganWhite", 24, 51 },
            { "SharinganWhite", 111, 135 },
          },
          -- Rows 5-8: red drip (left)
          { { "SharinganRed", 18, 24 }, { "SharinganRed", 39, 45 } },
          { { "SharinganRed", 18, 24 }, { "SharinganRed", 39, 42 } },
          { { "SharinganRed", 18, 24 }, { "SharinganRed", 39, 42 } },
          { { "SharinganRed", 18, 24 }, { "SharinganRed", 39, 42 } },
          -- Rows 9-11: red  drip
          { { "SharinganRed", 18, 24 } },
          { { "SharinganRed", 21, 24 } },
          { { "SharinganRed", 19, 22 } },
        }
        
        dashboard.section.buttons.val = {
          dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
          dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
          dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
          dashboard.button("c", "  Config", ":e C:/Users/pretb/AppData/Local/nvim/init.lua<CR>"),
          dashboard.button("q", "  Quit", ":qa<CR>"),
        }
        
        local handle = io.popen("nvim --version")
        local version = "Neovim"
        if handle then
          local result = handle:read("*a")
          handle:close()
          version = result:match("NVIM v([^\n]+)") or "Neovim"
        end
        
        dashboard.section.footer.val = {
          "start building"
        }
        
        alpha.setup(dashboard.opts)
      end
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