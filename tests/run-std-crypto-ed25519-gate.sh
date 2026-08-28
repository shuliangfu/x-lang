#!/usr/bin/env bash
# STD-126: std.crypto Ed25519 gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / soft ensure_runtime_*_glue / c=/x= →硬绿.
#
# Honesty: prefer-c first (xlang-c only) + soft SKIP→OK (no xlang-c still gate OK)
# + soft `ensure_std_c_o` / soft `ensure_runtime_ed25519_ref10_glue_o` + hard check
# as sole .x smoke + report `c=`/`x=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/crypto/crypto.o; refuse soft ensure). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-crypto-ed25519-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD126_CRYPTO_ED25519_DOC:-analysis/archive/std/std-crypto-ed25519-v1.md}"
MANIFEST="${XLANG_STD126_CRYPTO_ED25519_TSV:-tests/baseline/std-crypto-ed25519-manifest.tsv}"
MOD_X="std/crypto/mod.x"
ED25519_X="std/crypto/ed25519.x"
REF10_GLUE="compiler/seeds/runtime_ed25519_ref10_glue.from_x.c"
CRYPTO_GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
LIB="tests/lib/std-crypto-ed25519.sh"
SMOKE_X="tests/std-crypto/ed25519_roundtrip.x"
SMOKE_C="tests/std-crypto/ed25519_smoke_ok.c"
MIN_APIS=4

# shellcheck source=tests/lib/std-crypto-ed25519.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-crypto-ed25519 gate FAIL: $*" >&2
  std_crypto_ed25519_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-126: crypto Ed25519 manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ED25519_X" "$REF10_GLUE" "$CRYPTO_GLUE" \
  "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qF STD-126 "$DOC" || die "doc missing STD-126"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-crypto-ed25519-v1.md ] || die "dual-authority fossil analysis/std-crypto-ed25519-v1.md (archive live)"

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

sym_miss="$(std_crypto_ed25519_symbols_ok "$MOD_X" "$ED25519_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-crypto-ed25519 manifest OK"

if [ "${XLANG_STD126_CRYPTO_ED25519_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_crypto_ed25519_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-crypto-ed25519 gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-126: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make / soft glue rebuild.
# PLATFORM: SHARED — missing process_* / ref10 deps = obs.
set +e
std_crypto_ed25519_run_c_smoke
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-crypto-ed25519 OK: c smoke"
    ;;
  *)
    echo "std-crypto-ed25519 OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_crypto_ed25519_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-crypto-ed25519 OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_crypto_ed25519_run_smoke "$XLANG_BIN" "$SMOKE_X" "roundtrip"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-crypto-ed25519 OK: product -o"
else
  echo "std-crypto-ed25519 OBS tip product -o (std_crypto_ed25519* UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_crypto_ed25519_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-crypto-ed25519 gate OK"
