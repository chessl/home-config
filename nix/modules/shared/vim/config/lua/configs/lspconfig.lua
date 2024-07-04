-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
-- local configs = require("lspconfig.configs")

local servers = {
  "html",
  "cssls",
  "bashls",
  "emmet_ls",
  "clangd",
  "pyright",
  "dockerls",
  "jsonls",
  "rust_analyzer",
  "tsserver",
  "gopls",
  "rnix",
  "yamlls",
  "dartls",
  "move_analyzer",
  -- "sui_move_analyzer",
}

-- if not configs.sui_move_analyzer then
--   configs.sui_move_analyzer = {
--     default_config = {
--       cmd = {
--         "sui-move-analyzer",
--       },
--       filetypes = { "move" },
--       -- root_dir = lspconfig.util.root_pattern("pubspec.yaml"),
--       root_dir = function(fname)
--         local move_package_dir = lspconfig.util.root_pattern("Move.toml")(fname)
--         return move_package_dir
--       end,
--       default_config = {
--         root_dir = [[root_pattern("Move.toml")]],
--       },
--       settings = {},
--     },
--   }
-- end

-- lspconfig.sui_move_analyzer.setup({
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
-- })

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

-- rust
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})
