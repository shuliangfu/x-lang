#!/usr/bin/env bash
# STD-049：std.crypto AES-GCM 门禁
#
# 用法：./tests/run-std-crypto-aes-gcm-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CRYPTO_AES_GCM_DOC:-analysis/std-crypto-aes-gcm-v1.md}"
MANIFEST="${SHUX_STD_CRYPTO_AES_GCM_TSV:-tests/baseline/std-crypto-aes-gcm.tsv}"
VECTORS="${SHUX_STD_CRYPTO_AES_GCM_VECTORS:-tests/baseline/std-crypto-aes-gcm-vectors.tsv}"
MOD_X="std/crypto/mod.x"
AES_GCM_X="std/crypto/aes_gcm.x"
CRYPTO_GLUE="compiler/src/asm/runtime_crypto_inc_glue.inc"
LIB="tests/lib/std-crypto-aes-gcm.sh"
SMOKE_X="tests/std-crypto/aes_gcm_nist2.x"
MAIN_X="tests/crypto/main.x"
MIN_APIS=2

# shellcheck source=tests/lib/std-crypto-aes-gcm.sh
. "$LIB"

echo "=== STD-049: crypto AES-GCM manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$AES_GCM_X" "$CRYPTO_GLUE" "$SMOKE_X" "$MAIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-crypto-aes-gcm gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-049 aes_gcm_seal nist2_tc crypto.o AES_GCM_TAG_LEN; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-crypto-aes-gcm gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '0388dace60b6a392f328c2b971b2fe78' "$VECTORS" 2>/dev/null; then
  echo "std-crypto-aes-gcm gate FAIL: vectors missing nist2 ct" >&2
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-crypto-aes-gcm gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto-aes-gcm gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-crypto-aes-gcm gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_crypto_aes_gcm_symbols_ok "$MOD_X" "$CRYPTO_GLUE" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_crypto_aes_gcm_emit_report "fail" 0 0 0 0
  echo "std-crypto-aes-gcm gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-crypto-aes-gcm manifest OK"

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

SEAL_OK=0
OPEN_OK=0
MAIN_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-049: typeck + smoke (SHUX=$SHUX_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/crypto/crypto.o
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-crypto-aes-gcm gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_crypto_aes_gcm_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_crypto_aes_gcm_run_smoke "$SHUX_BIN" "$SMOKE_X" "nist2"; then
    SEAL_OK=1
    OPEN_OK=1
  else
    std_crypto_aes_gcm_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_crypto_aes_gcm_run_smoke "$SHUX_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_crypto_aes_gcm_emit_report "fail" "$SEAL_OK" "$OPEN_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-crypto-aes-gcm gate SKIP smoke (no native shux)" >&2
fi

std_crypto_aes_gcm_emit_report "ok" "$SEAL_OK" "$OPEN_OK" "$MAIN_OK" "$SKIP"
echo "std-crypto-aes-gcm gate OK"
