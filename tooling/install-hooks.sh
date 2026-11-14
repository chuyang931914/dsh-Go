#!/usr/bin/env bash
# 装上 pre-push 钩子：推之前跑 repo-check，不一致就先拦住。
# 仓库不能提交 .git/hooks，所以钩子内容放在 tooling/hooks/ 里，这个脚本负责复制。
set -eu

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
hooks=$(git -C "$root" rev-parse --git-dir)/hooks
mkdir -p "$hooks"
cp "$root/tooling/hooks/pre-push" "$hooks/pre-push"
chmod +x "$hooks/pre-push"
echo "已安装: $hooks/pre-push"
