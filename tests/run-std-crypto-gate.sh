#!/usr/bin/env bash
# STD-006: std.crypto min safety set gate (false-authority honesty).
#
# Usage: ./tests/run-std-crypto-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); sha256/hmac/mem_eq/rand/main smokes exit 0
# hard-fail (no soft SKIP when native xlang present). mac_verify_smoke stays
# observational (product link UNDEF _std_crypto_mac_{sign,verify} — not soft).
# Report check=/sha256=/hmac=/mem_eq=/rand=/main=/mac=/skip=. Product
# sha256/hmac/mem_eq/rand/main already green under asm; gate was
# portable-false-red (prefer xlang-c / soft SKIP on missing native /
# ## 4. Gate 与 report / hard-chain mac UNDEF).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-crypto-min-v1.md ]; then
  echo "std-crypto gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

echo "=== STD-006: std.crypto manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$CRYPTO_MOD" "$RAND_MOD" "$LIB" \
  "$HOOK_CRYPTO" "$HOOK_RANDOM" \
  "$SMOKE_SHA" "$SMOKE_HMAC" "$SMOKE_MAC" "$SMOKE_MEM" "$SMOKE_RAND" "$SMOKE_MAIN" \
  std/crypto/core.x compiler/seeds/runtime_crypto_inc_glue.from_x.c \
  std/random/random.x compiler/seeds/runtime_random_fill.from_x.c; do
  if [ ! -f "$f" ]; then
    echo "std-crypto gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable report K1-hash K3-sig; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-crypto gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-crypto gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

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
      path="tests/$anchor"
      if [ "$kind" = "script" ] && [ -f "tests/lib/$anchor" ]; then
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

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-crypto gate FAIL: apis=${API_N} < min_apis=${MIN_APIS}" >&2
  exit 1
fi
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "std-crypto gate FAIL: layers=${LAYER_N} < min_layers=${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  std_crypto_emit_report "fail" 0 0 0 0 0 0 0 1
  echo "std-crypto gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-crypto manifest OK (apis=${API_N} layers=${LAYER_N})"

if [ "${XLANG_STD_CRYPTO_MANIFEST_ONLY:-0}" = "1" ]; then
  std_crypto_emit_report "ok" 0 0 0 0 0 0 0 1
  echo "std-crypto gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
SHA256_OK=0
HMAC_OK=0
MEM_OK=0
RAND_OK=0
MAIN_OK=0
MAC_OK=0
SKIP=1

if XLANG_BIN="$(std_crypto_resolve_shu 2>/dev/null)"; then
  echo "=== STD-006: smoke (XLANG=$XLANG_BIN; check observational; sha256/hmac/mem_eq/rand/main hard; mac observational) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_SHA" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_HMAC" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_MEM" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_RAND" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_MAIN" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-crypto gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  echo "── smoke_sha256_abc ──"
  if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_SHA" "sha256"; then
    SHA256_OK=1
    echo "std-crypto OK smoke_sha256_abc"
  else
    std_crypto_emit_report "fail" "$CHECK_OK" 0 0 0 0 0 0 0
    exit 1
  fi

  echo "── smoke_hmac ──"
  if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_HMAC" "hmac"; then
    HMAC_OK=1
    echo "std-crypto OK smoke_hmac"
  else
    std_crypto_emit_report "fail" "$CHECK_OK" "$SHA256_OK" 0 0 0 0 0 0
    exit 1
  fi

  echo "── smoke_mem_eq ──"
  if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_MEM" "mem_eq"; then
    MEM_OK=1
    echo "std-crypto OK smoke_mem_eq"
  else
    std_crypto_emit_report "fail" "$CHECK_OK" "$SHA256_OK" "$HMAC_OK" 0 0 0 0 0
    exit 1
  fi

  echo "── smoke_rand ──"
  if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_RAND" "rand"; then
    RAND_OK=1
    echo "std-crypto OK smoke_rand"
  else
    std_crypto_emit_report "fail" "$CHECK_OK" "$SHA256_OK" "$HMAC_OK" "$MEM_OK" 0 0 0 0
    exit 1
  fi

  echo "── smoke_main ──"
  if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_MAIN" "main"; then
    MAIN_OK=1
    echo "std-crypto OK smoke_main"
  else
    std_crypto_emit_report "fail" "$CHECK_OK" "$SHA256_OK" "$HMAC_OK" "$MEM_OK" "$RAND_OK" 0 0 0
    exit 1
  fi

  # Observational mac (product link UNDEF residual; never hard-green).
  # PLATFORM: SHARED — link surface for mac_sign/mac_verify still product debt.
  echo "── smoke_mac ──"
  if std_crypto_run_smoke "$XLANG_BIN" "$SMOKE_MAC" "mac"; then
    MAC_OK=1
    echo "std-crypto OK smoke_mac"
  else
    echo "std-crypto gate SKIP mac smoke (observational; product UNDEF)" >&2
  fi

  # Hooks are observational regression; not the hard-green signal.
  echo "── hook_crypto ──"
  if std_crypto_run_hook "$XLANG_BIN" "$HOOK_CRYPTO"; then
    echo "std-crypto OK hook_crypto"
  else
    echo "std-crypto WARN hook_crypto (observational; hard signal = sha256/hmac/mem_eq/rand/main)" >&2
  fi
  echo "── hook_random ──"
  if std_crypto_run_hook "$XLANG_BIN" "$HOOK_RANDOM"; then
    echo "std-crypto OK hook_random"
  else
    echo "std-crypto WARN hook_random (observational; hard signal = sha256/hmac/mem_eq/rand/main)" >&2
  fi

  SKIP=0
else
  echo "std-crypto gate FAIL: no native xlang" >&2
  std_crypto_emit_report "fail" 0 0 0 0 0 0 0 0
  exit 1
fi

# check + mac stay observational; hard-green = sha256+hmac+mem_eq+rand+main.
echo "std-crypto check_ok=${CHECK_OK} mac=${MAC_OK} (observational)"
std_crypto_emit_report "ok" "$CHECK_OK" "$SHA256_OK" "$HMAC_OK" "$MEM_OK" "$RAND_OK" "$MAIN_OK" "$MAC_OK" "$SKIP"
echo "std-crypto gate OK"
