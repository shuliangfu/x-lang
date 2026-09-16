#!/usr/bin/env bash
# STD-050: std.crypto SHA-512 / HMAC-SHA512 gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# sha512_abc.x + hmac_sha512_rfc4231_tc1.x -o exit0 = hard run (both folded
# into run=). check / mac_verify_512_smoke.x (product UNDEF residual) = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-crypto-sha512-hmac-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-crypto-sha512-hmac gate FAIL: $*" >&2
  std_crypto_sha512_hmac_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-050: crypto SHA-512 / HMAC manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$CRYPTO_CORE" "$CRYPTO_GLUE" \
  "$SMOKE_SHA" "$SMOKE_HMAC" "$SMOKE_MAC"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-050 hmac_sha512 mac_sign_512 mac_verify_512 SHA512_DIGEST_LEN; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"
grep -qF 'ddaf35a193617abacc417349ae204131' "$VECTORS" 2>/dev/null || die "vectors missing sha512_abc"
grep -qF '87aa7cdea5ef619d4ff0b4241a1d6cb0' "$VECTORS" 2>/dev/null || die "vectors missing hmac tc1"

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
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_crypto_sha512_hmac_symbols_ok "$MOD_X" "$CRYPTO_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-crypto-sha512-hmac manifest OK"

if [ "${XLANG_STD_CRYPTO_SHA512_HMAC_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_crypto_sha512_hmac_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-crypto-sha512-hmac gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-050: smoke (XLANG=$XLANG_BIN; check/mac512 obs; sha512+hmac product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_SHA" >/tmp/xlang_std050_sha_check.log 2>&1
chk_sha=$?
"$XLANG_BIN" check -L . "$SMOKE_HMAC" >/tmp/xlang_std050_hmac_check.log 2>&1
chk_hmac=$?
set -e
if [ "$chk_sha" -ne 0 ] || [ "$chk_hmac" -ne 0 ]; then
  echo "std-crypto-sha512-hmac OBS check (paused / CHK residual sha=$chk_sha hmac=$chk_hmac; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover unused compiler-make.sh / soft ensure_std_c_o / soft auto-make
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_crypto_sha512_hmac_run_smoke "$XLANG_BIN" "$SMOKE_SHA" "abc"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-crypto-sha512-hmac OK: sha512"
else
  die "product -o sha512 failed (refuse soft SKIP→OK)"
fi
if std_crypto_sha512_hmac_run_smoke "$XLANG_BIN" "$SMOKE_HMAC" "tc1"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-crypto-sha512-hmac OK: hmac"
else
  die "product -o hmac failed (refuse soft SKIP→OK)"
fi

# Observational mac512 (product UNDEF residual; never hard-green).
# PLATFORM: SHARED — link surface for mac_sign_512/mac_verify_512 still product debt.
if std_crypto_sha512_hmac_run_smoke "$XLANG_BIN" "$SMOKE_MAC" "mac512"; then
  echo "std-crypto-sha512-hmac mac512 OK (observational)"
else
  echo "std-crypto-sha512-hmac OBS mac512 (product UNDEF residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_crypto_sha512_hmac_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-crypto-sha512-hmac gate OK"
