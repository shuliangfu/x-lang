#!/usr/bin/env bash
# F-03 v1：std.heap 算法层去 C 门禁（ops.x；heap.c 不得再定义 mem/map 算法符号）。
#
# 用法：./tests/run-f03-std-heap-ops-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f03-std-heap-ops-gate.sh
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; static + inventory +
# run-heap hard-fail (no soft die→exit0; no soft SKIP→OK when no native;
# no prefer-c). Drop mem-safe sub-gate (STD-144 separate; runs paused
# `xlang check` + asm UNDEF residual). Report inventory=/run=/skip=.
# Gate was portable-false-green (prefer xlang-c / soft FAIL exit0 / mem-safe
# check FAIL swallowed while asm run-heap already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F03_HEAP_OPS_DOC:-analysis/archive/phase/phase-f-f03-v1.md}"
PREFIX="xlang: [XLANG_F03_HEAP_OPS]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f03-heap-ops gate FAIL: $*" >&2
  echo "${PREFIX} status=fail inventory=${INVENTORY_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

INVENTORY_OK=0
RUN_OK=0
SKIP=1

echo "=== F-03 v1: std.heap heap_ops remove C algorithms (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v1' "$DOC" || die "doc missing F-03 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f std/heap/ops.x ] || die "missing ops.x"
grep -q 'heap_mem_set_c' std/heap/ops.x || die "heap_ops missing heap_mem_set_c"
grep -q 'map_i32_i32_find_c' std/heap/ops.x || die "heap_ops missing map find"
if [ -f std/heap/heap.c ]; then
  if grep -q 'heap_mem_set_c' std/heap/heap.c; then
    die "heap.c still defines heap_mem_set_c (should be in ops.x)"
  fi
  if grep -q 'map_i32_i32_find_c' std/heap/heap.c; then
    die "heap.c still defines map_i32_i32_find_c"
  fi
fi
grep -q 'import("std.heap.ops")' std/heap/mod.x || die "mod.x missing ops import"
echo "f03-heap-ops manifest OK"

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 v1: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  # Hard-fail inventory regressions (total > baseline). total < baseline stays OK.
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi

echo "=== F-03 v1: run-heap (XLANG=$XLANG_BIN; hard) ==="
# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Avoid subscript make rebuilding prefer-c side path during dogfood.
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-heap.sh ]; then
  die "missing tests/run-heap.sh"
fi
chmod +x tests/run-heap.sh
if ! tests/run-heap.sh; then
  die "run-heap sub-gate failed"
fi
RUN_OK=1
SKIP=0

echo "${PREFIX} status=ok inventory=${INVENTORY_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f03-heap-ops gate OK (F-03 v1; ops.x authority; honesty)"
