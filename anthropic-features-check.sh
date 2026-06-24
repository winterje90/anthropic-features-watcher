#!/bin/bash
#
# anthropic-features-check.sh
# Daily watcher that keeps a markdown file current with newly released
# Anthropic / Claude / Claude Code features.
#
# Dependency: Claude Code only (uses its built-in WebFetch/Read/Write tools).
# No firecrawl, no Python, no API keys. Runs one cheap `claude -p` call per day.
#
# Setup: see README.md. Schedule with launchd (macOS) or cron (Linux).

set -uo pipefail

# Where the feature list lives. Change if you keep it elsewhere.
FEATURES_FILE="$HOME/.claude/context/claude-features.md"
LOG="/tmp/anthropic-features-check.log"

# Resolve the claude binary (scheduled jobs don't inherit your shell PATH).
CLAUDE_BIN="$(command -v claude 2>/dev/null)"
if [ -z "$CLAUDE_BIN" ]; then
  for p in "$HOME/.local/bin/claude" /opt/homebrew/bin/claude /usr/local/bin/claude; do
    [ -x "$p" ] && CLAUDE_BIN="$p" && break
  done
fi

{ echo ""; echo "===== anthropic-features-check: $(date) ====="; } >> "$LOG"

if [ -z "$CLAUDE_BIN" ]; then
  echo "ERROR: 'claude' not found. Put it on PATH or edit CLAUDE_BIN below." >> "$LOG"; exit 1
fi
if [ ! -f "$FEATURES_FILE" ]; then
  echo "ERROR: $FEATURES_FILE not found. Copy the starter claude-features.md there." >> "$LOG"; exit 1
fi

# Safety: back up before any edit so a bad run can never destroy history.
cp "$FEATURES_FILE" "$FEATURES_FILE.bak"

read -r -d '' PROMPT <<EOF
You maintain a single markdown file that tracks newly released Anthropic / Claude features.

FILE: $FEATURES_FILE

STEPS:
1. Read the file. The table's Link column already lists every feature recorded so far — this is your dedup memory.
2. WebFetch https://www.anthropic.com/news and list the recent items (title, /news/ slug, date).
3. WebFetch https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md and read the newest versions (above the highest version already recorded in the file).
4. Determine which items are NOT already in the file.
5. For each NEW item, apply these rules:
   INCLUDE (a feature/capability a user would expect Claude to know it has):
     - model releases
     - Claude Code features (new commands, hooks, flags, modes, integrations) — notable user-facing ones, skip pure bugfixes/polish
     - Claude.ai app features
     - API capabilities, tools, integrations
   EXCLUDE: funding/business news, partnerships, policy/safety/regulatory posts, pure research papers,
            transparency reports, events, hiring/fellowship programs, op-eds.
6. APPEND a row for each qualifying NEW item to the existing table. Do NOT modify or reorder existing rows.
   - Column format: | Date | Feature | Category | What it is | Link |
   - Date: ISO date (YYYY-MM-DD) for news items; the version string (e.g. v2.1.200) for Claude Code changelog items.
   - Category: one of Model, Claude Code, Claude.ai, API, Integrations.
   - "What it is": one plain sentence.
   - Link: full https://www.anthropic.com/news/<slug> for news; https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md for changelog items.
   - Keep the table roughly newest-first.
7. Update frontmatter: set last_updated to today and feature_count to the new total.
8. Write the file back. If there are NO new qualifying items, make NO changes and stop.

Be conservative: when unsure whether something is a real feature vs. an announcement, EXCLUDE it.
EOF

"$CLAUDE_BIN" -p "$PROMPT" --model sonnet --allowedTools "WebFetch,Read,Write" >> "$LOG" 2>&1
RC=$?
echo "exit code: $RC" >> "$LOG"
exit $RC
