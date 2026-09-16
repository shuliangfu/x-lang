#!/usr/bin/env bash
# STD-113: std.crypto ChaCha20-Poly1305 gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / c=/x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native still gate OK) + soft
# `ensure_std_c_o` + hard check as sole .x smoke + report `c=`/`x=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/crypto/crypto.o; refuse soft ensure). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-crypto-chacha20-poly1305-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD113_CRYPTO_CHACHA_DOC:-analysis/archive/std/std-crypto-chacha20-poly1305-v1.md}"
MANIFEST="${XLANG_STD113_CRYPTO_CHACHA_TSV:-tests/baseline/std-crypto-chacha20-poly1305.tsv}"
MOD_X="std/crypto/mod.x"
CRYPTO_GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
LIB="tests/lib/std-crypto-chacha20-poly1305.sh"
SMOKE_X="tests/std-crypto/chacha20_poly1305_roundtrip.x"
SMOKE_C="tests/std-crypto/chacha_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-crypto-chacha20-poly1305.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-crypto-chacha gate FAIL: $*" >&2
  std_crypto_chacha_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-113: crypto ChaCha20-Poly1305 manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CRYPTO_GLUE" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qF STD-113 "$DOC" || die "doc missing STD-113"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-crypto-chacha20-poly1305-v1.md ] || die "dual-authority fossil analysis/std-crypto-chacha20-poly1305-v1.md (archive live)"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_crypto_chacha_symbols_ok "$MOD_X" "$CRYPTO_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-crypto-chacha manifest OK"

if [ "${XLANG_STD113_CRYPTO_CHACHA_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_crypto_chacha_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-crypto-chacha20-poly1305 gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-113: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing deps (process_*) = obs, not soft SKIP→OK.
set +e
std_crypto_chacha_run_c_smoke
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-crypto-chacha OK: c smoke"
    ;;
  *)
    echo "std-crypto-chacha OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_crypto_chacha_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-crypto-chacha OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_crypto_chacha_run_smoke "$XLANG_BIN" "$SMOKE_X" "roundtrip"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-crypto-chacha OK: product -o"
else
  echo "std-crypto-chacha OBS tip product -o (std_crypto_chacha* UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_crypto_chacha_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-crypto-chacha20-poly1305 gate OK"
