#!/usr/bin/env bash
# F-ffi v1：std.ffi 去 C（ffi.c → ffi.x；F-ZC 纯 .x 无 cb glue）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_FFI_V1_FAIL:-0}
DOC="analysis/phase-f-ffi-v1.md"
MANIFEST="tests/baseline/f-ffi-v1-closure.tsv"
die() { echo "f-ffi-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-ffi v1: ffi.x (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-ffi v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/ffi/ffi.x ] || die "missing ffi.x"
[ ! -f std/ffi/ffi_cb_glue.c ] || die "ffi_cb_glue.c should be deleted (F-ZC)"
[ ! -f std/ffi/ffi.c ] || die "ffi.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'ffi_cb_double_i32_fn_c' std/ffi/ffi.x || die "ffi.x missing cb fn"
grep -q 'ffi_invoke_i32_cb_c' std/ffi/ffi.x || die "ffi.x missing invoke"
grep -q 'ffi_f_zero_c_marker_c' std/ffi/ffi.x || die "ffi.x missing zero-c marker"
grep -q 'ffi.x' compiler/Makefile || die "Makefile missing ffi.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/ffi/ffi.o >/dev/null 2>&1 || die "make ffi.o failed"
else
  echo "f-ffi-v1 SKIP ffi.o build (no shux-c)" >&2
fi
for sub in run-std-ffi-cstring-lifecycle-gate.sh run-std-ffi-struct-callback-gate.sh run-safe-ffi-contract-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-ffi-v1 gate OK"
