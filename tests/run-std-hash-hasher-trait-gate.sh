#!/usr/bin/env bash
# STD-056：std.hash Hasher trait 化与 SipHash / aHash 切换门禁
#
# 用法：./tests/run-std-hash-hasher-trait-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_HASH_HASHER_TRAIT_DOC:-analysis/std-hash-hasher-trait-v1.md}"
MANIFEST="${SHU_STD_HASH_HASHER_TRAIT_TSV:-tests/baseline/std-hash-hasher-trait.tsv}"
VECTORS="${SHU_STD_HASH_HASHER_TRAIT_VECTORS:-tests/baseline/std-hash-hasher-trait-vectors.tsv}"
MOD_SU="std/hash/mod.su"
HASH_C="std/hash/hash.c"
LIB="tests/lib/std-hash-hasher-trait.sh"
SMOKE_SU="tests/std-hash/hasher_switch.su"
SMOKE_C="tests/std-hash/hasher_switch_ok.c"
STBL_TSV="tests/baseline/std-hash-api.tsv"
MIN_APIS=6

# shellcheck source=tests/lib/std-hash-hasher-trait.sh
. "$LIB"

echo "=== STD-056: hash hasher trait manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$HASH_C" "$SMOKE_SU" "$SMOKE_C" "$STBL_TSV"; do
  if [ ! -f "$f" ]; then
    echo "std-hash-hasher-trait gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-056 HASHER_SIPHASH SHU_HASH_ALGO SipHash; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-hash-hasher-trait gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'e71fa2190541574b' "$VECTORS" 2>/dev/null; then
  echo "std-hash-hasher-trait gate FAIL: vectors missing ahash_abc gold" >&2
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
        echo "std-hash-hasher-trait gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-hash-hasher-trait gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-hash-hasher-trait gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

for stbl_api in hash_start hash_write_bytes hash_finish hash_bytes; do
  if ! grep -qF "$stbl_api" "$STBL_TSV" 2>/dev/null; then
    echo "std-hash-hasher-trait gate FAIL: STBL missing $stbl_api" >&2
    exit 1
  fi
done

sym_miss="$(std_hash_hasher_trait_symbols_ok "$MOD_SU" "$HASH_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_hash_hasher_trait_emit_report "fail" 0 0 0
  echo "std-hash-hasher-trait gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-hash-hasher-trait manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/hash/hash.o

C_OK=0
if std_hash_hasher_trait_run_c_smoke "$HASH_C"; then
  C_OK=1
else
  std_hash_hasher_trait_emit_report "fail" 0 0 0
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
  echo "=== STD-056: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-hash-hasher-trait gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_hash_hasher_trait_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_hash_hasher_trait_run_smoke "$SHU_BIN" "$SMOKE_SU" "switch"; then
    SU_OK=1
  else
    std_hash_hasher_trait_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-hash-hasher-trait gate SKIP .su smoke (no native shu)" >&2
  SKIP=1
fi

std_hash_hasher_trait_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-hash-hasher-trait gate OK"
