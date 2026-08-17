if vim.b.did_java_nav then
  return
end
vim.b.did_java_nav = true

local nav = require('java-nav')
vim.keymap.set('n', 'gd', nav.goto_definition, { buffer = 0, desc = 'java-nav: go to declaration' })
vim.keymap.set('n', 'gr', nav.references, { buffer = 0, desc = 'java-nav: find references' })
