#!/usr/bin/env bash
# F-simd v1：std.simd 去 C（simd.c → simd.x；F-ZC 纯 .x 无 os glue）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_SIMD_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-simd-v1.md"
MANIFEST="tests/baseline/f-simd-v1-closure.tsv"
die() { echo "f-simd-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-simd v1: simd.x (F-ZC zero C) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
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
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/simd/simd.o >/dev/null 2>&1 || die "ensure simd.o failed (xlang_compiler_make)"
else
  echo "f-simd-v1 SKIP simd.o build (no xlang-c)" >&2
fi
if [ -f tests/run-std-simd-autovec-strategy-gate.sh ]; then
  chmod +x tests/run-std-simd-autovec-strategy-gate.sh
  tests/run-std-simd-autovec-strategy-gate.sh || die "simd autovec gate failed"
fi
echo "f-simd-v1 gate OK"
