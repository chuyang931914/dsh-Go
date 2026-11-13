#!/bin/bash
# 轮询两端信箱：有新消息就打印，按 Ctrl-C 退出。
# 用法：bash tooling/watch-inbox.sh [间隔秒数，默认 20]
set -u
cd "$(dirname "$0")/.." || exit 1
interval="${1:-20}"
echo "watch-inbox: 每 ${interval}s 拉一次 origin/phone，只看 docs/inbox.md 的变化"
last="$(git rev-parse HEAD)"
while true; do
  git fetch -q origin phone || { sleep "$interval"; continue; }
  remote="$(git rev-parse origin/phone)"
  if [ "$remote" != "$last" ]; then
    echo "=== 新提交 $(git log -1 --format='%h %s' origin/phone)"
    if git diff --quiet "$last" origin/phone -- docs/inbox.md 2>/dev/null; then
      echo "（信箱没变）"
    else
      echo "--- 信箱变化 ---"
      git diff "$last" origin/phone -- docs/inbox.md | sed -n 's/^+//p' | grep -v '^++' | head -40
      echo "----------------"
    fi
    last="$remote"
  fi
  sleep "$interval"
done
