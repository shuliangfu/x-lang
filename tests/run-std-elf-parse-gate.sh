#!/usr/bin/env bash
# STD-058：std.elf ELF64 头与 section 只读解析门禁
#
# 用法：./tests/run-std-elf-parse-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_ELF_PARSE_DOC:-analysis/std-elf-parse-v1.md}"
MANIFEST="${SHU_STD_ELF_PARSE_TSV:-tests/baseline/std-elf-parse.tsv}"
VECTORS="${SHU_STD_ELF_PARSE_VECTORS:-tests/baseline/std-elf-parse-vectors.tsv}"
MOD_SU="std/elf/mod.su"
ELF_C="std/elf/elf.c"
LIB="tests/lib/std-elf-parse.sh"
SMOKE_SU="tests/std-elf/parse_hdr.su"
SMOKE_C="tests/std-elf/parse_smoke_ok.c"
FIXTURE="tests/baseline/fixtures/elf64_min_reloc.bin"
MIN_APIS=3

# shellcheck source=tests/lib/std-elf-parse.sh
. "$LIB"

echo "=== STD-058: elf parse manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$ELF_C" "$SMOKE_SU" "$SMOKE_C" "$FIXTURE"; do
  if [ ! -f "$f" ]; then
    echo "std-elf-parse gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-058 ELF64 parse_hdr read_section; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-elf-parse gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'machine	62' "$VECTORS" 2>/dev/null; then
  echo "std-elf-parse gate FAIL: vectors missing machine gold" >&2
  exit 1
fi

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
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
        echo "std-elf-parse gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-elf-parse gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-elf-parse gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_elf_parse_symbols_ok "$MOD_SU" "$ELF_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_elf_parse_emit_report "fail" 0 0 0
  echo "std-elf-parse gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-elf-parse manifest OK"

if [ "${SHU_STD_ELF_PARSE_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "std-elf-parse gate OK (manifest only)"
  exit 0
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/elf/elf.o

C_OK=0
if std_elf_parse_run_c_smoke "$ELF_C"; then
  C_OK=1
else
  std_elf_parse_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
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
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-058: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-elf-parse gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_elf_parse_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_elf_parse_run_smoke "$SHU_BIN" "$SMOKE_SU" "hdr"; then
    SU_OK=1
  else
    std_elf_parse_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-elf-parse gate SKIP .su smoke (no native shu)" >&2
  SKIP=1
fi

std_elf_parse_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-elf-parse gate OK"
