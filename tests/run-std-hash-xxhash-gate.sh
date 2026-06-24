#!/usr/bin/env bash
# STD-105：std.hash xxHash64 快速哈希门禁
#
# 用法：./tests/run-std-hash-xxhash-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD105_DOC:-analysis/std-hash-xxhash-v1.md}"
MANIFEST="${SHUX_STD105_TSV:-tests/baseline/std-hash-xxhash.tsv}"
VECTORS="${SHUX_STD105_VECTORS:-tests/baseline/std-hash-xxhash-vectors.tsv}"
MOD_SX="std/hash/mod.sx"
HASH_SX="std/hash/hash.sx"
LIB="tests/lib/std-hash-xxhash.sh"
SMOKE_SX="tests/std-hash/xxhash64.sx"
SMOKE_C="tests/std-hash/xxhash64_smoke_ok.c"
MIN_APIS=2

# shellcheck source=tests/lib/std-hash-xxhash.sh
. "$LIB"

echo "=== STD-105: hash xxhash manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$HASH_SX" "$SMOKE_SX" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-hash-xxhash gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-105 HASHER_XXHASH hash_xxhash64 xxHash64; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-hash-xxhash gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '44bc2cf5ad770999' "$VECTORS" 2>/dev/null; then
  echo "std-hash-xxhash gate FAIL: vectors missing xxhash_abc gold" >&2
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-hash-xxhash FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-hash-xxhash gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_hash_xxhash_symbols_ok "$MOD_SX" "$HASH_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_hash_xxhash_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-hash-xxhash manifest OK"

C_OK=0
SX_OK=0
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
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/hash/hash.o
  if std_hash_xxhash_run_c_smoke "$HASH_SX"; then
    C_OK=1
  else
    std_hash_xxhash_emit_report "fail" 0 0 0
    exit 1
  fi
  echo "=== STD-105: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-hash-xxhash gate FAIL: typeck $SMOKE_SX" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_hash_xxhash_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_hash_xxhash_run_sx_smoke "$SHUX_BIN" "$SMOKE_SX" "xxhash"; then
    SX_OK=1
  else
    std_hash_xxhash_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-hash-xxhash gate SKIP c/sx smoke (no native shux-c)" >&2
  SKIP=1
fi

std_hash_xxhash_emit_report "ok" "$C_OK" "$SX_OK" "$SKIP"
echo "std-hash-xxhash gate OK"
