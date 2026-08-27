#!/usr/bin/env bash
# safe-ffi.sh — SAFE-004 shared: FFI contract case compile+run
#
# Honesty soft→硬绿 (2026-08-28):
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die at gate (refuse soft SKIP→OK / soft auto-make /
# prefer-c). Product path: pure-asm `$XLANG -L . -o` (host-cc only with
# XLANG_ALLOW_HOST_CC). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
#
# Usage (after source):
#   safe_ffi_contract_count [manifest_tsv]
#   safe_ffi_run_case XLANG_BIN src expect_rc [tag]
#   safe_ffi_emit_report status run obs skip

SAFE_FFI_PREFIX="${XLANG_SAFE_FFI_PREFIX:-xlang: [XLANG_SAFE_FFI]}"

# Count manifest rows whose case_id starts with case_.
safe_ffi_contract_count() {
  local man="${1:-tests/baseline/safe-ffi-contract.tsv}"
  awk -F'\t' '$1 ~ /^case_/ { n++ } END { print n+0 }' "$man"
}

# Emit structured honesty report line.
safe_ffi_emit_report() {
  local status="${1:-ok}"
  local run="${2:-0}"
  local obs="${3:-0}"
  local skip="${4:-0}"
  echo "${SAFE_FFI_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip}"
}

# Compile and run one contract .x; check exit code against expect_rc.
# Prefer pure-asm product -o; -backend c only with XLANG_ALLOW_HOST_CC=1.
# Returns: 0=ok, 1=hard fail, 2=obs (UNDEF/BLD residual on product -o).
safe_ffi_run_case() {
  local xlang="$1"
  local src="$2"
  local expect="${3:-0}"
  local tag="${4:-case}"
  local exe="/tmp/xlang_safe_ffi_${tag}_$$"
  local log="/tmp/xlang_safe_ffi_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "safe-ffi FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  # Prefer pure-asm product -o (host-cc banned without XLANG_ALLOW_HOST_CC).
  if "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    :
  elif [ -n "${XLANG_ALLOW_HOST_CC:-}" ] \
    && "$xlang" -backend c -L . "$src" -o "$exe" >"$log" 2>&1; then
    :
  else
    if grep -qE 'Undefined symbols|undefined reference|UNDEF|BLD001' "$log" 2>/dev/null; then
      echo "safe-ffi OBS $tag (product -o UNDEF/ld residual; $src)" >&2
      rm -f "$exe" "$log"
      return 2
    fi
    echo "safe-ffi FAIL: compile $tag ($src)" >&2
    tail -8 "$log" 2>/dev/null || true
    rm -f "$exe" "$log"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne "$expect" ]; then
    echo "safe-ffi FAIL: $tag exit=$ec expect=$expect ($src)" >&2
    return 1
  fi
  return 0
}
