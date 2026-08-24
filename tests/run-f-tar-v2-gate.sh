#!/usr/bin/env bash
# F-tar v2：std.tar 逻辑下沉（UStar/Pax → tar.x；删除 tar_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_TAR_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-tar-v2.md"
MANIFEST="tests/baseline/f-tar-v2-closure.tsv"
die() { echo "f-tar-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-tar v2: tar logic → tar.x (pure) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-tar v2' "$DOC" || die "doc marker"
[ -f std/tar/tar.x ] || die "missing tar.x"
[ ! -f std/tar/tar_glue.c ] || die "tar_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'tar_append_entry_c' std/tar/tar.x || die "tar.x missing append_entry"
grep -q 'tar_next_entry_c' std/tar/tar.x || die "tar.x missing next_entry"
grep -q 'tar_extended_smoke_c' std/tar/tar.x || die "tar.x missing extended smoke"
grep -q 'tar_f_tar_v2_marker_c' std/tar/tar.x || die "tar.x missing v2 marker"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/tar/tar.o >/dev/null 2>&1 || die "ensure tar.o failed (xlang_compiler_make)"
else
  echo "f-tar-v2 SKIP tar.o build (no xlang-c)" >&2
fi
for sub in run-std-tar-ustar-gate.sh run-std-tar-extended-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-tar-v2 gate OK"
