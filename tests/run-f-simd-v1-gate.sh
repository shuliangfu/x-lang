#!/usr/bin/env bash
# F-simd v1：std.simd 去 C（simd.c → simd.x；F-ZC 纯 .x 无 os glue）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SIMD_V1_FAIL:-0}
DOC="analysis/phase-f-simd-v1.md"
MANIFEST="tests/baseline/f-simd-v1-closure.tsv"
die() { echo "f-simd-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-simd v1: simd.x (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-simd v1' "$DOC" || die "doc marker"
[ -f std/simd/simd.x ] || die "missing simd.x"
[ ! -f std/simd/simd_os_glue.c ] || die "simd_os_glue.c should be deleted (F-ZC)"
[ ! -f std/simd/simd.c ] || die "simd.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'simd_autovec_smoke_c' std/simd/simd.x || die "simd.x missing smoke"
grep -q 'simd_f_zero_c_marker_c' std/simd/simd.x || die "simd.x missing zero-c marker"
grep -q 'simd.x' compiler/Makefile || die "Makefile missing simd.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/simd/simd.o >/dev/null 2>&1 || die "make simd.o failed"
else
  echo "f-simd-v1 SKIP simd.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-simd-autovec-strategy-gate.sh ]; then
  chmod +x tests/run-std-simd-autovec-strategy-gate.sh
  tests/run-std-simd-autovec-strategy-gate.sh || die "simd autovec gate failed"
fi
echo "f-simd-v1 gate OK"
