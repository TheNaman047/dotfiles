#!/usr/bin/env bash
#
# Claude Code statusline — minimal colored-text style.
#
# SAFETY: reads only the JSON Claude Code sends on stdin plus the LOCAL git
# branch (via `git branch --show-current`, a read-only local query). No network
# access, no curl/wget, no eval of external input. All jq lookups use `// empty`
# so missing fields degrade to blank rather than erroring.

input=$(cat)

# ── Parse JSON ───────────────────────────────────────────────────────────────
cwd=$(echo "$input"        | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"      | jq -r '.model.display_name // empty')
repo_owner=$(echo "$input" | jq -r '.workspace.repo.owner // empty')
repo_name=$(echo "$input"  | jq -r '.workspace.repo.name // empty')
wt_name=$(echo "$input"    | jq -r '.worktree.name // .workspace.git_worktree // empty')
effort=$(echo "$input"     | jq -r '.effort.level // empty')
rl_5h=$(echo "$input"      | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_7d=$(echo "$input"      | jq -r '.rate_limits.seven_day.used_percentage // empty')
ctx_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')
vim_mode=$(echo "$input"   | jq -r '.vim.mode // empty')
pr_num=$(echo "$input"     | jq -r '.pr.number // empty')
pr_state=$(echo "$input"   | jq -r '.pr.review_state // empty')

# ── Color helpers (foreground only — no background blocks) ────────────────────
reset="\033[0m"
bold="\033[1m"
fg() { printf "\033[38;5;%sm" "$1"; }

SEP=" $(fg 240)·${reset} "   # dim dot separator

# ── Icons (Nerd Font) ─────────────────────────────────────────────────────────
I_WORKTREE=""   # repo-forked
I_REPO=""       # repo
I_BRANCH=""     # git branch
I_MODEL="󰚩"       # robot
I_EFFORT=""     # gauge / speedometer
I_QUOTA=""      # clock (time-window quota)
I_CTX=""        # graph

# ── Branch name (worktree name if present, else local git branch) ─────────────
branch=""
if [ -n "$wt_name" ]; then
  branch="$wt_name"
elif [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
fi

# ── Build segments ────────────────────────────────────────────────────────────
parts=()

# 1. Vim mode (leftmost, only when active)
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    NORMAL)  parts+=("$(fg 179)${bold}N${reset}") ;;
    INSERT)  parts+=("$(fg 71)${bold}I${reset}")  ;;
    VISUAL*) parts+=("$(fg 135)${bold}V${reset}") ;;
    *)       parts+=("$(fg 240)${bold}${vim_mode:0:1}${reset}") ;;
  esac
fi

# 2. Worktree indicator (only when in a worktree)
if [ -n "$wt_name" ]; then
  parts+=("$(fg 175)${I_WORKTREE} worktree${reset}")
fi

# 3. Repo  owner/name
if [ -n "$repo_owner" ] && [ -n "$repo_name" ]; then
  parts+=("$(fg 71)${I_REPO} ${repo_owner}/${repo_name}${reset}")
fi

# 4. Branch / worktree name
if [ -n "$branch" ]; then
  parts+=("$(fg 110)${I_BRANCH} ${branch}${reset}")
fi

# 5. PR badge (only when a PR exists)
if [ -n "$pr_num" ]; then
  case "$pr_state" in
    approved)          pr_color=71  ;;
    changes_requested) pr_color=167 ;;
    draft)             pr_color=240 ;;
    *)                 pr_color=75  ;;
  esac
  parts+=("$(fg "$pr_color") #${pr_num}${reset}")
fi

# 6. Model (Claude prefix stripped for brevity)
if [ -n "$model" ]; then
  short=$(echo "$model" | sed 's/Claude //;s/ ([^)]*)//g')
  parts+=("$(fg 141)${I_MODEL} ${short}${reset}")
fi

# 7. Effort level (color by intensity)
if [ -n "$effort" ]; then
  case "$effort" in
    low)    eff_color=109 ;;
    medium) eff_color=73  ;;
    high)   eff_color=179 ;;
    xhigh)  eff_color=172 ;;
    max)    eff_color=167 ;;
    *)      eff_color=245 ;;
  esac
  parts+=("$(fg "$eff_color")${I_EFFORT} ${effort}${reset}")
fi

# 8. Quota usage — prefer 5h rate limit; fall back to context window.
#    color: green < 50 < orange < 80 < red
color_pct() {
  local p="$1"
  if   [ "$p" -ge 80 ]; then echo 167
  elif [ "$p" -ge 50 ]; then echo 172
  else                       echo 71
  fi
}
if [ -n "$rl_5h" ]; then
  p5=$(printf "%.0f" "$rl_5h")
  quota_seg="$(fg "$(color_pct "$p5")")${I_QUOTA} 5h ${p5}%${reset}"
  if [ -n "$rl_7d" ]; then
    p7=$(printf "%.0f" "$rl_7d")
    quota_seg="${quota_seg}$(fg 240)/${reset}$(fg "$(color_pct "$p7")")7d ${p7}%${reset}"
  fi
  parts+=("$quota_seg")
elif [ -n "$ctx_pct" ]; then
  pc=$(printf "%.0f" "$ctx_pct")
  parts+=("$(fg "$(color_pct "$pc")")${I_CTX} ${pc}%${reset}")
fi

# ── Join with separator ───────────────────────────────────────────────────────
out=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && out="${out}${SEP}"
  out="${out}${parts[$i]}"
done

printf "%b" "$out"
