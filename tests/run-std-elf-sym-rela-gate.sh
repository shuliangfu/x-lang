#!/usr/bin/env bash
# STD-103：std.elf symtab/rela 门禁
#
# 用法：./tests/run-std-elf-sym-rela-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD103_DOC:-analysis/std-elf-sym-rela-v1.md}"
MANIFEST="${SHUX_STD103_TSV:-tests/baseline/std-elf-sym-rela.tsv}"
VECTORS="${SHUX_STD103_VECTORS:-tests/baseline/std-elf-sym-rela-vectors.tsv}"
MOD_X="std/elf/mod.x"
ELF_X="std/elf/elf.x"
LIB="tests/lib/std-elf-sym-rela.sh"
SMOKE_X="tests/std-elf/parse_sym_rela.x"
SMOKE_C="tests/std-elf/parse_sym_rela_smoke_ok.c"
FIXTURE="tests/baseline/fixtures/elf64_sym_rela.bin"
MIN_APIS=4

# shellcheck source=tests/lib/std-elf-sym-rela.sh
. "$LIB"

echo "=== STD-103: elf symtab/rela manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$ELF_X" "$SMOKE_X" "$SMOKE_C" "$FIXTURE" \
  analysis/std-elf-parse-v1.md tests/run-std-elf-parse-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-elf-sym-rela gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-103 read_sym read_rela symtab_entry_count ELF_SHT_SYMTAB ELF_R_X86_64_64; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-elf-sym-rela gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-elf-sym-rela FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-elf-sym-rela OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-elf-sym-rela gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

if ! grep -qF 'sym_main_name	main' "$VECTORS" 2>/dev/null; then
  echo "std-elf-sym-rela gate FAIL: vectors missing sym_main_name" >&2
  exit 1
fi

sym_miss="$(std_elf_sym_rela_symbols_ok "$MOD_X" "$ELF_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_elf_sym_rela_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-elf-sym-rela manifest OK"

echo "=== STD-103: parent STD-058 manifest ==="
chmod +x tests/run-std-elf-parse-gate.sh
SHUX_STD_ELF_PARSE_MANIFEST_ONLY=1 ./tests/run-std-elf-parse-gate.sh

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  ensure_std_c_o ../std/elf/elf.o
else
  echo "std-elf-sym-rela gate SKIP c/x smoke (need shux-c for elf.x merge)" >&2
  std_elf_sym_rela_emit_report "ok" 0 0 1
  echo "std-elf-sym-rela gate OK (manifest only; no shux-c)"
  exit 0
fi

SYM_C=0
if std_elf_sym_rela_run_c_smoke "std/elf"; then
  SYM_C=1
else
  std_elf_sym_rela_emit_report "fail" 0 0 0
  exit 1
fi

SYM_X=0
SKIP=0
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
  echo "=== STD-103: .x symtab/rela smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-elf-sym-rela gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_elf_sym_rela_emit_report "fail" "$SYM_C" 0 0
    exit 1
  fi
  if std_elf_sym_rela_run_x_smoke "$SHUX_BIN" "$SMOKE_X" "symrela"; then
    SYM_X=1
  else
    std_elf_sym_rela_emit_report "fail" "$SYM_C" 0 0
    exit 1
  fi
else
  SKIP=1
  echo "std-elf-sym-rela gate SKIP .x smoke (no native shux)" >&2
fi

std_elf_sym_rela_emit_report "ok" "$SYM_C" "$SYM_X" "$SKIP"
echo "std-elf-sym-rela gate OK"
