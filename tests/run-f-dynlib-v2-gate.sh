#!/usr/bin/env bash
# F-dynlib v2：std.dynlib F-ZC（dynlib_os_glue.c → runtime_dynlib_os.inc）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_DYNLIB_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-dynlib-v2.md"
MANIFEST="tests/baseline/f-dynlib-v2-closure.tsv"
die() { echo "f-dynlib-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-dynlib v2: logic → dynlib.x + runtime ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-dynlib v2' "$DOC" || die "doc marker"
[ -f std/dynlib/dynlib.x ] || die "missing dynlib.x"
[ ! -f std/dynlib/dynlib_os_glue.c ] || die "dynlib_os_glue.c should be deleted (F-ZC)"
[ -f compiler/seeds/runtime_dynlib_os.from_x.c ] || die "missing runtime_dynlib_os.inc"
[ ! -f std/dynlib/dynlib_glue.c ] || die "dynlib_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'dynlib_open_c' std/dynlib/dynlib.x || die "dynlib.x missing open"
grep -q 'dynlib_last_error_copy_c' std/dynlib/dynlib.x || die "dynlib.x missing last_error"
grep -q 'dynlib_f_dynlib_v2_marker_c' std/dynlib/dynlib.x || die "dynlib.x missing v2 marker"
grep -q 'dynlib_os_open_c' compiler/seeds/runtime_dynlib_os.from_x.c || die "runtime missing open"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/dynlib/dynlib.o >/dev/null 2>&1 || die "ensure dynlib.o failed (xlang_compiler_make)"
else
  echo "f-dynlib-v2 SKIP dynlib.o build (no xlang-c)" >&2
fi
for sub in run-std-dynlib-windows-gate.sh run-std-dynlib-last-error-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-dynlib-v2 gate OK"
