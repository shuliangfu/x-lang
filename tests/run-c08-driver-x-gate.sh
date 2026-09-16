#!/usr/bin/env bash
# C-08 v1：compiler/src/driver/*.x 七模块 + DRIVER_SUBCMD 登记。
#
# 用法：./tests/run-c08-driver-x-gate.sh
# wave honesty (2026-08-24 #4): compiler/Makefile deleted MG wave941;
# DRIVER_SUBCMD_OBJS authority = compiler/mk/driver_subcmd_objs.mk (refuse MF resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

MK="${XLANG_C08_DRIVER_MK:-compiler/mk/driver_subcmd_objs.mk}"

echo "=== C-08: driver/*.x subcommands ==="
for sub in fmt check test build run; do
  f="compiler/src/driver/${sub}.x"
  [ -f "$f" ] || { echo "c08 driver-x FAIL: missing $f" >&2; exit 1; }
  grep -q "function cmd_${sub}" "$f" || grep -q "cmd_${sub}(" "$f" || {
    echo "c08 driver-x FAIL: $f missing cmd_${sub}" >&2
    exit 1
  }
done
[ -f compiler/src/driver/compile.x ] || { echo "c08 driver-x FAIL: missing compile.x" >&2; exit 1; }
grep -q 'function run_compiler_full_x' compiler/src/driver/compile.x || {
  echo "c08 driver-x FAIL: compile.x missing run_compiler_full_x" >&2
  exit 1
}
[ -f compiler/src/driver/emit.x ] || { echo "c08 driver-x FAIL: missing emit.x" >&2; exit 1; }
grep -q 'function run_x_emit_x' compiler/src/driver/emit.x || {
  echo "c08 driver-x FAIL: emit.x missing run_x_emit_x" >&2
  exit 1
}

# MG: compiler/Makefile deleted — driver subcmd inventory lives in mk/.
if [ -f compiler/Makefile ]; then
  echo "c08 driver-x FAIL: compiler/Makefile resurrected (use mk/driver_subcmd_objs.mk + xbuild)" >&2
  exit 1
fi
[ -f "$MK" ] || { echo "c08 driver-x FAIL: missing $MK" >&2; exit 1; }
grep -q 'DRIVER_SUBCMD_OBJS' "$MK" || {
  echo "c08 driver-x FAIL: $MK missing DRIVER_SUBCMD_OBJS" >&2
  exit 1
}
grep -q 'driver_x.o' compiler/scripts/g05_relink_env.sh || {
  echo "c08 driver-x FAIL: g05_relink_env.sh missing driver_x.o registration" >&2
  exit 1
}
for o in driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o; do
  grep -q "$o" "$MK" || { echo "c08 driver-x FAIL: $MK missing $o" >&2; exit 1; }
done
echo "c08 driver-x gate OK (7 subcmd modules + mk DRIVER_SUBCMD_OBJS)"
