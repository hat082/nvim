# Neovim Config Schema

## Load Order

- `init.lua` sets globals and core options.
- Neovim auto-sources files in `plugin/`.
- `plugin/zz-keymaps.lua` loads `lua/keymaps.lua` last so plugin-backed maps can safely reference already-loaded plugins.

## Plugins

- Plugin definitions and setup live in `plugin/*.lua`.
- Keep plugin config close to the plugin that owns it.
- Prefer one plugin area per file, for example UI, git, editor, LSP.

## Keymaps

- Shared/user-facing mappings live in `lua/keymaps.lua`.
- Plugin modules used by mappings are required once at the top of `lua/keymaps.lua`.
- Use explicit names like `ok_snacks`, `ok_oil`, `ok_gitsigns` for guarded plugin requires.
- If a mapping depends on a plugin, guard it with that plugin's top-level `ok_*` flag.
- Avoid duplicate lhs bindings unless one is intentionally overriding another.

## Rule Of Thumb

- Plugin behavior goes in `plugin/*.lua`.
- Cross-plugin keybinds and daily-driver mappings go in `lua/keymaps.lua`.
