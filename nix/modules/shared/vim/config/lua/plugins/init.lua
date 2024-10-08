return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require("configs.conform")
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require("configs.lspconfig")
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
        "bash-language-server",
        -- "quick-lint-js",
        "dockerfile-language-server",
        "rust-analyzer",
        "rustfmt",
        "yaml-language-server",
        "yamlfmt",
        "yamllint",
        "gopls",

        -- lua stuff
        "lua-language-server",
        "stylua",

        -- web dev
        "css-lsp",
        "html-lsp",
        "typescript-language-server",
        "deno",
        "emmet-ls",
        "json-lsp",
        "prettierd",
        "eslint_d",

        -- shell
        "shfmt",
        "shellcheck",

        -- move
        "move-analyzer",

        -- haskell
        "haskell-language-server",
        "hlint",
        "ormolu",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = "all",
    },
  },
}
