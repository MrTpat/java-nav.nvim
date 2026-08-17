# java-nav.nvim

Grep-based Java navigation for Neovim. No LSP, no jdtls, no java_home wrangling —
just `ripgrep` and Java's file-naming convention.

- `gd` on a class name: jumps straight to `ClassName.java` (Java convention: one
  public type per file, named after it). On a method/field, greps for the
  declaration and jumps if there's exactly one match, otherwise opens a
  quickfix list.
- `gr`: lists every whole-word occurrence of the identifier under the cursor
  (declaration + call sites) in the quickfix list. Cycle with `:cnext`/`:cprev`.

Both keymaps are buffer-local and only set for `filetype=java`.

## Requirements

- Neovim >= 0.9
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) on `$PATH`

## Install (vim-plug)

```vim
Plug 'MrTpat/java-nav.nvim'
```

## Configuration

Optional, call anywhere in your config:

```lua
require('java-nav').setup({
  root_markers = { '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle' },
})
```

## How it works

- Project root: nearest ancestor directory containing one of `root_markers`.
- `gd` on a capitalized word: `rg --files -g 'Word.java' <root>`.
- `gd` fallback / `gr`: `rg --type java --vimgrep` with a declaration or
  word-boundary pattern.

This is pattern matching, not a parser — overloaded methods and generic-heavy
signatures can produce noisier results than a real LSP. It trades that for
zero setup and no background language server.
