# Anthropic Features Watcher

**Keeps Claude Code up to date on new Anthropic features so it stops telling you things don't exist when they do.**

Claude has a "knowledge cutoff" — a date after which it doesn't know what happened. So when Anthropic ships something new (like Claude Design), Claude Code often has no idea it exists and will confidently tell you it doesn't. Annoying.

This is a tiny helper that fixes that. Once a day it quietly checks Anthropic's announcements, decides what's an actual new feature, and writes it to a list that Claude Code reads. From then on, when you ask Claude about a recent feature, it actually knows.

You don't need to be technical. **You don't run any commands yourself — you just ask Claude Code to set it up, and it does the rest.**

---

## What you need

Just **Claude Code**, installed and signed in. That's the only requirement. No accounts to create, no API keys, no extra software to install.

---

## How to install it (the easy way)

Open Claude Code, then copy and paste this message to it:

> **Install the Anthropic Features Watcher from https://github.com/winterje90/anthropic-features-watcher — read its README and set it up for me completely: copy the files into place, add the line to my CLAUDE.md, schedule it to run daily, and seed the list once so it works right away. Tell me when it's done.**

That's the whole install. Claude Code reads this page, puts everything where it belongs, schedules the daily check, and fills in the starting list of features. Takes about a minute.

---

## How to know it's working

After install, ask Claude Code something like:

> **What is Claude Design?**

If it tells you what Claude Design is (a tool for creating visual designs by chatting with Claude) instead of saying it's never heard of it — it's working. Claude is now reading the feature list.

You can also just open the file it maintains — `~/.claude/context/claude-features.md` — to see the running list.

---

## Common questions

**Does it cost anything?**
Almost nothing. It runs once a day and on most days there's no news, so it does basically nothing. When there is news, it's a few cents at most. Over a year, expect a couple of dollars.

**Is it safe? Does it send my data anywhere?**
Yes, it's safe. It only *reads* two public Anthropic web pages (the news page and the Claude Code release notes). It doesn't touch your files beyond the one feature list, doesn't send your data anywhere, and always saves a backup before it changes anything.

**Will it slow down or clutter my computer?**
No. It's one small text file and a short script that runs for a few seconds each morning.

**How do I turn it off?**
Just tell Claude Code: *"Remove the Anthropic Features Watcher."* It'll undo everything.

**Can I change what it watches or when it runs?**
Yes — tell Claude Code what you want (e.g. "also watch the API release notes" or "run it at 9am instead of 7am") and it'll adjust the settings.

---

## What's in this folder

| File | What it's for |
|------|---------------|
| `anthropic-features-check.sh` | The daily helper script. |
| `claude-features.md` | The starting feature list (Claude keeps it updated). |
| `CLAUDE.md-snippet.md` | The one line that tells Claude to read the list. |
| `com.claude-code.anthropic-features-check.plist` | The "run it daily" schedule (Mac). |
| `README.md` | This file. |

---

<!-- ============================================================= -->
<!-- INSTRUCTIONS FOR CLAUDE CODE — follow these to install.       -->
<!-- The human above just asked you to "set it up." Do this:       -->
<!-- ============================================================= -->

## For Claude Code: installation steps

You are installing this on the user's machine. The user is non-technical — do the work for them, explain briefly in plain language, and don't ask them to run commands. Follow these steps:

1. **Get the files.** If you're not already running inside a local copy of this repo, fetch the five files from `https://github.com/winterje90/anthropic-features-watcher` (raw URLs, or `git clone` to a temp dir).

2. **Place the files:**
   - Copy `anthropic-features-check.sh` → `~/.claude/scripts/` and make it executable (`chmod +x`).
   - Copy `claude-features.md` → `~/.claude/context/` (create the folder if needed). **Do not overwrite** an existing one — if it's already there, leave it.

3. **Wire up the CLAUDE.md pointer.** Add the section from `CLAUDE.md-snippet.md` to the user's global `~/.claude/CLAUDE.md`. Note: `~/.claude/CLAUDE.md` is often a **symlink** — resolve it (`readlink`) and edit the real target file. If the "Claude Feature Awareness" section is already present, skip.

4. **Schedule the daily run** for the user's OS:
   - **macOS:** edit `com.claude-code.anthropic-features-check.plist` — set the script path to the user's real home, and set `PATH` to include the directory from `dirname "$(command -v claude)"`. Copy it to `~/Library/LaunchAgents/` and `launchctl load` it. Confirm with `launchctl list | grep anthropic-features`.
   - **Linux:** add a cron line: `0 7 * * * $HOME/.claude/scripts/anthropic-features-check.sh`.
   - **Windows:** create a daily Scheduled Task that runs the script via the user's shell.

5. **Seed the list once** so it's useful immediately: run `~/.claude/scripts/anthropic-features-check.sh` once.
   - **IMPORTANT — expected gotcha:** the script calls `claude -p` (headless). Claude Code credentials are stored in the **macOS Keychain**, and your sandboxed Bash tool usually **can't read the Keychain**, so this in-session test will fail with *"Not logged in · Please run /login."* **This is a false negative, not a real failure.** The scheduled job runs in the user's normal session and works fine. To actually seed it now, either (a) re-run the script with the sandbox disabled, or (b) just populate `claude-features.md` yourself directly: WebFetch `https://www.anthropic.com/news` and `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`, apply the INCLUDE/EXCLUDE rules in the script, and write the rows. Option (b) is the most reliable.

6. **Confirm to the user** in plain language that it's installed, scheduled, and seeded, and tell them how to test it ("ask me what Claude Design is").

**INCLUDE/EXCLUDE rules** (same as the script): INCLUDE model releases, Claude Code features, Claude.ai app features, API capabilities, tools, integrations. EXCLUDE funding/business news, partnerships, policy/safety posts, research papers, transparency reports, events, hiring/fellowship programs. When unsure, exclude.

## For Claude Code: uninstall steps

If the user asks to remove it: delete `~/.claude/scripts/anthropic-features-check.sh`; remove the "Claude Feature Awareness" section from their `CLAUDE.md`; unload and delete the launchd plist (`launchctl unload ...` then `rm ~/Library/LaunchAgents/com.claude-code.anthropic-features-check.plist`) or remove the cron line. Optionally leave `~/.claude/context/claude-features.md` in place (it's harmless) or delete it if they want a clean removal.
