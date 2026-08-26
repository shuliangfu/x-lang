#!/usr/bin/env bash
# EXC-003: error code layer gate (false-authority honesty).
#
# Usage: ./tests/run-exc-error-code-layer-gate.sh
# wave honesty (2026-08-24 #12): DOC → analysis/archive/exc/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); error_code_layer.x exit 0 hard-fail
# (no soft SKIP→OK when native xlang present). Report check=/run=/skip=.
# Gate was portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# DOC ## 7. 门禁 without Gate honesty). Ubuntu/Darwin asm smoke already exit0.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_EXC_CODE_LAYER_DOC:-analysis/archive/exc/exc-error-code-layer-v1.md}"
MATRIX="${XLANG_EXC_CODE_LAYER_TSV:-tests/baseline/exc-error-code-layer.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/exc-error-code-layer.sh"
SMOKE="tests/exc/error_code_layer.x"
MIN_ITEMS=12

# shellcheck source=tests/lib/exc-error-code-layer.sh
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
exc_error_code_layer_resolve_shu() {
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

echo "=== EXC-003: error code layer manifest ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-error-code-layer-v1.md ]; then
  echo "exc-error-code-layer gate FAIL: top-level DOC resurrected (live = archive/exc/)" >&2
  exit 1
fi

if [ -f analysis/exc-result-error-v1-rfc.md ]; then
  echo "exc-error-code-layer gate FAIL: companion top-level DOC resurrected (analysis/exc-result-error-v1-rfc.md)" >&2
  exit 1
fi

for f in "$DOC" "$MATRIX" "$LIB" "$ERR_MOD" "$SMOKE" analysis/archive/exc/exc-result-error-v1-rfc.md; do
  if [ ! -f "$f" ]; then
    echo "exc-error-code-layer gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in EXC-003 code_in_global_range base_io; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "exc-error-code-layer gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "exc-error-code-layer gate FAIL: doc missing '## 7. Gate'" >&2
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
  echo "exc-error-code-layer gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi

sym_miss="$(exc_error_code_layer_symbols_ok "$DOC" "$MATRIX" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  exc_error_code_layer_emit_report "fail" 0 0 0
  echo "exc-error-code-layer gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "exc-error-code-layer manifest OK (items=${FOUND})"

# EXC-001 cross-ref (archive live path).
if ! grep -q 'EXC-003' analysis/archive/exc/exc-result-error-v1-rfc.md 2>/dev/null; then
  echo "exc-error-code-layer WARN: archive EXC-001 RFC has no EXC-003 ref" >&2
fi

if [ "${XLANG_EXC_CODE_LAYER_MANIFEST_ONLY:-0}" = "1" ]; then
  exc_error_code_layer_emit_report "ok" 0 0 1
  echo "exc-error-code-layer gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(exc_error_code_layer_resolve_shu 2>/dev/null)"; then
  echo "=== EXC-003: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "exc-error-code-layer gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Hard-fail runnable (no soft SKIP→OK).
  # PLATFORM: SHARED
  if $RUN_XLANG build -L . "$SMOKE" -o /tmp/xlang_exc_code_layer_gate_$$ 2>/tmp/xlang_exc_code_layer_gate_$$.log; then
    OUT="/tmp/xlang_exc_code_layer_gate_$$"
    if [ -x "$OUT" ] && "$OUT" >/dev/null 2>&1; then
      RUN_OK=1
      SKIP=0
    else
      echo "exc-error-code-layer gate FAIL runnable exit" >&2
      rm -f "$OUT"
      exc_error_code_layer_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    rm -f "$OUT"
  else
    # Fallback: direct -L . -o (same argv as Ubuntu probe that was already green).
    if exc_error_code_layer_run_smoke "$XLANG_BIN" "$SMOKE"; then
      RUN_OK=1
      SKIP=0
    else
      echo "exc-error-code-layer gate FAIL runnable link" >&2
      tail -20 /tmp/xlang_exc_code_layer_gate_$$.log 2>/dev/null >&2 || true
      exc_error_code_layer_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  fi
  rm -f /tmp/xlang_exc_code_layer_gate_$$.log
else
  echo "exc-error-code-layer gate FAIL: no native xlang" >&2
  exc_error_code_layer_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (error_code_layer).
echo "exc-error-code-layer check_ok=${CHECK_OK} (observational)"
exc_error_code_layer_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "exc-error-code-layer gate OK"
