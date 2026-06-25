#!/usr/bin/env bash

input=$(cat)

# ── Parse JSON ───────────────────────────────────────────────────────────────
cwd=$(echo "$input"          | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"        | jq -r '.model.display_name // empty')
repo_owner=$(echo "$input"   | jq -r '.workspace.repo.owner // empty')
repo_name=$(echo "$input"    | jq -r '.workspace.repo.name // empty')
git_worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
used_pct=$(echo "$input"     | jq -r '.context_window.used_percentage // empty')
vim_mode=$(echo "$input"     | jq -r '.vim.mode // empty')
pr_num=$(echo "$input"       | jq -r '.pr.number // empty')
pr_state=$(echo "$input"     | jq -r '.pr.review_state // empty')

# ── Color helpers (fg only — no bg blocks) ───────────────────────────────────
reset="\033[0m"
bold="\033[1m"
dim="\033[2m"
fg() { printf "\033[38;5;%sm" "$1"; }

SEP=" $(fg 240)·${reset} "   # dim dot separator

# ── Directory ────────────────────────────────────────────────────────────────
home="$HOME"
display_dir="${cwd/#$home/\~}"
display_dir=$(echo "$display_dir" | awk -F'/' '{
  if (NF > 4) print "…/" $(NF-1) "/" $NF
  else        print $0
}')

# ── Vim mode ─────────────────────────────────────────────────────────────────
vim_part=""
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    NORMAL)  vim_part="$(fg 179)${bold}N${reset}" ;;   # amber
    INSERT)  vim_part="$(fg 71)${bold}I${reset}"  ;;   # green
    VISUAL*) vim_part="$(fg 135)${bold}V${reset}" ;;   # violet
    *)       vim_part="$(fg 240)${bold}${vim_mode:0:1}${reset}" ;;
  esac
fi

# ── Directory segment ─────────────────────────────────────────────────────────
dir_part="$(fg 110)${display_dir}${reset}"    # soft blue

# ── Git segment ───────────────────────────────────────────────────────────────
git_part=""
if [ -n "$repo_owner" ] && [ -n "$repo_name" ]; then
  git_part="$(fg 71) ${repo_owner}/${repo_name}${reset}"  # muted green
  if [ -n "$git_worktree" ]; then
    git_part="${git_part}$(fg 240) ${git_worktree}${reset}"
  fi
fi

# ── PR segment ────────────────────────────────────────────────────────────────
pr_part=""
if [ -n "$pr_num" ]; then
  case "$pr_state" in
    approved)          pr_color=71;  pr_icon="" ;;
    changes_requested) pr_color=167; pr_icon="" ;;
    draft)             pr_color=240; pr_icon="" ;;
    *)                 pr_color=75;  pr_icon="" ;;
  esac
  pr_part="$(fg "$pr_color")${pr_icon} #${pr_num}${reset}"
fi

# ── Model segment ─────────────────────────────────────────────────────────────
model_part=""
if [ -n "$model" ]; then
  short=$(echo "$model" | sed 's/Claude //;s/ ([^)]*)//g')
  model_part="$(fg 141) ${short}${reset}"    # soft purple
fi

# ── Context segment ───────────────────────────────────────────────────────────
ctx_part=""
if [ -n "$used_pct" ]; then
  ctx_int=$(printf "%.0f" "$used_pct")
  if   [ "$ctx_int" -ge 80 ]; then ctx_color=167   # red-ish
  elif [ "$ctx_int" -ge 50 ]; then ctx_color=172   # orange
  else                              ctx_color=71    # green
  fi
  ctx_part="$(fg "$ctx_color") ${ctx_int}%${reset}"
fi

# ── Assemble ──────────────────────────────────────────────────────────────────
parts=()
[ -n "$vim_part"   ] && parts+=("$vim_part")
parts+=("$dir_part")
[ -n "$git_part"   ] && parts+=("$git_part")
[ -n "$pr_part"    ] && parts+=("$pr_part")
[ -n "$model_part" ] && parts+=("$model_part")
[ -n "$ctx_part"   ] && parts+=("$ctx_part")

# Join with separator
out=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && out="${out}${SEP}"
  out="${out}${parts[$i]}"
done

printf "%b" "$out"
