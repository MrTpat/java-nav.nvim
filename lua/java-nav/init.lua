-- Grep-based Java navigation, no LSP. gd steps into a declaration,
-- gr lists invocations/references. Both use quickfix for multi-match.
local M = {}

M.config = {
  root_markers = { '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle' },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

local function project_root()
  local found = vim.fs.find(M.config.root_markers, { path = vim.fn.expand('%:p:h'), upward = true })
  if found and #found > 0 then
    return vim.fn.fnamemodify(found[1], ':h')
  end
  return vim.fn.getcwd()
end

local function qf_from_vimgrep(lines, title)
  vim.fn.setqflist({}, ' ', { title = title, lines = lines, efm = '%f:%l:%c:%m' })
end

local function jump_or_list(lines, title)
  if #lines == 0 then
    vim.notify(title .. ': no matches', vim.log.levels.WARN)
    return
  end
  if #lines == 1 then
    local file, lnum, col = lines[1]:match('^(.-):(%d+):(%d+):')
    if file then
      vim.cmd('edit ' .. vim.fn.fnameescape(file))
      vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
      return
    end
  end
  qf_from_vimgrep(lines, title)
  vim.cmd('copen')
end

function M.goto_definition()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local root = project_root()

  -- Java convention: a public class/interface/enum lives in a file of the
  -- same name, so a capitalized identifier is fastest resolved as a filename.
  if word:match('^%u') then
    local files = vim.fn.systemlist({ 'rg', '--files', '-g', word .. '.java', root })
    if #files == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(files[1]))
      return
    elseif #files > 1 then
      vim.fn.setqflist({}, ' ', {
        title = 'gd: ' .. word,
        items = vim.tbl_map(function(f) return { filename = f, lnum = 1, text = word } end, files),
      })
      vim.cmd('copen')
      return
    end
  end

  -- fallback: grep for a type or method declaration by name
  local pattern = string.format(
    [[\b(class|interface|enum|record|@interface)\s+%s\b|\b(void|[A-Za-z_$][\w$<>\[\],. ]*)\s+%s\s*\(]],
    word, word
  )
  local lines = vim.fn.systemlist({ 'rg', '--type', 'java', '--vimgrep', '--pcre2', '-e', pattern, root })
  jump_or_list(lines, 'gd: ' .. word)
end

function M.references()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local root = project_root()
  local lines = vim.fn.systemlist({ 'rg', '--type', 'java', '--vimgrep', '-w', '-e', word, root })
  if #lines == 0 then
    vim.notify('gr: no references found for ' .. word, vim.log.levels.WARN)
    return
  end
  qf_from_vimgrep(lines, 'gr: ' .. word)
  vim.cmd('copen')
end

return M
