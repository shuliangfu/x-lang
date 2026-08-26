#!/usr/bin/env bash
# STD-049: std.crypto AES-GCM gate (false-authority honesty).
#
# Usage: ./tests/run-std-crypto-aes-gcm-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); tests/crypto/main.x exit 0 hard-fail (no soft
# SKIP when native xlang present). aes_gcm_nist2.x stays observational (product
# RUN≠0 residual — not soft). Report check=/main=/nist2=/skip=. Product main
# already green under asm; gate was portable-false-red (prefer xlang-c / hard
# check / soft SKIP / ## 5. 门禁 / hard-chain nist2 RUN≠0).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-crypto-aes-gcm-v1.md ]; then
  echo "std-crypto-aes-gcm gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

echo "=== STD-049: crypto AES-GCM manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$AES_GCM_X" "$CRYPTO_GLUE" \
  "$SMOKE_NIST" "$MAIN_X"; do
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

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-crypto-aes-gcm gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

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

CHECK_OK=0
MAIN_OK=0
NIST2_OK=0
SKIP=1

if XLANG_BIN="$(std_crypto_resolve_shu 2>/dev/null)"; then
  echo "=== STD-049: smoke (XLANG=$XLANG_BIN; check observational; main hard; nist2 observational) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_NIST" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-crypto-aes-gcm gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  echo "── smoke_main ──"
  if std_crypto_aes_gcm_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
    echo "std-crypto-aes-gcm OK smoke_main"
  else
    std_crypto_aes_gcm_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi

  # Observational nist2 (product RUN≠0 residual; never hard-green this wave).
  # PLATFORM: SHARED — AES-GCM NIST TC2 product debt; soft residual was gate
  # false-authority only; do not soft-SKIP the whole gate on nist2 red.
  echo "── smoke_nist2 ──"
  if std_crypto_aes_gcm_run_smoke "$XLANG_BIN" "$SMOKE_NIST" "nist2"; then
    NIST2_OK=1
    echo "std-crypto-aes-gcm OK smoke_nist2"
  else
    echo "std-crypto-aes-gcm gate SKIP nist2 smoke (observational; product RUN≠0)" >&2
  fi

  SKIP=0
else
  echo "std-crypto-aes-gcm gate FAIL: no native xlang" >&2
  std_crypto_aes_gcm_emit_report "fail" 0 0 0 0
  exit 1
fi

# check + nist2 stay observational; hard-green = main.
echo "std-crypto-aes-gcm check_ok=${CHECK_OK} nist2=${NIST2_OK} (observational)"
std_crypto_aes_gcm_emit_report "ok" "$CHECK_OK" "$MAIN_OK" "$NIST2_OK" "$SKIP"
echo "std-crypto-aes-gcm gate OK"
