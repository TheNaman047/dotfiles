# PR Review in Neovim

octo.nvim + diffview.nvim.

**`<leader>` is `<space>`. `<localleader>` is `\` (backslash).**
Octo's in-buffer mappings all use `<localleader>`, so they are typed `\ca`, `\pd`, etc.

## Entry points (`<leader>` = space)

| Key | Action |
|-----|--------|
| `<space>gpr` | List open PRs |
| `<space>gps` | Search PRs |
| `<space>gpR` | Start review on current PR |
| `<space>gir` | List issues |

## In a PR buffer (`\` = localleader)

| Key | Action |
|-----|--------|
| `\pd` | Show PR diff — starts the review view |
| `\pf` | List changed files |
| `\pc` | List PR commits |
| `\po` | Checkout PR branch locally |
| `\ca` | Add comment |
| `\cr` | Reply to comment |
| `\cd` | Delete comment |
| `\la` / `\ld` | Add / remove label |
| `\va` / `\vd` | Add / remove reviewer |
| `\aa` / `\ad` | Add / remove assignee |
| `\pm` | Merge PR |
| `\psm` | Squash and merge |
| `\r+` / `\r-` | Thumbs up / down reaction |
| `]c` / `[c` | Next / previous comment |
| `<C-b>` | Open in browser |
| `<C-y>` | Copy PR URL |
| `<C-r>` | Reload PR |
| `<space>qa` | Approve PR (this one is leader, not localleader) |

## In the review diff view

| Key | Action |
|-----|--------|
| `\ca` | Add review comment (works on a visual range too) |
| `\sa` | Add review suggestion |
| `\vs` | Submit review — opens the submit window |
| `\vd` | Discard review |
| `\e` | Focus changed-files panel |
| `\b` | Toggle changed-files panel |
| `\<space>` | Toggle file viewed state |
| `\C` | Review PR commits |
| `]q` / `[q` | Next / previous changed file |
| `]u` / `[u` | Next / previous unviewed file |
| `]t` / `[t` | Next / previous comment thread |
| `[Q` / `]Q` | First / last changed file |
| `gf` | Go to file |
| `<C-c>` | Close review tab |

## Submit window (after `\vs`)

| Key | Action |
|-----|--------|
| `<C-a>` | Approve |
| `<C-m>` | Comment |
| `<C-r>` | Request changes |
| `<C-c>` | Close review tab |

## Diffs outside a PR

| Key | Action |
|-----|--------|
| `<space>gd` | Diff working tree |
| `<space>gD` | Diff last commit |
| `<space>gH` | File history for current file |
| `<space>gx` | Close diffview |

## Known issue

Closing an Octo popup before the `gh` request finishes throws
`Invalid buffer id` from `octo/init.lua:111` — the async callback calls
`nvim_buf_call` without checking the buffer still exists. Cosmetic; the
buffer still loads. Present on octo master as of 2026-07-28.
