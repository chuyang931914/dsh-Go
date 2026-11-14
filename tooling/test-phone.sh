#!/usr/bin/env bash
# 手机端测试：analyze + 非金色图测试。金色图依赖电脑侧字体，这里排除。
# 用法：tooling/test-phone.sh [额外目录，默认 test/chat]
set -u

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
cd app || exit 1
# shellcheck disable=SC1091
source /root/dev/dsh-env.sh >/dev/null 2>&1 || true
export DSH_TEST_FONT_DIR=${DSH_TEST_FONT_DIR:-/usr/share/fonts/opentype/noto}

dirs=${*:-test/chat}

echo "== dart analyze =="
dart analyze || exit 1

echo
echo "== 非金色图测试 =="
# 金色图测试按内容识别(含 matchesGoldenFile 的文件一律跳过),不靠文件名。
files=$(find $dirs -name '*_test.dart' ! -path '*/goldens/*' | sort | while read -r f; do
  grep -q 'matchesGoldenFile' "$f" || echo "$f"
done)
if [ -z "$files" ]; then
  echo "没有找到可跑的测试文件"
  exit 1
fi
count=$(printf '%s\n' "$files" | wc -l)
echo "$count 个文件"
# shellcheck disable=SC2086
flutter test $files
