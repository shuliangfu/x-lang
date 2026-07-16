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
# bootstrap-link 在 SHUX_LINK_SHUX=shux-c + FORCE_BACKEND=c 时会把 RUN_SHUX
# 包成 wrap 指向 pin shux-c，-backend c 导致 link 失败。
# 产品冷链：-o 用当前 SHUX/shux_asm + -backend c（与 mac 矩阵一致）。
TYPES_LINK_BACKEND_ARGS="${SHUX_TYPES_LINK_BACKEND_ARGS:-${SHUX_LINK_BACKEND_ARGS:-}}"
TYPES_LINK_SHUX="$RUN_SHUX"
case "$(basename "${SHUX:-}")" in
  shux|shux_asm|shux_asm2|shux_asm_stage1)
    TYPES_LINK_SHUX="$SHUX"
    TYPES_LINK_BACKEND_ARGS="-backend c"
    ;;
esac
# 若仍是 wrap，还原真实二进制
case "$(basename "$TYPES_LINK_SHUX")" in
  shux-backend-wrap.sh|shux-min-link.sh)
    TYPES_LINK_SHUX="${SHUX_BACKEND_WRAP_REAL:-${SHUX_MIN_LINK_REAL:-./compiler/shux}}"
    TYPES_LINK_BACKEND_ARGS="${SHUX_BACKEND_WRAP_ARGS:--backend c}"
    ;;
esac

echo "=== types gate: link + run ==="
for f in "${RUN_CASES[@]}"; do
  base="/tmp/shux_types_$(basename "$f" .x)"
  if ! $TYPES_LINK_SHUX $TYPES_LINK_BACKEND_ARGS -L . "$f" -o "$base" 2>"${base}_build.log"; then
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
