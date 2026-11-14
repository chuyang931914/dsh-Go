#!/usr/bin/env bash
# 仓库流程自检：分支一致性、版本号、文档同步、工作区干净。
# 手机端和电脑端都能跑；有任一问题退出码 1。
set -u

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
fail=0
say() { printf '%-28s %s\n' "$1" "$2"; }
bad() { say "$1" "$2"; fail=1; }

# 1. 工作区
if [ -n "$(git status --porcelain)" ]; then
  bad "worktree" "脏（$(git status --porcelain | wc -l) 个文件未提交）"
else
  say "worktree" "clean"
fi

# 2. 分支
branch=$(git rev-parse --abbrev-ref HEAD)
say "branch" "$branch"

# 3. 本地 main 与 phone
if git rev-parse --verify -q main >/dev/null && git rev-parse --verify -q phone >/dev/null; then
  m=$(git rev-parse main); p=$(git rev-parse phone)
  if [ "$m" = "$p" ]; then say "local main=phone" "${p:0:7}"; else bad "local main=phone" "分叉 ${m:0:7} / ${p:0:7}"; fi
fi

# 4. 远端 main 与 phone（拿不到就跳过，不判失败）
if git fetch -q origin 2>/dev/null; then
  rm=$(git rev-parse origin/main 2>/dev/null || true)
  rp=$(git rev-parse origin/phone 2>/dev/null || true)
  if [ -n "$rm" ] && [ -n "$rp" ]; then
    if [ "$rm" = "$rp" ]; then say "remote main=phone" "${rp:0:7}"; else bad "remote main=phone" "分叉 ${rm:0:7} / ${rp:0:7}"; fi
    cur=$(git rev-parse HEAD)
    if [ "$cur" = "$rp" ]; then say "HEAD=remote phone" "ok"; else bad "HEAD=remote phone" "本地 ${cur:0:7} / 远端 ${rp:0:7}"; fi
  fi
fi

# 5. 版本号与版本表
ver=$(sed -n 's/^version: //p' app/pubspec.yaml | head -1)
say "pubspec version" "$ver"
if [ -n "$ver" ]; then
  short=${ver%%+*}
  if grep -q "^| $short |" UPGRADE_TABLE.md; then say "version in table" "$short"; else bad "version in table" "UPGRADE_TABLE 里没有 $short 这一行"; fi
fi

# 6. 状态页大小（自定上限 6KB）
bytes=$(wc -c < PROJECT_STATE.md)
if [ "$bytes" -le 6144 ]; then say "PROJECT_STATE" "${bytes}B"; else bad "PROJECT_STATE" "${bytes}B 超过 6KB"; fi

# 7. AGENTS 软链
if [ -L /root/workspace/AGENTS.md ]; then say "AGENTS symlink" "$(readlink /root/workspace/AGENTS.md)"; else say "AGENTS symlink" "不是软链（可忽略）"; fi

# 8. 插件目录残留
extra=$(ls "$HOME/.dsh/dsh-go/plugins" 2>/dev/null | grep -v '^local-ai-cost$' || true)
if [ -n "$extra" ]; then say "extra plugins" "$(echo "$extra" | tr '\n' ' ')"; fi

echo
if [ "$fail" = 0 ]; then echo "RESULT OK"; else echo "RESULT FAIL"; fi
exit "$fail"
