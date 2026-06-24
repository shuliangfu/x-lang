#!/usr/bin/env bash
# F-03 v2：std.heap libc 层去 C 门禁（heap_libc.sx + 无 heap.c/heap.o）。
#
# 用法：./tests/run-f03-std-heap-libc-gate.sh
# 环境：SHUX_F03_HEAP_LIBC_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F03_HEAP_LIBC_FAIL:-0}
DOC="analysis/phase-f-f03-v2-heap.md"
MANIFEST="tests/baseline/f03-std-heap-libc.tsv"
HEAP_LIBC="std/heap/heap_libc.sx"
HEAP_MOD="std/heap/mod.sx"

die() {
  echo "f03-heap-libc gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-03 v2: std.heap heap_libc remove heap.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v2' "$DOC" || die "doc missing F-03 v2 marker"
[ -f "$HEAP_LIBC" ] || die "missing heap_libc.sx"
[ ! -f std/heap/heap.c ] || die "heap.c should be deleted"
grep -q 'heap_alloc_c' "$HEAP_LIBC" || die "heap_libc missing heap_alloc_c"
grep -q 'SHUX_HEAP_TRACE' "$HEAP_LIBC" || die "heap_libc missing SHUX_HEAP_TRACE"
grep -q 'import("std.heap.heap_libc")' "$HEAP_MOD" || die "mod.sx missing heap_libc import"
if grep -q 'extern function heap_alloc_c' "$HEAP_MOD" 2>/dev/null; then
  die "mod.sx still extern heap_alloc_c"
fi
if grep -q 'std/heap/heap.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references heap.o"
fi
if grep -q 'std/heap/heap.o' compiler/src/runtime_link_abi.c 2>/dev/null; then
  die "runtime_link_abi.c still pushes heap.o"
fi
grep -q 'malloc' compiler/src/lsp/lsp_io_std_heap.sx || die "lsp_io_std_heap missing malloc extern"

if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        target="$HEAP_LIBC"
        case "$mod_path" in
          std/heap/mod.sx) target="$HEAP_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  export SHUX="$SHUX_BIN"
  if [ -f tests/run-heap.sh ]; then
    echo "=== F-03 v2: delegate run-heap.sh (SHUX=$SHUX_BIN) ==="
    chmod +x tests/run-heap.sh
    if ! tests/run-heap.sh; then
      die "run-heap sub-gate failed"
    fi
  fi
  if [ -f tests/run-std-heap-trace-gate.sh ]; then
    echo "=== F-03 v2: delegate run-std-heap-trace-gate ==="
    chmod +x tests/run-std-heap-trace-gate.sh
    if ! tests/run-std-heap-trace-gate.sh; then
      die "std-heap-trace sub-gate failed"
    fi
  fi
else
  echo "f03-heap-libc: SKIP runtime sub-gates (no native shux on this host)"
fi

echo "f03 std.heap libc gate OK (F-03 v2)"
