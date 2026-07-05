#!/usr/bin/env bash
# 类型特性烟测：函数重载可用
#
# 用法：./tests/run-types-gate.sh
set -e
cd "$(dirname "$0")/.."

SHUX="${SHUX:-./compiler/shux-c}"
CHECK_CASES=(
  tests/types/overload.x
)
RUN_CASES=(
  tests/types/overload.x
)

# shellcheck source=tests/lib/shux-link-env.sh
. tests/lib/shux-link-env.sh

for f in "${CHECK_CASES[@]}" "${RUN_CASES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "types gate FAIL: missing $f" >&2
    exit 1
  fi
done

if [ ! -x "$SHUX" ]; then
  make -C compiler shux-c
  SHUX=./compiler/shux-c
fi

echo "=== types gate: typeck ==="
for f in "${CHECK_CASES[@]}"; do
  if ! "$SHUX" check -L . "$f" >/dev/null 2>&1; then
    echo "types gate FAIL: typeck $f" >&2
    "$SHUX" check -L . "$f" 2>&1 | tail -6 >&2 || true
    exit 1
  fi
  echo "types gate OK: check $f"
done

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. tests/lib/bootstrap-link-shux.sh
# 【Why 根源】shux-c (SHUX_LEGACY_C_FRONTEND=1 build) 不支持 -backend 参数；
# 仅 shux_asm/shux_asm2 等链 asm 后端的构建支持。
# bootstrap-link-shux.sh 已根据 RUN_SHUX 类型设置 SHUX_LINK_BACKEND_ARGS：
#   shux-c → "" (空，不传 -backend)
#   shux_asm → "-backend asm"
# 此处沿用之，避免 shux-c 报 "-backend asm not available in this build"。
TYPES_LINK_BACKEND_ARGS="${SHUX_TYPES_LINK_BACKEND_ARGS:-${SHUX_LINK_BACKEND_ARGS:-}}"

echo "=== types gate: link + run ==="
for f in "${RUN_CASES[@]}"; do
  base="/tmp/shux_types_$(basename "$f" .x)"
  if ! $RUN_SHUX $TYPES_LINK_BACKEND_ARGS -L . "$f" -o "$base" 2>"${base}_build.log"; then
    echo "types gate FAIL: link $f" >&2
    tail -8 "${base}_build.log" 2>/dev/null >&2 || true
    exit 1
  fi
  exitcode=0
  "$base" >/dev/null 2>&1 || exitcode=$?
  if [ "$exitcode" -ne 0 ]; then
    echo "types gate FAIL: run $f exit=$exitcode" >&2
    exit 1
  fi
  echo "types gate OK: run $f"
done

echo "types gate OK"
