#!/usr/bin/env bash
# STD-050：std.crypto SHA-512 / HMAC-SHA512 门禁
#
# 用法：./tests/run-std-crypto-sha512-hmac-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CRYPTO_SHA512_HMAC_DOC:-analysis/std-crypto-sha512-hmac-v1.md}"
MANIFEST="${SHUX_STD_CRYPTO_SHA512_HMAC_TSV:-tests/baseline/std-crypto-sha512-hmac.tsv}"
VECTORS="${SHUX_STD_CRYPTO_SHA512_HMAC_VECTORS:-tests/baseline/std-crypto-sha512-hmac-vectors.tsv}"
MOD_X="std/crypto/mod.x"
CRYPTO_CORE="std/crypto/core.x"
CRYPTO_GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
LIB="tests/lib/std-crypto-sha512-hmac.sh"
SMOKE_SHA="tests/std-crypto/sha512_abc.x"
SMOKE_HMAC="tests/std-crypto/hmac_sha512_rfc4231_tc1.x"
SMOKE_MAC="tests/std-crypto/mac_verify_512_smoke.x"
MIN_APIS=4

# shellcheck source=tests/lib/std-crypto-sha512-hmac.sh
. "$LIB"

echo "=== STD-050: crypto SHA-512 / HMAC manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$CRYPTO_CORE" "$CRYPTO_GLUE" \
  "$SMOKE_SHA" "$SMOKE_HMAC" "$SMOKE_MAC"; do
  if [ ! -f "$f" ]; then
    echo "std-crypto-sha512-hmac gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-050 hmac_sha512 mac_sign_512 mac_verify_512 SHA512_DIGEST_LEN; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-crypto-sha512-hmac gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'ddaf35a193617abacc417349ae204131' "$VECTORS" 2>/dev/null; then
  echo "std-crypto-sha512-hmac gate FAIL: vectors missing sha512_abc" >&2
  exit 1
fi
if ! grep -qF '87aa7cdea5ef619d4ff0b4241a1d6cb0' "$VECTORS" 2>/dev/null; then
  echo "std-crypto-sha512-hmac gate FAIL: vectors missing hmac tc1" >&2
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
        echo "std-crypto-sha512-hmac gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto-sha512-hmac gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-crypto-sha512-hmac gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_crypto_sha512_hmac_symbols_ok "$MOD_X" "$CRYPTO_GLUE" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_crypto_sha512_hmac_emit_report "fail" 0 0 0 0
  echo "std-crypto-sha512-hmac gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-crypto-sha512-hmac manifest OK"

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

SHA512_OK=0
HMAC_OK=0
MAC_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-050: typeck + smoke (SHUX=$SHUX_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/crypto/crypto.o
  for smoke in "$SMOKE_SHA" "$SMOKE_HMAC" "$SMOKE_MAC"; do
    if ! "$SHUX_BIN" check -L . "$smoke" >/dev/null 2>&1; then
      echo "std-crypto-sha512-hmac gate FAIL: typeck $smoke" >&2
      "$SHUX_BIN" check -L . "$smoke" 2>&1 | tail -10 >&2 || true
      std_crypto_sha512_hmac_emit_report "fail" 0 0 0 0
      exit 1
    fi
  done
  if std_crypto_sha512_hmac_run_smoke "$SHUX_BIN" "$SMOKE_SHA" "abc"; then
    SHA512_OK=1
  else
    std_crypto_sha512_hmac_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_crypto_sha512_hmac_run_smoke "$SHUX_BIN" "$SMOKE_HMAC" "tc1"; then
    HMAC_OK=1
  else
    std_crypto_sha512_hmac_emit_report "fail" "$SHA512_OK" 0 0 0
    exit 1
  fi
  if std_crypto_sha512_hmac_run_smoke "$SHUX_BIN" "$SMOKE_MAC" "mac512"; then
    MAC_OK=1
  else
    std_crypto_sha512_hmac_emit_report "fail" "$SHA512_OK" "$HMAC_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-crypto-sha512-hmac gate SKIP smoke (no native shux)" >&2
fi

std_crypto_sha512_hmac_emit_report "ok" "$SHA512_OK" "$HMAC_OK" "$MAC_OK" "$SKIP"
echo "std-crypto-sha512-hmac gate OK"
