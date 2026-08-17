if vim.b.did_java_nav then
  return
end
vim.b.did_java_nav = true

-- gd is left to the global ctags mapping (works for Java too, and every
-- other language ctags parses). Only gr stays java-nav: ctags has no notion
-- of references/call sites, so this is still ripgrep-based.
local nav = require('java-nav')
vim.keymap.set('n', 'gr', nav.references, { buffer = 0, desc = 'java-nav: find references' })
