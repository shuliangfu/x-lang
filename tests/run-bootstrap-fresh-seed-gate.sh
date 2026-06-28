#!/usr/bin/env bash
# V6 §7 / P0#1：fresh bootstrap seed 烟测门禁（§七）
#
# 验证 shux-c -c + -backend c -o 最小 main；禁止 pinned 回退。
# 用法：./tests/run-bootstrap-fresh-seed-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

if [ "${SHUX_BOOTSTRAP_FRESH_SEED_SKIP:-0}" = "1" ]; then
  gate_progress "bootstrap-fresh-seed-gate: SKIP"
  exit 0
fi

DOC="analysis/自举前必须清单.md"
SMOKE="compiler/scripts/bootstrap_driver_seed_smoke.sh"
[ -f "$DOC" ] || { gate_progress "FAIL: missing $DOC"; exit 1; }
[ -x "$SMOKE" ] || { gate_progress "FAIL: missing $SMOKE"; exit 1; }

TARGET="${SHUX_BOOTSTRAP_FRESH_SEED_BIN:-./compiler/shux-c}"
if [ ! -x "$TARGET" ]; then
  TARGET="./compiler/shux"
fi
if [ ! -x "$TARGET" ]; then
  gate_progress "FAIL: no executable seed (shux-c/shux)"
  exit 1
fi

if [ "${SHUX_BOOTSTRAP_FRESH_SEED_BUILD:-0}" = "1" ]; then
  gate_progress "V6: make bootstrap-driver-seed（耗时长）..."
  gate_progress_run "bootstrap-driver-seed" make -C compiler bootstrap-driver-seed
  TARGET="./compiler/shux"
fi

if [ -f compiler/src/asm/runtime_process_argv.c ]; then
  if [ ! -f compiler/runtime_process_argv.o ] \
     || [ compiler/src/asm/runtime_process_argv.c -nt compiler/runtime_process_argv.o ]; then
    gate_progress "V6: 重编 runtime_process_argv.o ..."
    gate_progress_run "runtime_process_argv.o" make -C compiler runtime_process_argv.o
  fi
fi

TARGET_ABS="$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"
gate_progress "V6: seed smoke 开始 (TARGET=$TARGET_ABS)"
gate_progress "V6: 预计 1–3 分钟（-c 然后 -backend c -o；每 15s 心跳）..."

if gate_progress_run_heartbeat "V6 seed smoke" 15 \
    bash -c "cd compiler && SHUX_BOOTSTRAP_NO_PINNED_FALLBACK=1 ./scripts/bootstrap_driver_seed_smoke.sh \"$TARGET_ABS\""; then
  gate_progress "bootstrap-fresh-seed-gate OK"
  exit 0
fi

gate_progress "bootstrap-fresh-seed-gate FAIL"
exit 1
