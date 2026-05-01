return {
  cmd = { '/Users/thenaman047/.bun/bin/vscode-json-languageserver', '--stdio' },
  filetypes = { 'json', 'jsonc', 'json5' },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { '.git' },
  settings = {
    json = {
      format = {
        enable = true,
      },
      schemas = {
        {
          fileMatch = { 'package.json' },
          url = 'https://json.schemastore.org/package.json',
        },
        {
          fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
          url = 'https://json.schemastore.org/tsconfig.json',
        },
        {
          fileMatch = { '.eslintrc', '.eslintrc.json' },
          url = 'https://json.schemastore.org/eslintrc.json',
        },
        {
          fileMatch = { '.prettierrc', '.prettierrc.json' },
          url = 'https://json.schemastore.org/prettierrc.json',
        },
        {
          fileMatch = { 'babelrc.json', '.babelrc.json', '.babelrc' },
          url = 'https://json.schemastore.org/babelrc.json',
        },
        {
          fileMatch = { 'lerna.json' },
          url = 'https://json.schemastore.org/lerna.json',
        },
        {
          fileMatch = { '.stylelintrc', '.stylelintrc.json' },
          url = 'https://json.schemastore.org/stylelintrc.json',
        },
        {
          fileMatch = { '.markdownlint.json', '.markdownlint.jsonc' },
          url = 'https://json.schemastore.org/markdownlint.json',
        },
        {
          fileMatch = {
            '.github/workflows/*.yml',
            '.github/workflows/*.yaml',
          },
          url = 'https://json.schemastore.org/github-workflow.json',
        },
        {
          fileMatch = {
            '.github/dependabot.yml',
            '.github/dependabot.yaml',
          },
          url = 'https://json.schemastore.org/dependabot-2.0.json',
        },
      },
    },
  },
}