local vue_language_server_path =
  vim.fn.expand('$HOME') .. '/.bun/install/global/node_modules/@vue/language-server'
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}
return {
  cmd = { 'vtsls', '--stdio' },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = { 'vue' },
  root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
}
