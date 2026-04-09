-- 1. Mason Setup (Installs binaries)
require('mason').setup()

-- 2. Mason LSP Bridge (Ensures installation only)
require('mason-lspconfig').setup({
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "eslint",
    "jsonls",
    "tailwindcss",
    "html",
    "cssls",
    "asm_lsp", -- NASM support
  },
  automatic_installation = true,
})

-- 3. Diagnostics Keymaps
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>d', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- 4. On Attach Mappings
local on_attach = function(_, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gk', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- 5. Capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- 6. Register LSP Servers (Native 0.11 API)
local servers = { "lua_ls", "ts_ls", "eslint", "jsonls", "tailwindcss", "html", "cssls" }

for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    capabilities = capabilities,
    on_attach = on_attach,
  })
  vim.lsp.enable(server)
end

-- 7. Force .asm files to be recognized as nasm
vim.filetype.add({
  extension = {
    asm = "nasm",
  },
})

-- 8. asm_lsp: attach to both asm and nasm filetypes
vim.lsp.config('asm_lsp', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { 'asm', 'nasm', 'vmasm' },
})
vim.lsp.enable('asm_lsp')

-- 8. nvim-cmp Setup
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }),
})
