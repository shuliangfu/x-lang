#!/usr/bin/env bash
# 类型特性烟测：函数重载可用
#
# 用法：./tests/run-types-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

XLANG="${XLANG:-./compiler/xlang-c}"
CHECK_CASES=(
  tests/types/overload.x
)
RUN_CASES=(
  tests/types/overload.x
)

# shellcheck source=tests/lib/xlang-link-env.sh
. tests/lib/xlang-link-env.sh

for f in "${CHECK_CASES[@]}" "${RUN_CASES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "types gate FAIL: missing $f" >&2
    exit 1
  fi
done

if [ ! -x "$XLANG" ]; then
  xlang_compiler_make xlang-c
  XLANG=./compiler/xlang-c
fi

echo "=== types gate: typeck ==="
# PLATFORM: SHARED — product check ignores paths containing /tests/ (bare-scan
# hygiene). Stage copies outside tests/ so explicit harness check still runs.
_types_chk_tmp="${TMPDIR:-/tmp}/xlang_types_check_$$"
mkdir -p "$_types_chk_tmp"
trap 'rm -rf "$_types_chk_tmp"' EXIT
for f in "${CHECK_CASES[@]}"; do
  _base=$(basename "$f")
  cp "$f" "$_types_chk_tmp/$_base"
  if ! "$XLANG" check -L . "$_types_chk_tmp/$_base" >/dev/null 2>&1; then
    echo "types gate FAIL: typeck $f" >&2
    "$XLANG" check -L . "$_types_chk_tmp/$_base" 2>&1 | tail -6 >&2 || true
    exit 1
  fi
  # Also require silent success (CHK002 historically exited 0 with a message).
  _chk_out=$("$XLANG" check -L . "$_types_chk_tmp/$_base" 2>&1) || true
  if [ -n "$_chk_out" ]; then
    echo "types gate FAIL: typeck not silent $f: $_chk_out" >&2
    exit 1
  fi
  echo "types gate OK: check $f"
done

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh
# 【Why 根源】xlang-c (XLANG_LEGACY_C_FRONTEND=1 build) 不支持 -backend 参数；
# 仅 xlang_asm/xlang_asm2 等链 asm 后端的构建支持。
# bootstrap-link 在 XLANG_LINK_XLANG=xlang-c + FORCE_BACKEND=c 时会把 RUN_XLANG
# 包成 wrap 指向 pin xlang-c，-backend c 导致 link 失败。
# 产品冷链：-o 用当前 XLANG/xlang_asm + -backend c（与 mac 矩阵一致）。
TYPES_LINK_BACKEND_ARGS="${XLANG_TYPES_LINK_BACKEND_ARGS:-${XLANG_LINK_BACKEND_ARGS:-}}"
TYPES_LINK_XLANG="$RUN_XLANG"
case "$(basename "${XLANG:-}")" in
  xlang|xlang_asm|xlang_asm2|xlang_asm_stage1)
    TYPES_LINK_XLANG="$XLANG"
    TYPES_LINK_BACKEND_ARGS="-backend c"
    ;;
esac
# 若仍是 wrap，还原真实二进制
case "$(basename "$TYPES_LINK_XLANG")" in
  xlang-backend-wrap.sh|xlang-min-link.sh)
    TYPES_LINK_XLANG="${XLANG_BACKEND_WRAP_REAL:-${XLANG_MIN_LINK_REAL:-./compiler/xlang}}"
    TYPES_LINK_BACKEND_ARGS="${XLANG_BACKEND_WRAP_ARGS:--backend c}"
    ;;
esac

echo "=== types gate: link + run ==="
for f in "${RUN_CASES[@]}"; do
  base="/tmp/xlang_types_$(basename "$f" .x)"
  if ! $TYPES_LINK_XLANG $TYPES_LINK_BACKEND_ARGS -L . "$f" -o "$base" 2>"${base}_build.log"; then
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
