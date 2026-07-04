#!/usr/bin/env bash
# F-elf v2：std.elf 逻辑下沉（解析/写入/烟测 → elf.x；F-ZC 纯 .x 无 io glue）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_ELF_V2_FAIL:-0}
DOC="analysis/phase-f-elf-v2.md"
MANIFEST="tests/baseline/f-elf-v2-closure.tsv"
die() { echo "f-elf-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-elf v2: ELF logic → elf.x (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-elf v2' "$DOC" || die "doc marker"
[ -f std/elf/elf.x ] || die "missing elf.x"
[ ! -f std/elf/elf_io_glue.c ] || die "elf_io_glue.c should be deleted (F-ZC)"
[ ! -f std/elf/elf_glue.c ] || die "elf_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'elf64_parse_hdr_c' std/elf/elf.x || die "elf.x missing parse_hdr"
grep -q 'elf64_write_min_reloc_c' std/elf/elf.x || die "elf.x missing write"
grep -q 'elf64_parse_smoke_c' std/elf/elf.x || die "elf.x missing smoke"
grep -q 'elf_f_elf_v2_marker_c' std/elf/elf.x || die "elf.x missing v2 marker"
grep -q 'elf_f_zero_c_marker_c' std/elf/elf.x || die "elf.x missing zero-c marker"
grep -q 'elf_read_fixture_c' std/elf/elf.x || die "elf.x missing read_fixture"
grep -q 'fs_open_read_c' std/elf/elf.x || die "elf.x missing fs fixture IO"
grep -q 'elf.x' compiler/Makefile || die "Makefile missing elf.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/elf/elf.o >/dev/null 2>&1 || die "make elf.o failed"
else
  echo "f-elf-v2 SKIP elf.o build (no shux-c)" >&2
fi
for sub in run-std-elf-parse-gate.sh run-std-elf-deep-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-elf-v2 gate OK"
