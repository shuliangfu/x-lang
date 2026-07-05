#!/usr/bin/env bash
# C-08 v1：compiler/src/driver/*.sx 七模块 + Makefile DRIVER_SUBCMD 登记。
#
# 用法：./tests/run-c08-driver-sx-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== C-08: driver/*.sx subcommands ==="
for sub in fmt check test build run; do
  f="compiler/src/driver/${sub}.sx"
  [ -f "$f" ] || { echo "c08 driver-sx FAIL: missing $f" >&2; exit 1; }
  grep -q "function cmd_${sub}" "$f" || grep -q "cmd_${sub}(" "$f" || {
    echo "c08 driver-sx FAIL: $f missing cmd_${sub}" >&2
    exit 1
  }
done
[ -f compiler/src/driver/compile.sx ] || { echo "c08 driver-sx FAIL: missing compile.sx" >&2; exit 1; }
grep -q 'function run_compiler_full_sx' compiler/src/driver/compile.sx || {
  echo "c08 driver-sx FAIL: compile.sx missing run_compiler_full_sx" >&2
  exit 1
}
[ -f compiler/src/driver/emit.sx ] || { echo "c08 driver-sx FAIL: missing emit.sx" >&2; exit 1; }
grep -q 'function run_sx_emit_sx' compiler/src/driver/emit.sx || {
  echo "c08 driver-sx FAIL: emit.sx missing run_sx_emit_sx" >&2
  exit 1
}
grep -q 'DRIVER_SUBCMD_OBJS' compiler/Makefile || { echo "c08 driver-sx FAIL: Makefile missing DRIVER_SUBCMD_OBJS" >&2; exit 1; }
grep -q 'driver_sx.o' compiler/Makefile || { echo "c08 driver-sx FAIL: Makefile missing driver_sx.o" >&2; exit 1; }
for o in driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_compile_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o; do
  grep -q "$o" compiler/Makefile || { echo "c08 driver-sx FAIL: Makefile missing $o" >&2; exit 1; }
done
echo "c08 driver-sx gate OK (7 subcmd modules + Makefile objs)"
