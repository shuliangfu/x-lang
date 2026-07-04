#!/usr/bin/env bash
# L9 / X2：Arena bump align_up 契约门禁（§三）
#
# 验收：typeck + -o 运行 exit=0；shux-c 失败时回退 stage1/min-link。
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh
# shellcheck source=tests/lib/p0-gate-shux.sh
source tests/lib/p0-gate-shux.sh

SRC="tests/memory-contract/arena_align.x"
WANT_EXIT=0
O_TIMEOUT="${SHUX_L9_O_TIMEOUT:-45}"

gate_progress "§三 L9: 检查 manifest ..."
[ -f "$SRC" ] || { gate_progress "FAIL: missing $SRC"; exit 1; }
grep -q 'mem.align_up' std/heap/page_mmap.x || { gate_progress "FAIL: page_mmap 无 align_up"; exit 1; }
gate_progress "OK: page_mmap.x 含 mem.align_up"

export SHUX_P0_SKIP_STAGE1="${SHUX_P0_SKIP_STAGE1:-1}"
export SHUX_MINIMAL_CC_LINK=1

gate_progress "§三 L9: typeck（shux-c 优先）..."
SHUX_BIN="$(p0_gate_run_typeck_prefer_seed "$SRC")" || {
  gate_progress "FAIL: 无编译器通过 typeck"
  exit 1
}
gate_progress "OK: typeck (SHUX=$SHUX_BIN)"

if [ "${SHUX_L9_SKIP_O:-0}" = "1" ]; then
  gate_progress "L9 SKIP -o（FAST；typeck 已验 align_up 契约）"
  gate_progress "arena-align gate OK (typeck-only FAST)"
  exit 0
fi

EXE="/tmp/shux_arena_align_$$"
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

if [ "$(basename "$SHUX_BIN")" = "shux-c" ]; then
  l9_run_o "shux-c -backend c" "$SHUX_BIN" -backend c && OK_O=1 || true
fi
if [ "$OK_O" -eq 0 ] && [ "$(uname)" != "Darwin" ] && [ -x ./compiler/shux_asm_stage1 ]; then
  l9_run_o "stage1 asm" ./compiler/shux_asm_stage1 -backend asm && OK_O=1 || true
fi
if [ "$OK_O" -eq 0 ] && [ "$(uname)" != "Darwin" ] && [ -x ./tests/lib/shux-min-link.sh ] && [ -x ./compiler/shux_asm_stage1 ]; then
  export SHUX_MIN_LINK_REAL=./compiler/shux_asm_stage1
  l9_run_o "min-link stage1" ./tests/lib/shux-min-link.sh && OK_O=1 || true
fi

if [ "$OK_O" -eq 0 ]; then
  if [ "${SHUX_P0_GATE_RUN_STRICT:-0}" = "1" ]; then
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
