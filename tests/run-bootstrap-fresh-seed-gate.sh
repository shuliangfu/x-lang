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

if [ "${SHUX_CI_DOCKER:-0}" != "1" ]; then
  os="$(uname -s 2>/dev/null || true)"
  arch="$(uname -m 2>/dev/null || true)"
  case "$arch" in x86_64|amd64) : ;; *) arch="non-x86_64" ;; esac
  if [ "$os" != "Linux" ] || [ "$arch" = "non-x86_64" ]; then
    gate_progress "V6: run in docker linux/amd64 ..."
    cmd="SHUX_BOOTSTRAP_FRESH_SEED_SKIP=${SHUX_BOOTSTRAP_FRESH_SEED_SKIP:-0} "
    cmd="${cmd}SHUX_BOOTSTRAP_FRESH_SEED_BUILD=${SHUX_BOOTSTRAP_FRESH_SEED_BUILD:-0} "
    if [ -n "${SHUX_BOOTSTRAP_FRESH_SEED_BIN:-}" ]; then
      cmd="${cmd}SHUX_BOOTSTRAP_FRESH_SEED_BIN=$(printf '%q' "$SHUX_BOOTSTRAP_FRESH_SEED_BIN") "
    fi
    cmd="${cmd}./tests/run-bootstrap-fresh-seed-gate.sh"
    exec ./tests/lib/docker-linux-run.sh "$cmd"
  fi
fi

DOC="analysis/自举前必须清单.md"
SMOKE="compiler/scripts/bootstrap_driver_seed_smoke.sh"
[ -f "$DOC" ] || { gate_progress "FAIL: missing $DOC"; exit 1; }
[ -x "$SMOKE" ] || { gate_progress "FAIL: missing $SMOKE"; exit 1; }

if [ "${SHUX_BOOTSTRAP_FRESH_SEED_BUILD:-0}" = "1" ]; then
  gate_progress "V6: make bootstrap-driver-seed（耗时长）..."
  gate_progress_run "bootstrap-driver-seed" make -C compiler bootstrap-driver-seed SHUX_FORCE_REGEN_GEN=1
fi

TARGET="${SHUX_BOOTSTRAP_FRESH_SEED_BIN:-./compiler/shux-c}"
if [ ! -x "$TARGET" ]; then
  TARGET="./compiler/shux"
fi
if [ ! -x "$TARGET" ]; then
  TARGET="./compiler/bootstrap_shuxc"
fi
if [ ! -x "$TARGET" ]; then
  gate_progress "FAIL: no executable seed (shux-c/shux/bootstrap_shuxc)"
  exit 1
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
