#!/usr/bin/env bash
# EXC-004: ErrorChain wrap/depth gate (false-authority honesty).
#
# Usage: ./tests/run-exc-error-chain-gate.sh
# wave honesty (2026-08-24 #12): DOC → analysis/archive/exc/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); error_chain_smoke.x exit 0 hard-fail
# (no soft SKIP→OK when native xlang present). Report check=/run=/skip=.
# Gate was portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# no Gate honesty section). Ubuntu asm smoke already exit0.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_EXC_ERROR_CHAIN_DOC:-analysis/archive/exc/exc-error-chain-v1.md}"
MATRIX="${XLANG_EXC_ERROR_CHAIN_TSV:-tests/baseline/exc-error-chain.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/exc-error-chain.sh"
SMOKE="tests/exc/error_chain_smoke.x"
MIN_ITEMS=8

# shellcheck source=tests/lib/exc-error-chain.sh
. "$LIB"

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
exc_error_chain_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== EXC-004: error chain manifest ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-error-chain-v1.md ]; then
  echo "exc-error-chain gate FAIL: top-level DOC resurrected (live = archive/exc/)" >&2
  exit 1
fi

if [ -f analysis/exc-result-error-v1-rfc.md ]; then
  echo "exc-error-chain gate FAIL: companion top-level DOC resurrected (analysis/exc-result-error-v1-rfc.md)" >&2
  exit 1
fi

for f in "$DOC" "$MATRIX" "$LIB" "$ERR_MOD" "$SMOKE" analysis/archive/exc/exc-result-error-v1-rfc.md; do
  if [ ! -f "$f" ]; then
    echo "exc-error-chain gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in EXC-004 ErrorChain chain_wrap; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "exc-error-chain gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "exc-error-chain gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_items) MIN_ITEMS="$c2" ;; esac
done < "$MATRIX"

FOUND=0
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  FOUND=$((FOUND + 1))
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "exc-error-chain gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi

sym_miss="$(exc_error_chain_symbols_ok "$ERR_MOD" "$MATRIX" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  exc_error_chain_emit_report "fail" 0 0 0
  echo "exc-error-chain gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "exc-error-chain manifest OK (items=${FOUND})"

if [ "${XLANG_EXC_ERROR_CHAIN_MANIFEST_ONLY:-0}" = "1" ]; then
  exc_error_chain_emit_report "ok" 0 0 1
  echo "exc-error-chain gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(exc_error_chain_resolve_shu 2>/dev/null)"; then
  echo "=== EXC-004: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "exc-error-chain gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Host-indirect for std_* MEMORY + refuse cross-module single-field inline;
  # nested CALL-as-MEMORY still Cap (smoke uses lets). Hard-fail runnable.
  # PLATFORM: SHARED
  if $RUN_XLANG build -L . "$SMOKE" -o /tmp/xlang_exc_error_chain_gate_$$ 2>/tmp/xlang_exc_error_chain_gate_$$.log; then
    OUT="/tmp/xlang_exc_error_chain_gate_$$"
    if [ -x "$OUT" ] && "$OUT" >/dev/null 2>&1; then
      RUN_OK=1
      SKIP=0
    else
      echo "exc-error-chain gate FAIL runnable exit" >&2
      rm -f "$OUT"
      exc_error_chain_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    rm -f "$OUT"
  else
    # Fallback: direct -L . -o (same argv as Ubuntu probe that was already green).
    if exc_error_chain_run_smoke "$XLANG_BIN" "$SMOKE"; then
      RUN_OK=1
      SKIP=0
    else
      echo "exc-error-chain gate FAIL runnable link" >&2
      tail -20 /tmp/xlang_exc_error_chain_gate_$$.log 2>/dev/null >&2 || true
      exc_error_chain_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  fi
  rm -f /tmp/xlang_exc_error_chain_gate_$$.log
else
  echo "exc-error-chain gate FAIL: no native xlang" >&2
  exc_error_chain_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (error_chain_smoke).
echo "exc-error-chain check_ok=${CHECK_OK} (observational)"
exc_error_chain_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "exc-error-chain gate OK"
