#!/usr/bin/env bash
# F-elf v1：std.elf 去 C（elf.c → elf.sx + elf_io_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_ELF_V1_FAIL:-0}
DOC="analysis/phase-f-elf-v1.md"
MANIFEST="tests/baseline/f-elf-v1-closure.tsv"
die() { echo "f-elf-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-elf v1: elf.c → elf.sx + io glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-elf v1' "$DOC" || die "doc marker"
[ -f std/elf/elf.sx ] || die "missing elf.sx"
[ ! -f std/elf/elf_io_glue.c ] || die "elf_io_glue.c should be deleted (F-ZC)"
[ ! -f std/elf/elf.c ] || die "elf.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'elf.sx' compiler/Makefile || die "Makefile missing elf.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/elf/elf.o >/dev/null 2>&1 || die "make elf.o failed"
else
  echo "f-elf-v1 SKIP elf.o build (no shux-c)" >&2
fi
for sub in run-std-elf-parse-gate.sh; do
  chmod +x "tests/$sub"
  SHUX_STD_ELF_PARSE_MANIFEST_ONLY="${SHUX_STD_ELF_PARSE_MANIFEST_ONLY:-0}" tests/"$sub" || die "$sub failed"
done
echo "f-elf-v1 gate OK"
