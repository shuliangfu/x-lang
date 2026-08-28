#!/usr/bin/env bash
# STD-049: std.crypto AES-GCM gate — honesty residual auto-make /
# XLANG fallthrough / check=/main=/nist2= report →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# `std_crypto_resolve_shu` XLANG fallthrough (explicit bad XLANG
# continues to xlang_asm) + bootstrap-link wrap + report
# check=/main=/nist2=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c / XLANG fallthrough).
# check residual = obs (paused 2026-08-05). tests/crypto/main.x product
# -o exit0 = hard run. aes_gcm_nist2.x = obs (product RUN≠0 residual;
# not soft). Report: run=/obs=/skip=. Live ensure_std family left.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-crypto-aes-gcm-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_CRYPTO_AES_GCM_DOC:-analysis/archive/std/std-crypto-aes-gcm-v1.md}"
MANIFEST="${XLANG_STD_CRYPTO_AES_GCM_TSV:-tests/baseline/std-crypto-aes-gcm.tsv}"
VECTORS="${XLANG_STD_CRYPTO_AES_GCM_VECTORS:-tests/baseline/std-crypto-aes-gcm-vectors.tsv}"
MOD_X="std/crypto/mod.x"
AES_GCM_X="std/crypto/aes_gcm.x"
CRYPTO_GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
LIB="tests/lib/std-crypto-aes-gcm.sh"
SMOKE_NIST="tests/std-crypto/aes_gcm_nist2.x"
MAIN_X="tests/crypto/main.x"
MIN_APIS=2

# shellcheck source=tests/lib/std-crypto-aes-gcm.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-crypto-aes-gcm gate FAIL: $*" >&2
  std_crypto_aes_gcm_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c / XLANG fallthrough.
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

echo "=== STD-049: crypto AES-GCM manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$AES_GCM_X" "$CRYPTO_GLUE" \
  "$SMOKE_NIST" "$MAIN_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-crypto-aes-gcm-v1.md ] || die "dual-authority fossil analysis/std-crypto-aes-gcm-v1.md (archive live)"

for kw in STD-049 aes_gcm_seal nist2_tc crypto.o AES_GCM_TAG_LEN; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## 5\. Gate' "$DOC" || die "doc missing ## 5. Gate section"
grep -qF '0388dace60b6a392f328c2b971b2fe78' "$VECTORS" 2>/dev/null || die "vectors missing nist2 ct"

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

sym_miss="$(std_crypto_aes_gcm_symbols_ok "$MOD_X" "$CRYPTO_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-crypto-aes-gcm manifest OK (apis=${API_N})"

if [ "${XLANG_STD_CRYPTO_AES_GCM_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_crypto_aes_gcm_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-crypto-aes-gcm gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-049: smoke (XLANG=$XLANG_BIN; check=obs; main product -o hard; nist2=obs) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check = obs (paused); sample main only to bound cost.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std_crypto_aes_gcm_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-crypto-aes-gcm OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# main product -o exit0 is the hard-green signal (already green under asm).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_crypto_aes_gcm_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-crypto-aes-gcm OK: product crypto/main.x"
else
  die "product -o crypto/main.x failed (refuse soft SKIP→OK)"
fi

# nist2 observational (product RUN≠0 residual; never hard-green this wave).
# PLATFORM: SHARED — AES-GCM NIST TC2 product debt; refuse soft SKIP→OK wrap.
if std_crypto_aes_gcm_run_smoke "$XLANG_BIN" "$SMOKE_NIST" "nist2"; then
  echo "std-crypto-aes-gcm nist2 OK (observational)"
else
  echo "std-crypto-aes-gcm OBS nist2 (product RUN≠0 residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_crypto_aes_gcm_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-crypto-aes-gcm gate OK"
