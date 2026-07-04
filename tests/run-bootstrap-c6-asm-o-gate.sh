#!/usr/bin/env bash
# C6 / P0#2：asm -o 直链烟测（无 gcc 回退）
#
# Linux x86_64：shux_asm -backend asm -o return-value 须 exit=42。
# 无 shux_asm 时 SKIP（bootstrap-min 仍可用 min-link 回退）。
#
# 用法：./tests/run-bootstrap-c6-asm-o-gate.sh
# 环境：SHUX_BOOTSTRAP_C6_SKIP=1 跳过
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

if [ "${SHUX_BOOTSTRAP_C6_SKIP:-0}" = "1" ]; then
  gate_progress "bootstrap-c6-asm-o-gate: SKIP"
  exit 0
fi

DOC="analysis/自举前必须清单.md"
RV="tests/return-value/main.x"
ASM="./compiler/shux_asm"
for f in "$DOC" "$RV"; do
  [ -f "$f" ] || { gate_progress "FAIL: missing $f"; exit 1; }
done
grep -qF "C6" "$DOC" || { gate_progress "FAIL: doc missing C6"; exit 1; }

# shellcheck source=tests/lib/ci-host.sh
source tests/lib/ci-host.sh
if [ ! -x "$ASM" ] || ! ci_native_shu "$ASM"; then
  gate_progress "bootstrap-c6-asm-o-gate SKIP (no native shux_asm)"
  exit 0
fi

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true
EXE="/tmp/shux_c6_asm_rv_$$"
rm -f "$EXE"
gate_progress "C6: shux_asm -backend asm -o return-value ..."
set +e
"$ASM" -backend asm -L . "$RV" -o "$EXE" >/tmp/shux_c6_asm_o.log 2>&1
ec=$?
set -e
if [ "$ec" -ne 0 ] || [ ! -x "$EXE" ]; then
  tail -8 /tmp/shux_c6_asm_o.log >&2
  gate_progress "FAIL: asm -o ec=$ec"
  exit 1
fi
run_ec=0
"$EXE" >/dev/null 2>&1 || run_ec=$?
rm -f "$EXE"
if [ "$run_ec" -ne 42 ]; then
  gate_progress "FAIL: run exit=$run_ec want=42"
  exit 1
fi
gate_progress "bootstrap-c6-asm-o-gate OK (asm -o exit=42)"
