# nvim cheat sheet

Close this tab with `q`. For any key group, press Space and wait: which-key lists what follows. Full article: Obsidian, Projects/desktop/nvim-config.

## How to read the keys

| Written | Means |
|---|---|
| `<leader>` | the Space key. `<leader>gd` is Space, then `g`, then `d`, one after another |
| `<C-s>` | Ctrl and `s` held together. `<C-Space>` is Ctrl+Space |
| `<A-x>`, `<M-x>` | Alt and `x` held together |
| `<S-Tab>` | Shift and Tab held together. A capital letter (`G`, `C`) is Shift and that letter |
| `<CR>`, `<Esc>`, `<Tab>`, `<BS>` | Enter, Escape, Tab, Backspace |
| `<F1>` | the F1 function key |
| `]h`, `gd`, `grr` | plain keys pressed in a row, not together |
| `n`, `x`, `i` | normal, visual and insert mode, when a row names one |

## See what the agent did

| Keys | Action |
|---|---|
| `<leader>gd` | uncommitted changes, or the last commit when there are none |
| `<leader>gh` `<leader>gw` | the last commit, the uncommitted changes |
| `<leader>gD` | the whole branch against its base |
| `<leader>gg` | git menu with plain words |
| `<leader>gG` | lazygit |
| `<leader>gf` `<leader>gl` | history of this file, log of the repository |
| `]h` `[h` | next, previous hunk in the file |
| `<leader>hp` | preview the hunk |

## Inside the diff view

| Keys | Action |
|---|---|
| `<Tab>` `<S-Tab>` | next, previous file |
| `-` | stage or unstage the file |
| `<leader>hs` `<leader>hu` `<leader>hr` | stage, unstage, discard the hunk |
| `i` | comment on the line (in visual mode, on the selection) |
| `C` | copy the comments to the clipboard for the agent |
| `q` | close; the comments go to the clipboard and the archive |

## Commits

| Keys | Action |
|---|---|
| `<leader>gs` | status; there `cw` rewrites the last commit message, `rw` the one under the cursor |
| `<leader>gc` | commit |
| `<leader>tc` | the message popup for agent commits, on or off |

## Agent

| Keys | Action |
|---|---|
| `<leader>as` | send the selection to the agent |
| `<leader>ab` | add this file to the agent |
| `<leader>yp` | copy path and code, ready to paste |

## Files and search

| Keys | Action |
|---|---|
| `<leader><space>` | find a file |
| `<leader>/` | search text in the project |
| `<leader>,` | open buffers |
| `<leader>sk` | search all key bindings |
| `<leader>r` | run the current file |
| `<leader>u` | undo tree |

## Code

| Keys | Action |
|---|---|
| `gd` `grr` `grn` | definition, references, rename |
| `gra` `K` | code actions, documentation |
| `<leader>cf` | format |
| `]d` `[d` | next, previous diagnostic |
| `<C-s>` | save |
