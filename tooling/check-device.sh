#!/usr/bin/env bash
# One glance at the phone's actual state: repo, installed APK, UI config,
# plugin, secrets and install baseline. Run from the repo root on the phone.
set -uo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
fail=0
say() { printf '%s\n' "$*"; }
bad() { say "FAIL  $*"; fail=1; }

say "repo      $(git log -1 --format='%h %s')"
say "version   $(grep '^version:' app/pubspec.yaml | awk '{print $2}')"
say "worktree  $(if [ -z "$(git status --porcelain)" ]; then echo clean; else echo DIRTY; fi)"
say "branch    $(git rev-parse --abbrev-ref HEAD)"

if [ -x /system/bin/cmd ]; then
  installed="$(/system/bin/cmd package list packages --show-versioncode 2>/dev/null | grep dsh_app || true)"
  say "installed ${installed:-unknown}"
else
  say "installed (not on phone; skipped)"
fi

ui="$DSH_HOME/dsh-go/ui.json"
if [ -L "$ui" ]; then
  bad "ui.json is a symlink; the app reads a real rootfs file"
elif [ ! -f "$ui" ]; then
  bad "ui.json missing at $ui"
else
  say "ui.json   regular file"
  python3 - "$ui" <<'PY' || fail=1
import json, sys
p = sys.argv[1]
try:
    d = json.load(open(p))
except Exception as e:
    print("FAIL  ui.json invalid:", e); raise SystemExit(1)
hide = d.get("hide") or []
groups = (d.get("drawer") or {}).get("groups") or []
print("ui hide   ", ",".join(hide) if hide else "-")
print("ui groups ", " -> ".join(groups) if groups else "-")
if "pluginCapsule" not in hide:
    print("WARN  pluginCapsule is not hidden"); raise SystemExit(2)
PY
fi

P="$DSH_HOME/dsh-go/plugins/local-ai-cost"
if [ -f "$P/lib/index.js" ]; then
  say "plugin    local-ai-cost source present"
else
  bad "plugin local-ai-cost missing"
fi
if [ -f "$P/secrets.json" ]; then
  mode="$(stat -c '%a' "$P/secrets.json")"
  [ "$mode" = "600" ] && say "secrets   600" || bad "secrets.json mode is $mode (want 600)"
else
  say "secrets   not configured"
fi

for f in "$DSH_HOME"/dsh-app/install-baseline-*.txt; do
  [ -e "$f" ] && say "baseline  $(basename "$f")"
done
say "sessions  $(find "$DSH_HOME/sessions" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l) dir(s)"
[ "$fail" -eq 0 ] && say "RESULT    OK" || say "RESULT    CHECK FAILURES ABOVE"
exit "$fail"
