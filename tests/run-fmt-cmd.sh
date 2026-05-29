#!/usr/bin/env bash
# shu fmt 子命令：格式化 .su 后仍能通过 check。
set -e
cd "$(dirname "$0")/.."
SHU=${SHU:-./compiler/shu}
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  fi
fi

# 故意错误缩进；fmt 写回后应打印 fmt OK 且 check 仍通过（须含分号）
printf 'function main(): i32 {\nreturn 0;\n}\n' >/tmp/shu_fmt_cmd_test.su
fmt_out=$($SHU fmt /tmp/shu_fmt_cmd_test.su 2>&1)
echo "$fmt_out" | grep -q "fmt OK" || { echo "expected fmt OK on reformatted file, got: $fmt_out"; exit 1; }
chk_out=$($SHU check /tmp/shu_fmt_cmd_test.su 2>&1)
if [ -n "$chk_out" ]; then
  echo "expected silent check after fmt, got: $chk_out"
  exit 1
fi
chmod +x tests/run-fmt-check-cmd.sh 2>/dev/null || true
SHU="$SHU" ./tests/run-fmt-check-cmd.sh
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
SHU="$SHU" ./tests/run-fmt-wrap.sh

echo "fmt cmd test OK"
