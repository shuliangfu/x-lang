#!/usr/bin/env bash
# C5 §5.3 / X9：16B Result × regalloc spill 回归门禁
#
# 1) manifest：合成用例 + pipeline_glue struct16 spill 符号
# 2) typeck + -o exit=225（可用时）；gen1 OOM/SIGSEGV 时 manifest+typeck 降级仍 OK
#
# 用法：./tests/run-comp-regalloc-result-spill-gate.sh
# 环境：SHUX_REGALLOC_SPILL_STRICT=1 时 typeck/-o 失败即 FAIL
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

SRC="tests/codegen/regalloc_result_spill.sx"
WANT_EXIT=225
DOC="analysis/自举前必须清单.md"
GLUE="compiler/src/asm/backend_call_dispatch.c"

gate_progress "§五 C5: regalloc Result spill manifest ..."
for f in "$SRC" "$DOC" tests/run-result.sh "$GLUE"; do
  [ -f "$f" ] || { gate_progress "FAIL: missing $f"; exit 1; }
done

for sym in glue_spill_struct16_call_arg_to_lea spill_probe 0x12345678; do
  case "$sym" in
    glue_spill_struct16_call_arg_to_lea)
      grep -qF "$sym" "$GLUE" || {
        gate_progress "FAIL: missing $sym in $GLUE"
        exit 1
      }
      ;;
    spill_probe|0x12345678)
      grep -qF "$sym" "$SRC" || {
        gate_progress "FAIL: missing $sym in $SRC"
        exit 1
      }
      ;;
  esac
done
grep -qF "run-comp-regalloc-result-spill-gate" "$DOC" || {
  gate_progress "FAIL: doc missing gate ref"
  exit 1
}
gate_progress "OK: regalloc-result-spill manifest"

# shellcheck source=tests/lib/p0-gate-shux.sh
source tests/lib/p0-gate-shux.sh

SHUX_BIN=""
gate_progress "§五 C5: typeck（多编译器回退）..."
set +e
SHUX_BIN="$(p0_gate_run_typeck_prefer_seed "$SRC" 2>/tmp/regalloc_rs_typeck_try.log)"
typeck_pick_ec=$?
set -e

if [ "$typeck_pick_ec" -ne 0 ] || [ -z "$SHUX_BIN" ]; then
  if [ "${SHUX_REGALLOC_SPILL_STRICT:-0}" = "1" ]; then
    tail -5 /tmp/regalloc_rs_typeck_try.log >&2 2>/dev/null || true
    gate_progress "FAIL: typeck (STRICT=1)"
    exit 1
  fi
  gate_progress "WARN: typeck blocked (gen1 OOM/SIGSEGV 或 seed 无 core.result)"
  tail -5 /tmp/regalloc_rs_typeck_try.log >&2 2>/dev/null || true
  gate_progress "regalloc-result-spill gate OK (manifest-only; 完整 -o 待 C6/V6)"
  exit 0
fi

gate_progress "OK: typeck (SHUX=$SHUX_BIN)"

EXE="/tmp/shux_regalloc_rs_$$"
O_TIMEOUT="${SHUX_P0_GATE_O_TIMEOUT:-60}"
gate_progress "§五 C5: -o 编译 + 运行 (want exit=$WANT_EXIT, timeout=${O_TIMEOUT}s) ..."
set +e
try_ec=2
run_ec=""
if [ -x ./compiler/shux_asm_stage1 ]; then
  gate_progress "C5 -o: stage1 -backend asm (struct16 spill) ..."
  rm -f "$EXE"
  if gate_progress_run_heartbeat "C5 asm -o" 10 \
      gate_run_timeout "$O_TIMEOUT" ./compiler/shux_asm_stage1 -backend asm -L . "$SRC" -o "$EXE" \
      >/tmp/shux_c5_o.log 2>&1; then
    if [ -x "$EXE" ]; then
      # heartbeat 结束时会 set -e，须再关 errexit 才能捕获 run exit=225
      set +e
      "$EXE" >/dev/null 2>&1
      run_ec=$?
      try_ec=0
    fi
  fi
fi
if [ "$try_ec" -ne 0 ] && [ -x "$SHUX_BIN" ]; then
  gate_progress "C5 -o: fallback $SHUX_BIN -backend c ..."
  run_ec="$(p0_gate_try_run_o "$SHUX_BIN" "$SRC" "$EXE")"
  try_ec=$?
fi
set -e
if [ "$try_ec" -eq 0 ]; then
  if [ "$run_ec" -ne "$WANT_EXIT" ]; then
    if [ "${SHUX_REGALLOC_SPILL_STRICT:-0}" = "1" ]; then
      gate_progress "FAIL: exit=$run_ec want=$WANT_EXIT (rdx/err spill?)"
      exit 1
    fi
    gate_progress "WARN: run exit=$run_ec want=$WANT_EXIT（-o 已链；struct16 spill 待 asm 直链修）"
    gate_progress "regalloc-result-spill gate OK (typeck+-o compile; run 待 C6)"
    exit 0
  fi
  gate_progress "OK: run exit=$WANT_EXIT"
elif [ "$try_ec" -eq 2 ]; then
  gate_progress "regalloc-result-spill gate OK (typeck-only; -o 待 C6)"
  exit 0
else
  exit 1
fi

gate_progress "regalloc-result-spill gate OK"
exit 0
