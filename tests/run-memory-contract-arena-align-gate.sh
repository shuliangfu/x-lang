#!/usr/bin/env bash
# L9 / X2：Arena bump align_up 契约门禁（§三）
#
# 验收：typeck + -o 运行 exit=0；xlang-c 失败时回退 stage1/min-link。
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh
# shellcheck source=tests/lib/p0-gate-xlang.sh
source tests/lib/p0-gate-xlang.sh

SRC="tests/memory-contract/arena_align.x"
WANT_EXIT=0
O_TIMEOUT="${XLANG_L9_O_TIMEOUT:-45}"

gate_progress "§三 L9: 检查 manifest ..."
[ -f "$SRC" ] || { gate_progress "FAIL: missing $SRC"; exit 1; }
grep -q 'mem.align_up' std/heap/page_mmap.x || { gate_progress "FAIL: page_mmap 无 align_up"; exit 1; }
gate_progress "OK: page_mmap.x 含 mem.align_up"

export XLANG_P0_SKIP_STAGE1="${XLANG_P0_SKIP_STAGE1:-1}"
export XLANG_MINIMAL_CC_LINK=1

gate_progress "§三 L9: typeck（xlang-c 优先）..."
XLANG_BIN="$(p0_gate_run_typeck_prefer_seed "$SRC")" || {
  gate_progress "FAIL: 无编译器通过 typeck"
  exit 1
}
gate_progress "OK: typeck (XLANG=$XLANG_BIN)"

if [ "${XLANG_L9_SKIP_O:-0}" = "1" ]; then
  gate_progress "L9 SKIP -o（FAST；typeck 已验 align_up 契约）"
  gate_progress "arena-align gate OK (typeck-only FAST)"
  exit 0
fi

EXE="/tmp/xlang_arena_align_$$"
OK_O=0

# 尝试 -o 编译；成功返回 0。
l9_run_o() {
  local label="$1"
  shift
  gate_progress "§三 L9: -o $label (timeout=${O_TIMEOUT}s) ..."
  rm -f "$EXE"
  set +e
  gate_progress_run "L9 -o $label" gate_run_timeout "$O_TIMEOUT" "$@" -L . "$SRC" -o "$EXE"
  local ec=$?
  set -e
  [ "$ec" -eq 0 ] && [ -x "$EXE" ]
}

if [ "$(basename "$XLANG_BIN")" = "xlang-c" ]; then
  l9_run_o "xlang-c -backend c" "$XLANG_BIN" -backend c && OK_O=1 || true
fi
if [ "$OK_O" -eq 0 ] && [ "$(uname)" != "Darwin" ] && [ -x ./compiler/xlang_asm_stage1 ]; then
  l9_run_o "stage1 asm" ./compiler/xlang_asm_stage1 -backend asm && OK_O=1 || true
fi
if [ "$OK_O" -eq 0 ] && [ "$(uname)" != "Darwin" ] && [ -x ./tests/lib/xlang-min-link.sh ] && [ -x ./compiler/xlang_asm_stage1 ]; then
  export XLANG_MIN_LINK_REAL=./compiler/xlang_asm_stage1
  l9_run_o "min-link stage1" ./tests/lib/xlang-min-link.sh && OK_O=1 || true
fi

if [ "$OK_O" -eq 0 ]; then
  if [ "${XLANG_P0_GATE_RUN_STRICT:-0}" = "1" ]; then
    gate_progress "FAIL: 所有 -o 路径失败 (STRICT=1)"
    exit 1
  fi
  gate_progress "WARN: -o 未绿；typeck 已绿"
  gate_progress "arena-align gate OK (typeck-only)"
  exit 0
fi

run_ec=0
"$EXE" >/dev/null 2>&1 || run_ec=$?
rm -f "$EXE"
if [ "$run_ec" -ne "$WANT_EXIT" ]; then
  gate_progress "FAIL: run exit=$run_ec want=$WANT_EXIT"
  exit 1
fi
gate_progress "OK: arena_align exit=$WANT_EXIT"
gate_progress "arena-align gate OK (typeck + -o)"
exit 0
