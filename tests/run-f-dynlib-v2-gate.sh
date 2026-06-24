#!/usr/bin/env bash
# F-dynlib v2：std.dynlib F-ZC（dynlib_os_glue.c → runtime_dynlib_os.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_DYNLIB_V2_FAIL:-0}
DOC="analysis/phase-f-dynlib-v2.md"
MANIFEST="tests/baseline/f-dynlib-v2-closure.tsv"
die() { echo "f-dynlib-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-dynlib v2: logic → dynlib.sx + runtime ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-dynlib v2' "$DOC" || die "doc marker"
[ -f std/dynlib/dynlib.sx ] || die "missing dynlib.sx"
[ ! -f std/dynlib/dynlib_os_glue.c ] || die "dynlib_os_glue.c should be deleted (F-ZC)"
[ -f compiler/src/asm/runtime_dynlib_os.c ] || die "missing runtime_dynlib_os.c"
[ ! -f std/dynlib/dynlib_glue.c ] || die "dynlib_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'dynlib_open_c' std/dynlib/dynlib.sx || die "dynlib.sx missing open"
grep -q 'dynlib_last_error_copy_c' std/dynlib/dynlib.sx || die "dynlib.sx missing last_error"
grep -q 'dynlib_f_dynlib_v2_marker_c' std/dynlib/dynlib.sx || die "dynlib.sx missing v2 marker"
grep -q 'dynlib_os_open_c' compiler/src/asm/runtime_dynlib_os.c || die "runtime missing open"
grep -q 'dynlib_glue.c' compiler/Makefile && die "Makefile still references dynlib_glue.c"
grep -q 'runtime_dynlib_os' compiler/Makefile || die "Makefile missing runtime_dynlib_os.o"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/dynlib/dynlib.o >/dev/null 2>&1 || die "make dynlib.o failed"
else
  echo "f-dynlib-v2 SKIP dynlib.o build (no shux-c)" >&2
fi
for sub in run-std-dynlib-windows-gate.sh run-std-dynlib-last-error-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-dynlib-v2 gate OK"
