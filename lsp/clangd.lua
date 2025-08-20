return {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--completion-style=detailed',
    '--header-insertion=iwyu'
  },
  root_markers = {
    'compile_commands.json',
    'compile_flags.txt',
    '.git',
    'CMakeLists.txt'
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  init_options = {
    fallbackFlags = { "-std=c++17" }
  }
}
