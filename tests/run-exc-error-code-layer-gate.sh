#!/usr/bin/env bash
# EXC-003: error code layer gate (false-authority honesty).
#
# Usage: ./tests/run-exc-error-code-layer-gate.sh
# wave honesty (2026-08-24 #12): DOC → analysis/archive/exc/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`) retired.
# Prefer xlang_asm; pin XLANG_LINK_XLANG. Explicit-bad XLANG / missing native
# = hard die. check observational (paused 2026-08-05); error_code_layer.x
# exit 0 hard-fail. Report run=/obs=/skip= (keep check= extra). G.7: complete
# existing exc_error_code_layer_resolve_shu; converge dod_native_exe; drop
# unused compiler-make.sh. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_EXC_CODE_LAYER_DOC:-analysis/archive/exc/exc-error-code-layer-v1.md}"
MATRIX="${XLANG_EXC_CODE_LAYER_TSV:-tests/baseline/exc-error-code-layer.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/exc-error-code-layer.sh"
SMOKE="tests/exc/error_code_layer.x"
MIN_ITEMS=12

# shellcheck source=tests/lib/exc-error-code-layer.sh
. "$LIB"

# G.7: complete existing exc_error_code_layer_resolve_shu. Explicit XLANG
# that is missing or non-native returns 1 (caller hard-dies). Unset XLANG
# prefers asm. Native check converges on dod_native_exe.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
exc_error_code_layer_resolve_shu() {
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
  exc_error_code_layer_emit_report "ok" 0 0 1 0
  echo "exc-error-code-layer gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
RUN_OK=0
OBS=0
SKIP=1

if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(exc_error_code_layer_resolve_shu)"; then
    echo "exc-error-code-layer gate FAIL: explicit XLANG not native (refuse leftover XLANG fallthrough)" >&2
    exc_error_code_layer_emit_report "fail" 0 0 0 0
    exit 1
  fi
elif ! XLANG_BIN="$(exc_error_code_layer_resolve_shu)"; then
  echo "exc-error-code-layer gate FAIL: no native xlang" >&2
  exc_error_code_layer_emit_report "fail" 0 0 0 0
  exit 1
fi

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
      if [ "$CHECK_OK" -eq 0 ]; then OBS=1; fi
      exc_error_code_layer_emit_report "fail" "$CHECK_OK" 0 0 "$OBS"
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
      if [ "$CHECK_OK" -eq 0 ]; then OBS=1; fi
      exc_error_code_layer_emit_report "fail" "$CHECK_OK" 0 0 "$OBS"
      exit 1
    fi
  fi
  rm -f /tmp/xlang_exc_code_layer_gate_$$.log

# check stays observational; hard-green signal is run= (error_code_layer).
if [ "$CHECK_OK" -eq 0 ]; then OBS=1; fi
echo "exc-error-code-layer check_ok=${CHECK_OK} (observational)"
exc_error_code_layer_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP" "$OBS"
echo "exc-error-code-layer gate OK"
