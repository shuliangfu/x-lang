#!/usr/bin/env bash
# F-elf v1：std.elf 去 C（elf.c → elf.x + elf_io_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_ELF_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-elf-v1.md"
MANIFEST="tests/baseline/f-elf-v1-closure.tsv"
die() { echo "f-elf-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-elf v1: elf.c → elf.x + io glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-elf v1' "$DOC" || die "doc marker"
[ -f std/elf/elf.x ] || die "missing elf.x"
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
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/elf/elf.o >/dev/null 2>&1 || die "ensure elf.o failed (xlang_compiler_make)"
else
  echo "f-elf-v1 SKIP elf.o build (no xlang-c)" >&2
fi
for sub in run-std-elf-parse-gate.sh; do
  chmod +x "tests/$sub"
  XLANG_STD_ELF_PARSE_MANIFEST_ONLY="${XLANG_STD_ELF_PARSE_MANIFEST_ONLY:-0}" tests/"$sub" || die "$sub failed"
done
echo "f-elf-v1 gate OK"
