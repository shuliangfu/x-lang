#!/usr/bin/env bash
# F-tar v1：std.tar 去 C（tar.c → tar.sx；胶层 v2 已删，见 run-f-tar-v2-gate.sh）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TAR_V1_FAIL:-0}
DOC="analysis/phase-f-tar-v1.md"
MANIFEST="tests/baseline/f-tar-v1-closure.tsv"
die() { echo "f-tar-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-tar v1: tar.c → tar.sx (glue superseded by v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-tar v1' "$DOC" || die "doc marker"
[ -f std/tar/tar.sx ] || die "missing tar.sx"
[ ! -f std/tar/tar.c ] || die "tar.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'tar.sx' compiler/Makefile || die "Makefile missing tar.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/tar/tar.o >/dev/null 2>&1 || die "make tar.o failed"
else
  echo "f-tar-v1 SKIP tar.o build (no shux-c)" >&2
fi
for sub in run-std-tar-ustar-gate.sh run-std-tar-extended-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-tar-v1 gate OK"
