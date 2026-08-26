#!/usr/bin/env bash
# F-03 v2：std.heap libc 层去 C 门禁（libc.x + 无 heap.c/heap.o）。
#
# 用法：./tests/run-f03-std-heap-libc-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f03-std-heap-libc-gate.sh
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; static + inventory +
# run-heap + heap-trace hard-fail (no soft die→exit0; no soft SKIP→OK when
# no native; no prefer-c). Soft XLANG_F03_HEAP_LIBC_FAIL retired. Report
# inventory=/run=/trace=/skip=. Gate was portable-false-green (prefer
# xlang-c / soft FAIL exit0 / SKIP runtime still OK while asm run-heap +
# heap-trace already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F03_HEAP_LIBC_DOC:-analysis/archive/phase/phase-f-f03-v2-heap.md}"
MANIFEST="tests/baseline/f03-std-heap-libc.tsv"
HEAP_LIBC="std/heap/libc.x"
HEAP_MOD="std/heap/mod.x"
PREFIX="xlang: [XLANG_F03_HEAP_LIBC]"

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
  echo "f03-heap-libc gate FAIL: $*" >&2
  echo "${PREFIX} status=fail inventory=${INVENTORY_OK:-0} run=${RUN_OK:-0} trace=${TRACE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

INVENTORY_OK=0
RUN_OK=0
TRACE_OK=0
SKIP=1

echo "=== F-03 v2: std.heap heap_libc remove heap.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v2' "$DOC" || die "doc missing F-03 v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$HEAP_LIBC" ] || die "missing libc.x"
[ ! -f std/heap/heap.c ] || die "heap.c should be deleted"
grep -q 'heap_alloc_c' "$HEAP_LIBC" || die "heap_libc missing heap_alloc_c"
grep -q 'XLANG_HEAP_TRACE' "$HEAP_LIBC" || die "heap_libc missing XLANG_HEAP_TRACE"
grep -q 'import("std.heap.libc")' "$HEAP_MOD" || die "mod.x missing libc import"
if grep -q 'extern function heap_alloc_c' "$HEAP_MOD" 2>/dev/null; then
  die "mod.x still extern heap_alloc_c"
fi
# F-03 = delete heap.c; heap.o is F-06 on-demand only (not argv0 always-resolve).
# PLATFORM: SHARED archaeology / link_abi.
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"
if grep -q 'xlang_rel_o_path_from_argv0(argv\[0\], "std/heap/heap.o")' "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi still always-resolves std/heap/heap.o (legacy F-06)"
fi
if grep -q 'link_abi_asm_ld_push_obj.*std/heap/heap\.o' "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi still unconditionally push_obj std/heap/heap.o"
fi
grep -q 'malloc' compiler/src/lsp/lsp_io_std_heap.x || die "lsp_io_std_heap missing malloc extern"

if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        target="$HEAP_LIBC"
        case "$mod_path" in
          std/heap/mod.x) target="$HEAP_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi
echo "f03-heap-libc manifest OK"

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 v2: delegate run-std-c-inventory-gate (F-01; hard) ==="
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

echo "=== F-03 v2: run-heap (XLANG=$XLANG_BIN; hard) ==="
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

echo "=== F-03 v2: run-std-heap-trace-gate (STD-017; hard) ==="
if [ ! -f tests/run-std-heap-trace-gate.sh ]; then
  die "missing tests/run-std-heap-trace-gate.sh"
fi
chmod +x tests/run-std-heap-trace-gate.sh
if ! tests/run-std-heap-trace-gate.sh; then
  die "std-heap-trace sub-gate failed"
fi
TRACE_OK=1
SKIP=0

echo "${PREFIX} status=ok inventory=${INVENTORY_OK} run=${RUN_OK} trace=${TRACE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f03-heap-libc gate OK (F-03 v2; libc.x authority; honesty)"
