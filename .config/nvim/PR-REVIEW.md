# PR Review in Neovim

Cheatsheet for the octo.nvim + diffview.nvim workflow.

## Opening a review

| Key | Action |
|-----|--------|
| `<leader>gpr` | List open PRs |
| `<leader>gps` | Search PRs |
| `<leader>gpR` | Start review on current PR |
| `<leader>gir` | List issues |

## Inside a review

| Key | Action |
|-----|--------|
| `]q` / `[q` | Next / previous changed file |
| `]t` / `[t` | Next / previous comment thread |
| `<space>ca` | Add a comment on the current line |
| `<space>cs` | Add a suggestion |
| `<space>ca` (visual) | Comment on a range |
| `<space>e` | Submit the review |

## Submitting

From the submit window: `<C-a>` approve, `<C-m>` comment, `<C-r>` request changes.

## Diffs outside a PR

| Key | Action |
|-----|--------|
| `<leader>gd` | Diff working tree |
| `<leader>gD` | Diff last commit |
| `<leader>gH` | File history for current file |
| `<leader>gx` | Close diffview |
