#!/usr/bin/env bash
# STD-063：std.elf ELF64 头/section 深化门禁
#
# 用法：./tests/run-std-elf-deep-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD063_DOC:-analysis/std-elf-deep-v1.md}"
MANIFEST="${SHU_STD063_TSV:-tests/baseline/std-elf-deep.tsv}"
VECTORS="${SHU_STD063_VECTORS:-tests/baseline/std-elf-deep-vectors.tsv}"
MOD_SU="std/elf/mod.su"
ELF_C="std/elf/elf.c"
LIB="tests/lib/std-elf-deep.sh"
SMOKE_SU="tests/std-elf/parse_sections.su"
SMOKE_C="tests/std-elf/parse_sections_smoke_ok.c"
FIXTURE="tests/baseline/fixtures/elf64_min_reloc.bin"
MIN_DEEP=2

# shellcheck source=tests/lib/std-elf-deep.sh
. "$LIB"

echo "=== STD-063: elf deep manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$ELF_C" "$SMOKE_SU" "$SMOKE_C" "$FIXTURE" \
  analysis/std-elf-parse-v1.md tests/run-std-elf-parse-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-elf-deep gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-063 find_section_idx read_sec_byte ELF_ERR_NOT_FOUND; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-elf-deep gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_deep_apis) MIN_DEEP="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-elf-deep FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-elf-deep OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_DEEP" ]; then
  echo "std-elf-deep gate FAIL: api count $API_N < min $MIN_DEEP" >&2
  exit 1
fi

if ! grep -qF 'find_text_idx	1' "$VECTORS" 2>/dev/null; then
  echo "std-elf-deep gate FAIL: vectors missing find_text_idx" >&2
  exit 1
fi
if ! grep -qF 'text_byte0	144' "$VECTORS" 2>/dev/null; then
  echo "std-elf-deep gate FAIL: vectors missing text_byte0" >&2
  exit 1
fi

sym_miss="$(std_elf_deep_symbols_ok "$MOD_SU" "$ELF_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_elf_deep_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-elf-deep manifest OK"

echo "=== STD-063: parent STD-058 manifest ==="
chmod +x tests/run-std-elf-parse-gate.sh
SHU_STD_ELF_PARSE_MANIFEST_ONLY=1 ./tests/run-std-elf-parse-gate.sh

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/elf/elf.o

DEEP_C=0
if std_elf_deep_run_c_smoke "$ELF_C"; then
  DEEP_C=1
else
  std_elf_deep_emit_report "fail" 0 0 0
  exit 1
fi

DEEP_SU=0
SKIP=0
SHU_BIN=""
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
if stdlib_cm_native_shu ./compiler/shu-c; then
  SHU_BIN=./compiler/shu-c
elif stdlib_cm_native_shu ./compiler/shu; then
  SHU_BIN=./compiler/shu
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-063: .su deep smoke (SHU=$SHU_BIN) ==="
  rc=0
  std_elf_deep_run_su_smoke "$SHU_BIN" "$SMOKE_SU" || rc=$?
  if [ "$rc" -eq 0 ]; then
    DEEP_SU=1
  elif [ "$rc" -eq 2 ]; then
    SKIP=1
  else
    std_elf_deep_emit_report "fail" "$DEEP_C" 0 0
    exit 1
  fi
else
  echo "std-elf-deep gate SKIP .su smoke (no native shu)" >&2
  SKIP=1
fi

std_elf_deep_emit_report "ok" "$DEEP_C" "$DEEP_SU" "$SKIP"
echo "std-elf-deep gate OK"
