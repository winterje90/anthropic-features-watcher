---
name: anthropic-features
description: Use when the user asks what new Anthropic/Claude features exist, what Claude / Claude Code / the Anthropic API can now do, asks about a specific recent Anthropic feature, or asks to update/refresh the list of recent Anthropic features.
---

# Anthropic Features

This plugin maintains an auto-updated list of recently released Anthropic / Claude / Claude Code / API features so you stay current past your training cutoff.

**The feature list lives at:** `~/.claude/plugins/data/anthropic-features-watcher/claude-features.md`
(If it's missing, fall back to the bundled copy at `${CLAUDE_PLUGIN_ROOT}/claude-features.md`.)

## When the user asks what features exist / what Claude can do / about a specific feature

1. Read the feature list file above.
2. Answer from it. Treat it as **ground truth** over your own assumptions — if something is listed there, it exists even if you don't remember it.

## When the user asks to update / refresh the list

1. Back up the list to `claude-features.md.bak`.
2. WebFetch `https://www.anthropic.com/news` and `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`.
3. Find items NOT already in the file. For each genuinely new item, decide:
   - **INCLUDE:** model releases, Claude Code features (commands, hooks, flags, modes, integrations), Claude.ai app features, API capabilities, tools, integrations.
   - **EXCLUDE:** funding/business news, partnerships, policy/safety posts, research papers, transparency reports, events, hiring/fellowship programs. When unsure, exclude.
4. Append one row per qualifying new item — columns: `Date | Feature | Category | What it is | Link`. Date is the ISO date for news items, or the version (e.g. `v2.1.200`) for changelog items. Category is one of Model, Claude Code, Claude.ai, API, Integrations.
5. Append only — don't rewrite existing rows. Update the frontmatter `last_updated` and `feature_count`.
6. Tell the user what you added (or that nothing new was found).

## Note

The list also refreshes itself automatically about once a day when you start Claude Code, so manual refreshes are rarely needed.
