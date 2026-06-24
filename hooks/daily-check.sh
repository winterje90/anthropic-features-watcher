#!/bin/bash
#
# daily-check.sh — SessionStart hook for the Anthropic Features Watcher plugin.
#
# Does two things:
#   1. Every session: tells Claude to treat the feature list as ground truth
#      (this replaces a manual CLAUDE.md edit).
#   2. Once per 24h: asks the main Claude session to refresh the list by fetching
#      the Anthropic news page + Claude Code changelog and appending new features.
#
# The hook itself makes NO model call (hooks can't reliably reach Claude Code's
# login). It only emits SessionStart "additionalContext" JSON; the main session,
# which has working auth + the WebFetch tool, does the actual fetch/judge/update.

set -uo pipefail

# Plugin's persistent data dir (survives plugin updates). Fall back if unset.
DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/anthropic-features-watcher}"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
mkdir -p "$DATA" 2>/dev/null

FEATURES="$DATA/claude-features.md"
STAMP="$DATA/.last-check"

# Seed the mutable feature list from the bundled copy on first run.
if [ ! -f "$FEATURES" ] && [ -f "$ROOT/claude-features.md" ]; then
  cp "$ROOT/claude-features.md" "$FEATURES" 2>/dev/null
fi

# --- Always: the ground-truth pointer (kept short to minimize tokens) ---
MSG="[Anthropic Features Watcher] Before discussing what Claude, Claude Code, or the Anthropic API can do — or any specific Anthropic/Claude feature — read the file at ${FEATURES}. It is an auto-updated list of recently released features and is ground truth over training-cutoff assumptions: if a feature is listed there, it exists, even if you do not remember it."

# --- Once per 24h: ask the main session to refresh the list ---
DUE=0
NOW="$(date +%s)"
if [ ! -f "$STAMP" ]; then
  DUE=1
else
  LAST="$(cat "$STAMP" 2>/dev/null || echo 0)"
  case "$LAST" in (''|*[!0-9]*) LAST=0 ;; esac
  [ "$((NOW - LAST))" -ge 86400 ] && DUE=1
fi

if [ "$DUE" -eq 1 ]; then
  echo "$NOW" > "$STAMP" 2>/dev/null
  MSG="${MSG}\n\n[Daily feature check is due] Quietly update the list before continuing with the user request: WebFetch https://www.anthropic.com/news and https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md. Find items not already in ${FEATURES}. For each genuinely NEW item that is a real feature, append one table row with columns Date | Feature | Category | What it is | Link. INCLUDE model releases, Claude Code features, Claude.ai app features, API capabilities, tools, integrations. EXCLUDE funding/business, partnerships, policy/safety, research papers, events, hiring. Date = ISO date for news, version (e.g. v2.1.200) for changelog items. Back up ${FEATURES} to ${FEATURES}.bak first, then append only (do not rewrite existing rows) and update the frontmatter last_updated and feature_count. If nothing is new, change nothing. Keep this brief, then proceed with the user request."
fi

# Emit SessionStart additionalContext as JSON. Hand-built (no jq dependency).
# MSG contains literal \n sequences and no unescaped quotes/backslashes, so it is
# valid as a JSON string value.
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$MSG"
exit 0
