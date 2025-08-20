-- HTML LSP configuration
return {
  cmd = { 'vscode-html-language-server', '--stdio' },
  root_markers = { 
    'package.json', 
    '.git',
    'index.html'
  },
  filetypes = { 'html', 'htmldjango' },
  init_options = {
    configurationSection = { 'html', 'css', 'javascript' },
    embeddedLanguages = {
      css = true,
      javascript = true
    },
    provideFormatter = true
  },
  settings = {
    html = {
      format = {
        indentInnerHtml = true,
        wrapLineLength = 120,
        wrapAttributes = 'auto'
      },
      suggest = {
        html5 = true
      },
      validate = {
        scripts = true,
        styles = true
      }
    }
  }
}
