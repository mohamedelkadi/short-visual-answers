#!/usr/bin/env bash
# Install the short-visual-answers skill for Claude Code.
#   ./install.sh                 -> ~/.claude/skills (all projects)
#   ./install.sh --project DIR   -> DIR/.claude/skills (one project)
#   add --auto-load              -> also add a line to CLAUDE.md so it applies to every reply
#   ./install.sh --uninstall [--project DIR]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
base="$HOME/.claude"; auto=0; uninstall=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) base="$(cd "${2:?--project needs a directory}" && pwd)/.claude"; shift 2 ;;
    --auto-load) auto=1; shift ;;
    --uninstall) uninstall=1; shift ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
dest="$base/skills/short-visual-answers"
claude_md="$base/CLAUDE.md"
[ "$base" != "$HOME/.claude" ] && claude_md="$(dirname "$base")/CLAUDE.md"
marker="<!-- short-visual-answers -->"
if [ "$uninstall" = 1 ]; then
  rm -rf "$dest"
  if [ -f "$claude_md" ] && grep -q "$marker" "$claude_md"; then
    tmp="$(mktemp)"; grep -v "$marker" "$claude_md" > "$tmp" && mv "$tmp" "$claude_md"
  fi
  echo "Removed $dest"; exit 0
fi
mkdir -p "$(dirname "$dest")"
if [ -f "$dest/references/voice.md" ]; then cp "$dest/references/voice.md" /tmp/sva-voice.md.bak; fi
rm -rf "$dest"; cp -R "$here/skills/short-visual-answers" "$dest"
chmod +x "$dest/scripts/card.sh"
# Keep a voice file the user already filled in.
if [ -f /tmp/sva-voice.md.bak ]; then mv /tmp/sva-voice.md.bak "$dest/references/voice.md"; fi
echo "Installed skill -> $dest"
if [ "$auto" = 1 ]; then
  touch "$claude_md"
  if ! grep -q "$marker" "$claude_md"; then
    printf '\n%s Before any reply that explains, summarizes, reports status, compares options, drafts text for others, or builds an artifact, load the `short-visual-answers` skill and follow it. %s\n' "$marker" "$marker" >> "$claude_md"
    echo "Auto-load line added -> $claude_md"
  else
    echo "Auto-load line already in $claude_md"
  fi
fi
echo "Start a new Claude Code session to pick it up."
