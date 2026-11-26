#!/usr/bin/env bash
# Render an HTML card to a 2x PNG with a headless Chromium browser.
# Usage: card.sh card.html out.png [width=1200] [height=675]
# Set CHROME=/path/to/chrome to override browser detection.
set -euo pipefail
in="${1:-}"; out="${2:-}"; w="${3:-1200}"; h="${4:-675}"
if [ -z "$in" ] || [ -z "$out" ] || [ ! -f "$in" ]; then
  echo "usage: card.sh card.html out.png [width] [height]" >&2; exit 1
fi
find_chrome() {
  [ -n "${CHROME:-}" ] && { echo "$CHROME"; return; }
  for c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    [ -x "$c" ] && { echo "$c"; return; }
  done
  for c in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser chrome; do
    command -v "$c" >/dev/null 2>&1 && { command -v "$c"; return; }
  done
  return 1
}
chrome="$(find_chrome)" || { echo "No Chrome/Chromium/Edge found. Install one or set CHROME=/path/to/browser." >&2; exit 2; }
abs() { (cd "$(dirname "$1")" && printf '%s/%s' "$(pwd)" "$(basename "$1")"); }
mkdir -p "$(dirname "$out")"
in_abs="$(abs "$in")"; out_abs="$(abs "$out")"
"$chrome" --headless=new --disable-gpu --hide-scrollbars --no-sandbox \
  --force-device-scale-factor=2 --window-size="$w,$h" \
  --screenshot="$out_abs" "file://$in_abs" >/dev/null 2>&1
[ -s "$out_abs" ] || { echo "Render failed: $out_abs not created." >&2; exit 3; }
echo "$out_abs"
