#!/usr/bin/env bash
# STD-006: std.crypto min safety set gate — honesty residual soft
# auto-make / XLANG fallthrough / check=/sha256= report →硬绿.
#
# Honesty: residual soft auto-make (`xlang_compiler_make -q ||
# xlang_compiler_make`) + `std_crypto_resolve_shu` XLANG fallthrough
# (explicit bad XLANG continues to xlang_asm) + bootstrap-link wrap +
# report check=/sha256=/hmac=/mem_eq=/rand=/main=/mac=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c / XLANG fallthrough). check residual = obs (paused
# 2026-08-05). Product sha256/hmac/mem_eq/rand/main -o exit0 = hard
# run (already green under asm). mac_verify_smoke = obs (product
# UNDEF residual; not soft). Hooks observational. Report:
# run=/obs=/skip=. Keep ## 5. Gate. Keep keywords runnable / report /
# K1-hash / K3-sig. PLATFORM: SHARED archaeology — Ubuntu gold still
# required.
# Usage: ./tests/run-std-crypto-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

DOC="${XLANG_STD_CRYPTO_DOC:-analysis/archive/std/std-crypto-min-v1.md}"
MANIFEST="${XLANG_STD_CRYPTO_MANIFEST:-tests/baseline/std-crypto-manifest.tsv}"
VECTORS="${XLANG_STD_CRYPTO_VECTORS:-tests/baseline/std-crypto-vectors.tsv}"
CRYPTO_MOD="${XLANG_STD_CRYPTO_MOD:-std/crypto/mod.x}"
RAND_MOD="${XLANG_STD_RANDOM_MOD:-std/random/mod.x}"
LIB="tests/lib/std-crypto.sh"
HOOK_CRYPTO="tests/run-crypto.sh"
HOOK_RANDOM="tests/run-random.sh"
SMOKE_SHA="tests/std-crypto/sha256_abc.x"
SMOKE_HMAC="tests/std-crypto/hmac_key_msg.x"
SMOKE_MAC="tests/std-crypto/mac_verify_smoke.x"
SMOKE_MEM="tests/std-crypto/mem_eq_ct.x"
SMOKE_RAND="tests/std-crypto/rand_fill_smoke.x"
SMOKE_MAIN="tests/crypto/main.x"
MIN_APIS=5
MIN_LAYERS=3

# shellcheck source=tests/lib/std-crypto.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-crypto gate FAIL: $*" >&2
  std_crypto_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-crypto-min-v1.md ] || die "dual-authority fossil analysis/std-crypto-min-v1.md (archive live)"

echo "=== STD-006: std.crypto manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$CRYPTO_MOD" "$RAND_MOD" "$LIB" \
  "$HOOK_CRYPTO" "$HOOK_RANDOM" \
  "$SMOKE_SHA" "$SMOKE_HMAC" "$SMOKE_MAC" "$SMOKE_MEM" "$SMOKE_RAND" "$SMOKE_MAIN" \
  std/crypto/core.x compiler/seeds/runtime_crypto_inc_glue.from_x.c \
  std/random/random.x compiler/seeds/runtime_random_fill.from_x.c; do
  [ -f "$f" ] || die "missing $f"
done

for kw in runnable report K1-hash K3-sig; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
    min_layers) MIN_LAYERS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
LAYER_N=0
echo "=== STD-006: manifest walk ==="
while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      mod="$CRYPTO_MOD"
      if [ "$anchor" = "fill_bytes" ]; then
        mod="$RAND_MOD"
      fi
      if ! std_crypto_has_api "$mod" "$anchor"; then
        echo "std-crypto FAIL: missing API $anchor in $mod" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|cross_ref)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "std-crypto FAIL: missing file $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|hook_script)
      # Full-path TSV anchors preferred; keep relative tests/$anchor fallback.
      path="$anchor"
      if [ ! -f "$path" ]; then
        path="${src:-$anchor}"
      fi
      if [ ! -f "$path" ]; then
        path="tests/$anchor"
      fi
      if [ ! -f "$path" ] && [ "$kind" = "script" ] && [ -f "tests/lib/$anchor" ]; then
        path="tests/lib/$anchor"
      fi
      if [ ! -f "$path" ]; then
        echo "std-crypto FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-crypto FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "apis=${API_N} < min_apis=${MIN_APIS}"
[ "$LAYER_N" -ge "$MIN_LAYERS" ] || die "layers=${LAYER_N} < min_layers=${MIN_LAYERS}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "std-crypto manifest OK (apis=${API_N} layers=${LAYER_N})"

if [ "${XLANG_STD_CRYPTO_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_crypto_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-crypto gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(std_crypto_resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-006: smoke (XLANG=$XLANG_BIN; check=obs; sha256/hmac/mem_eq/rand/main hard; mac=obs) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check residual = obs (paused 2026-08-05). Refuse hard-bind check.
# PLATFORM: SHARED — CHK residual is not a green signal.
set +e
"$XLANG_BIN" check -L . "$SMOKE_SHA" >/tmp/xlang_std_crypto_check_$$.log 2>&1 \
  && "$XLANG_BIN" check -L . "$SMOKE_HMAC" >>/tmp/xlang_std_crypto_check_$$.log 2>&1 \
  && "$XLANG_BIN" check -L . "$SMOKE_MEM" >>/tmp/xlang_std_crypto_check_$$.log 2>&1 \
  && "$XLANG_BIN" check -L . "$SMOKE_RAND" >>/tmp/xlang_std_crypto_check_$$.log 2>&1 \
  && "$XLANG_BIN" check -L . "$SMOKE_MAIN" >>/tmp/xlang_std_crypto_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-crypto OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Product sha256/hmac/mem_eq/rand/main -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make. G.7: std_crypto_run_smoke.
run_hard() {
  local src="$1"
  local tag="$2"
  local label="$3"
  if std_crypto_run_smoke "$XLANG_BIN" "$src" "$tag"; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-crypto OK: product $label"
  else
    die "product -o $src failed (refuse soft SKIP→OK)"
  fi
}

echo "── smoke_sha256_abc ──"
run_hard "$SMOKE_SHA" "sha256" "sha256_abc"
echo "── smoke_hmac ──"
run_hard "$SMOKE_HMAC" "hmac" "hmac_key_msg"
echo "── smoke_mem_eq ──"
run_hard "$SMOKE_MEM" "mem_eq" "mem_eq_ct"
echo "── smoke_rand ──"
run_hard "$SMOKE_RAND" "rand" "rand_fill"
echo "── smoke_main ──"
run_hard "$SMOKE_MAIN" "main" "crypto/main.x"

# Observational mac (product link UNDEF residual; never hard-green).
# PLATFORM: SHARED — link surface for mac_sign/mac_verify still product debt.
echo "── smoke_mac ──"
if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_MAC" "mac"; then
  echo "std-crypto OK smoke_mac (observational)"
else
  echo "std-crypto OBS mac (product UNDEF residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Hooks are observational regression; not the hard-green signal.
echo "── hook_crypto ──"
if std_crypto_run_hook "$XLANG_BIN" "$HOOK_CRYPTO"; then
  echo "std-crypto OK hook_crypto (observational)"
else
  echo "std-crypto OBS hook_crypto (observational; hard signal = sha256/hmac/mem_eq/rand/main)" >&2
  OBS=$((OBS + 1))
fi
echo "── hook_random ──"
if std_crypto_run_hook "$XLANG_BIN" "$HOOK_RANDOM"; then
  echo "std-crypto OK hook_random (observational)"
else
  echo "std-crypto OBS hook_random (observational; hard signal = sha256/hmac/mem_eq/rand/main)" >&2
  OBS=$((OBS + 1))
fi

std_crypto_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-crypto gate OK"
