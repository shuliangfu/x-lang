#!/usr/bin/env bash
# STD-121：std.elf 最小写入门禁
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-elf-write-v1.md"
MANIFEST="tests/baseline/std-elf-write-manifest.tsv"
VECTORS="tests/baseline/std-elf-write-vectors.tsv"
MOD_SU="std/elf/mod.sx"
ELF_C="std/elf/elf.c"
LIB="tests/lib/std-elf-write.sh"
SMOKE_SU="tests/std-elf/write_roundtrip.sx"
SMOKE_C="tests/std-elf/write_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-elf-write.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$ELF_C" "$SMOKE_SU" "$SMOKE_C"; do
  [ -f "$f" ] || { echo "std-elf-write gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF write_min_reloc "$DOC" || exit 1
grep -qF 0x90 "$VECTORS" || exit 1

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_SU" || exit 1
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || exit 1

sym_miss="$(std_elf_write_symbols_ok "$MOD_SU" "$ELF_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/elf/elf.o
ELF_O="$(cd compiler && pwd)/../std/elf/elf.o"

C_OK=0
std_elf_write_run_c_smoke "$ELF_O" && C_OK=1 || exit 1

SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_elf_write_run_sx_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

std_elf_write_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-elf-write gate OK"
