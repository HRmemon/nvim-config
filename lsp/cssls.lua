-- CSS LSP configuration
return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  root_markers = { 
    'package.json', 
    '.git',
    'style.css',
    'styles.css'
  },
  filetypes = { 'css', 'scss', 'less' },
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    scss = {
      validate = true
    },
    less = {
      validate = true
    }
  }
}
