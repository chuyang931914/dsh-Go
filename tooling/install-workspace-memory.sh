#!/usr/bin/env bash
# 把工作区的 AGENTS.md 指向仓库里的 PROJECT_STATE.md（新对话开机记忆）。
# 换机/重装后、克隆完仓库执行一次。
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace="${DSH_WORKSPACE:-$(dirname "$root")}"
# The phone keeps the repo under /root/workspace/dsh-Go, the computer under
# /root/dsh-Go. If the parent is /root but /root/workspace exists, that is
# the DSH workspace whose AGENTS.md a new conversation actually loads.
if [ -z "${DSH_WORKSPACE:-}" ] && [ "$workspace" = "/root" ] && [ -d "/root/workspace" ]; then
  workspace="/root/workspace"
fi
target="$workspace/AGENTS.md"
if [[ -e $target && ! -L $target ]]; then
  echo "install-workspace-memory: $target already exists (not a symlink); leaving it alone" >&2
  exit 1
fi
ln -sfn "$root/PROJECT_STATE.md" "$target"
echo "install-workspace-memory: $target -> $root/PROJECT_STATE.md"
