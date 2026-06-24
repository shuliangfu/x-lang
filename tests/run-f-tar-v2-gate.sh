#!/usr/bin/env bash
# F-tar v2：std.tar 逻辑下沉（UStar/Pax → tar.sx；删除 tar_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TAR_V2_FAIL:-0}
DOC="analysis/phase-f-tar-v2.md"
MANIFEST="tests/baseline/f-tar-v2-closure.tsv"
die() { echo "f-tar-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-tar v2: tar logic → tar.sx (pure) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-tar v2' "$DOC" || die "doc marker"
[ -f std/tar/tar.sx ] || die "missing tar.sx"
[ ! -f std/tar/tar_glue.c ] || die "tar_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'tar_append_entry_c' std/tar/tar.sx || die "tar.sx missing append_entry"
grep -q 'tar_next_entry_c' std/tar/tar.sx || die "tar.sx missing next_entry"
grep -q 'tar_extended_smoke_c' std/tar/tar.sx || die "tar.sx missing extended smoke"
grep -q 'tar_f_tar_v2_marker_c' std/tar/tar.sx || die "tar.sx missing v2 marker"
grep -q 'tar.sx' compiler/Makefile || die "Makefile missing tar.sx"
grep -q 'tar_glue.c' compiler/Makefile && die "Makefile still references tar_glue.c"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/tar/tar.o >/dev/null 2>&1 || die "make tar.o failed"
else
  echo "f-tar-v2 SKIP tar.o build (no shux-c)" >&2
fi
for sub in run-std-tar-ustar-gate.sh run-std-tar-extended-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-tar-v2 gate OK"
