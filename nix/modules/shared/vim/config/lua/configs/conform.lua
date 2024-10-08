local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    -- web
    javascript = { { "prettierd", "prettier" } },
    javascriptreact = { { "prettierd", "prettier" } },
    typescript = { { "prettierd", "prettier" } },
    typescriptreact = { { "prettierd", "prettier" } },
    vue = { { "prettierd", "prettier" } },
    css = { { "prettierd", "prettier" } },
    scss = { { "prettierd", "prettier" } },
    less = { { "prettierd", "prettier" } },
    html = { { "prettierd", "prettier" } },

    -- backend
    rust = { "rustfmt" },
    go = { "goimports", "gofmt" },
    nix = { "nixfmt" },
    dart = { "dart_formah" },
    haskell = { "ormolu" },
    lhaskell = { "ormolu" },

    -- Configs
    json = { "yq" },
    jsonc = { "yq" },
    yaml = { "yq" },
    toml = { "yq" },
    csv = { "yq" },
    xml = { "yq" },
    markdown = { "mdformat" },
    sql = { "sqlfluff" },

    -- Shells
    bash = { "shfmt" },
    sh = { "shfmt" },

    -- others
    ["*"] = { "codespell" },
    ["_"] = { "trim_whitespace" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
