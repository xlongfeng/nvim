# Copilot Instructions

Personal Neovim configuration built on [LazyVim](https://lazyvim.github.io). All files are Lua plugin specs or small config overrides layered on top of LazyVim defaults.

## Commands

```bash
# Sync/install plugins (run after editing plugin specs)
nvim --headless "+Lazy! sync" +qa

# Startup smoke test (run after most config changes)
nvim --headless +qa

# Health check (run when touching LSP, external tools, or providers)
nvim --headless "+checkhealth" +qa

# Format a changed file
stylua lua/plugins/conform.lua

# Syntax-check a changed file (closest thing to a single-file test)
luac -p lua/plugins/conform.lua

# Format entire repo
stylua .
```

No automated test suite exists. Quick command selection:

| What changed | Command |
|---|---|
| One Lua file | `stylua <file>` then `luac -p <file>` |
| Config/startup behavior | `nvim --headless +qa` |
| Plugin specs | `nvim --headless "+Lazy! sync" +qa` |
| LSP / external tool integration | `nvim --headless "+checkhealth" +qa` |
| Keymaps / UI / colorscheme | Open `nvim` and test manually |

## Architecture

```
init.lua                  # Entry point — calls require("config.lazy")
lua/config/lazy.lua       # Bootstraps lazy.nvim; imports LazyVim then lua/plugins/
lua/config/options.lua    # vim.opt / vim.g overrides (loaded before lazy.nvim)
lua/config/keymaps.lua    # Additional keymaps (loaded on VeryLazy)
lua/config/autocmds.lua   # Additional autocmds (loaded on VeryLazy)
lua/plugins/*.lua         # Per-topic plugin specs; each file returns a spec table
lazyvim.json              # LazyVim extras enabled for this install
lazy-lock.json            # Plugin version lockfile (treat as generated)
stylua.toml               # Formatter config: spaces, 2-wide indent, 120 col width
```

**Load order:** `init.lua` → `config/lazy.lua` → LazyVim core + extras → `lua/plugins/*`

**Enabled LazyVim extras** (`lazyvim.json`): `mini-comment`, `mini-surround`, `clangd`, `cmake`, `docker`, `json`, `markdown`, `toml`, `yaml`.

## Plugin Spec Conventions

Each file under `lua/plugins/` returns a table of lazy.nvim specs:

```lua
-- Simple option extension
return {
  { "author/plugin", opts = { key = "value" } },
}

-- Mutating inherited LazyVim defaults
return {
  { "author/plugin", opts = function(_, opts)
    opts.sections.lualine_z = { "filetype" }
  end },
}

-- Full setup when opts isn't enough
return {
  { "author/plugin", config = function() ... end },
}
```

Prefer `opts = { ... }` → `opts = function(_, opts)` → `config = function()` in that order of preference. Keep each file focused on one plugin or closely related group.

## Lua Import Conventions

- Use `require("...")` with **double-quoted** module names.
- Prefer `local x = require("mod")` when a module is referenced more than once.
- Inline `require()` inside callbacks is fine for single-use references.
- Avoid top-level `require()` calls that would load plugins before lazy.nvim intends.
- Use `snake_case` for local variables and helper functions.

## Key Conventions

- **Extend, don't replace**: Override only what differs from LazyVim defaults. Avoid copying full upstream config blocks.
- **`<leader>` groups**: New keymaps must fit the existing `<leader>` group structure. Use `which-key` `spec` entries to declare group labels.
- **No relative line numbers**: `vim.opt.relativenumber = false` is set globally.
- **Animations disabled**: `vim.g.snacks_animate = false`.
- **`exrc` enabled**: `vim.opt.exrc = true` — per-project `.nvim.lua` files are loaded automatically.
- **cmake_format**: conform.nvim is configured to format CMake files; `cmake_format` must be installed externally.
- **blink.cmp**: `<C-y>` remapped to `fallback` (restores default Vim behaviour).
- **Lockfile**: Do not hand-edit `lazy-lock.json`; update intentionally via `:Lazy sync`.

## Commit Message Style

Follow the existing history format: `type: Capitalized verb rest of message`

```
docs: Add .github/copilot-instructions.md
plugs: Format cmake with cmake_format
opts: Enable loading extra rc from current directory
```

- Common types: `docs`, `plugs`, `opts`, `fix`
- The first word after `type:` must be a capitalized verb (e.g., `Add`, `Remove`, `Fix`, `Update`)

## Agent Checklist

- Read nearby plugin files before changing local style or structure.
- Format changed files with `stylua`; syntax-check with `luac -p`.
- Run `nvim --headless +qa` for startup-sensitive changes.
- Run `nvim --headless "+Lazy! sync" +qa` after plugin-spec changes.
- Do not reformat unrelated files opportunistically.
- Mention any validation you could not run in the final handoff.
