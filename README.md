# Anthropic Features Watcher

**Keeps Claude Code up to date on new Anthropic features so it stops telling you things don't exist when they do.**

Claude has a "knowledge cutoff" — a date after which it doesn't know what happened. So when Anthropic ships something new (like Claude Design), Claude Code often has no idea and will confidently tell you it doesn't exist. This fixes that: it keeps a short, auto-updated list of new features that Claude reads and trusts.

You don't need to be technical, and you don't need a terminal. It installs **inside Claude Code** like an app from an app store.

---

## Install it (two lines, inside Claude Code)

In Claude Code, type:

```
/plugin marketplace add winterje90/anthropic-features-watcher
```

Then:

```
/plugin install anthropic-features-watcher@anthropic-features-watcher
```

(Or just type `/plugin`, go to the **Discover** tab, find "anthropic-features-watcher," and press Enter to install.)

That's it. Restart Claude Code (or start a new chat) and it's working.

---

## How to know it's working

Ask Claude Code:

> **What is Claude Design?**

If it tells you what Claude Design is (a tool for creating visual designs by chatting with Claude) instead of saying it's never heard of it — you're set.

You can also just ask: **"What new Anthropic features do you know about?"**

---

## How it stays current

Once a day, when you open Claude Code, it quietly checks Anthropic's news page and the Claude Code release notes and adds anything genuinely new to its list. No setup, no schedule to manage. (It only runs once per 24 hours, so it won't slow you down.)

If you ever want to force an update, just say: **"Update my Anthropic features list."**

---

## Common questions

**Does it cost anything?** Almost nothing. The daily check is tiny, and on most days there's no news so it does nothing.

**Is it private/safe?** Yes. It only reads two public Anthropic web pages. It doesn't send your data anywhere, and it backs up its list before changing it.

**How do I remove it?** In Claude Code: `/plugin uninstall anthropic-features-watcher@anthropic-features-watcher`.

---

## Want a guaranteed daily schedule instead?

The plugin refreshes when you *open* Claude Code, which is perfect for most people. If you'd rather have it run on a strict schedule (e.g. every morning at 7am whether or not Claude Code is open), there's a standalone version in the [`manual-install/`](./manual-install) folder that uses your computer's built-in scheduler. Its README walks you through it — or just point Claude Code at that folder and ask it to set it up.

---

## What's in this repo

| Path | What it is |
|------|------------|
| `.claude-plugin/` | Plugin + marketplace manifests (how Claude Code installs it). |
| `hooks/` | The once-a-day check that runs when you open Claude Code. |
| `skills/` | Lets you ask "what features exist" or "update the list." |
| `claude-features.md` | The starting feature list (kept updated automatically). |
| `manual-install/` | Optional standalone version with a true daily background schedule. |
