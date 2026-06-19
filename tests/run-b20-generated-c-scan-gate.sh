#!/usr/bin/env bash
# B-20 v1：runtime generated_c_needs_* 按需链扫描不再使用 fopen（改 read_file/POSIX）。
# 用法：./tests/run-b20-generated-c-scan-gate.sh
# 环境：SHUX_B20_GENERATED_C_SCAN_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_B20_GENERATED_C_SCAN_FAIL:-0}
RT="compiler/src/runtime.c"

if [ ! -f "$RT" ]; then
  echo "b20-generated-c-scan-gate: SKIP (no runtime.c)"
  exit 0
fi

# generated_c_contains_any_substr 须存在
if ! grep -q 'generated_c_contains_any_substr' "$RT"; then
  echo "b20-generated-c-scan-gate FAIL: missing generated_c_contains_any_substr helper" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# 六个按需链扫描函数体内不得再 fopen
for fn in async_scheduler core_builtin core_mem db_kv db_arrow core_slice; do
  block=$(awk "/generated_c_needs_${fn}\(/,/^}/" "$RT" | head -20)
  if echo "$block" | grep -q 'fopen'; then
    echo "b20-generated-c-scan-gate FAIL: generated_c_needs_${fn} still uses fopen" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
done

# runtime.o 可编译
if ! make -s -C compiler src/runtime.o 2>/tmp/b20_runtime_o.log; then
  echo "b20-generated-c-scan-gate FAIL: make runtime.o" >&2
  tail -n 8 /tmp/b20_runtime_o.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "b20-generated-c-scan-gate OK (generated_c_needs_* scan via read_file, no fopen)"
exit 0
