#!/usr/bin/env bash
# STD-064：std.elf ELF64 program header 只读门禁
#
# 用法：./tests/run-std-elf-phdr-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD064_DOC:-analysis/std-elf-phdr-v1.md}"
MANIFEST="${SHUX_STD064_TSV:-tests/baseline/std-elf-phdr.tsv}"
VECTORS="${SHUX_STD064_VECTORS:-tests/baseline/std-elf-phdr-vectors.tsv}"
MOD_SU="std/elf/mod.sx"
ELF_C="std/elf/elf.c"
LIB="tests/lib/std-elf-phdr.sh"
SMOKE_SU="tests/std-elf/parse_phdr.sx"
SMOKE_C="tests/std-elf/parse_phdr_smoke_ok.c"
FIXTURE="tests/baseline/fixtures/elf64_min_phdr.bin"
MIN_PHDR=2

# shellcheck source=tests/lib/std-elf-phdr.sh
. "$LIB"
# shellcheck source=tests/lib/std-elf-parse.sh
. tests/lib/std-elf-parse.sh

echo "=== STD-064: elf phdr manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$ELF_C" "$SMOKE_SU" "$SMOKE_C" "$FIXTURE" \
  analysis/std-elf-deep-v1.md tests/run-std-elf-deep-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-elf-phdr gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-064 read_phdr ELF_PT_LOAD phoff; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-elf-phdr gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_phdr_apis) MIN_PHDR="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-elf-phdr FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-elf-phdr OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_PHDR" ]; then
  echo "std-elf-phdr gate FAIL: api count $API_N < min $MIN_PHDR" >&2
  exit 1
fi

if ! grep -qF 'phnum	1' "$VECTORS" 2>/dev/null; then
  echo "std-elf-phdr gate FAIL: vectors missing phnum" >&2
  exit 1
fi
if ! grep -qF 'p_type	1' "$VECTORS" 2>/dev/null; then
  echo "std-elf-phdr gate FAIL: vectors missing p_type" >&2
  exit 1
fi

sym_miss="$(std_elf_phdr_symbols_ok "$MOD_SU" "$ELF_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_elf_phdr_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-elf-phdr manifest OK"

echo "=== STD-064: parent STD-058 manifest ==="
chmod +x tests/run-std-elf-parse-gate.sh
SHUX_STD_ELF_PARSE_MANIFEST_ONLY=1 ./tests/run-std-elf-parse-gate.sh

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/elf/elf.o

PHDR_C=0
if std_elf_phdr_run_c_smoke "$ELF_C"; then
  PHDR_C=1
else
  std_elf_phdr_emit_report "fail" 0 0 0
  exit 1
fi

PHDR_SU=0
SKIP=1
SHUX_BIN=""
stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
if stdlib_cm_native_shu ./compiler/shux-c; then
  SHUX_BIN=./compiler/shux-c
elif stdlib_cm_native_shu ./compiler/shux; then
  SHUX_BIN=./compiler/shux
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-064: .sx phdr smoke (SHUX=$SHUX_BIN) ==="
  if std_elf_parse_run_smoke "$SHUX_BIN" "$SMOKE_SU" "phdr"; then
    PHDR_SU=1
    SKIP=0
  else
    echo "std-elf-phdr gate SKIP .sx smoke" >&2
    SKIP=1
  fi
else
  echo "std-elf-phdr gate SKIP .sx smoke (no native shux)" >&2
fi

std_elf_phdr_emit_report "ok" "$PHDR_C" "$PHDR_SU" "$SKIP"
echo "std-elf-phdr gate OK"
