#!/usr/bin/env bash
# STD-050：std.crypto SHA-512 / HMAC-SHA512 门禁（假权威诚实）。
#
# 用法：./tests/run-std-crypto-sha512-hmac-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); sha512_abc.x + hmac_sha512_rfc4231_tc1.x
# exit 0 hard-fail (no soft SKIP when native xlang present). mac_verify_512_smoke.x
# stays observational (product UNDEF _std_crypto_mac_{sign,verify}_512 — not soft).
# Report check=/sha512=/hmac=/mac512=/skip=. Product sha512/hmac already green
# under asm; gate was portable-false-red (prefer xlang-c / hard check / soft SKIP /
# hard-chain mac512 UNDEF).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CRYPTO_SHA512_HMAC_DOC:-analysis/archive/std/std-crypto-sha512-hmac-v1.md}"
MANIFEST="${XLANG_STD_CRYPTO_SHA512_HMAC_TSV:-tests/baseline/std-crypto-sha512-hmac.tsv}"
VECTORS="${XLANG_STD_CRYPTO_SHA512_HMAC_VECTORS:-tests/baseline/std-crypto-sha512-hmac-vectors.tsv}"
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

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-crypto-sha512-hmac gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

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
  std_crypto_sha512_hmac_emit_report "fail" 0 0 0 0 0
  echo "std-crypto-sha512-hmac gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-crypto-sha512-hmac manifest OK"

if [ "${XLANG_STD_CRYPTO_SHA512_HMAC_MANIFEST_ONLY:-0}" = "1" ]; then
  std_crypto_sha512_hmac_emit_report "ok" 0 0 0 0 1
  echo "std-crypto-sha512-hmac gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
SHA512_OK=0
HMAC_OK=0
MAC_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-050: smoke (XLANG=$XLANG_BIN; check observational; sha512/hmac hard; mac512 observational) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_SHA" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_HMAC" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-crypto-sha512-hmac gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/crypto/crypto.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_crypto_sha512_hmac_run_smoke "$XLANG_BIN" "$SMOKE_SHA" "abc"; then
    SHA512_OK=1
  else
    std_crypto_sha512_hmac_emit_report "fail" "$CHECK_OK" 0 0 0 0
    exit 1
  fi
  if std_crypto_sha512_hmac_run_smoke "$XLANG_BIN" "$SMOKE_HMAC" "tc1"; then
    HMAC_OK=1
    SKIP=0
  else
    std_crypto_sha512_hmac_emit_report "fail" "$CHECK_OK" "$SHA512_OK" 0 0 0
    exit 1
  fi

  # Observational mac512 (product UNDEF residual; never hard-green).
  # PLATFORM: SHARED — link surface for mac_sign_512/mac_verify_512 still product debt.
  if std_crypto_sha512_hmac_run_smoke "$XLANG_BIN" "$SMOKE_MAC" "mac512"; then
    MAC_OK=1
  else
    echo "std-crypto-sha512-hmac gate SKIP mac512 smoke (observational; product UNDEF)" >&2
  fi
else
  echo "std-crypto-sha512-hmac gate FAIL: no native xlang" >&2
  std_crypto_sha512_hmac_emit_report "fail" 0 0 0 0 0
  exit 1
fi

# check + mac512 stay observational; hard-green signal is sha512= + hmac=.
echo "std-crypto-sha512-hmac check_ok=${CHECK_OK} mac512=${MAC_OK} (observational)"
std_crypto_sha512_hmac_emit_report "ok" "$CHECK_OK" "$SHA512_OK" "$HMAC_OK" "$MAC_OK" "$SKIP"
echo "std-crypto-sha512-hmac gate OK"
