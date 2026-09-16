#!/usr/bin/env bash
# SAFE-004: FFI boundary memory-contract manifest — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + fossil top-level DOC dual
# authority retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - manifest + ## Gate + case .x / API anchors = hard.
#   - product -o contract cases = hard run (UNDEF residual = obs).
#   - run-ffi.sh hook = hard when cases ran.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-safe-ffi-contract-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-ffi.sh
. tests/lib/safe-ffi.sh

DOC="${XLANG_SAFE_FFI_DOC:-analysis/archive/safe/safe-ffi-contract-v1.md}"
MANIFEST="${XLANG_SAFE_FFI_MANIFEST:-tests/baseline/safe-ffi-contract.tsv}"
MOD_X="${XLANG_SAFE_FFI_MOD:-std/ffi/mod.x}"
MIN_CASES=8

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-ffi-contract gate FAIL: $*" >&2
  safe_ffi_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== SAFE-004: FFI memory contract manifest (archive DOC) ==="
if [ -f analysis/safe-ffi-contract-v1.md ]; then
  die "top-level DOC resurrected (live = archive/safe/)"
fi
for f in "$DOC" "$MANIFEST" "$MOD_X" std/ffi/ffi.x tests/lib/safe-ffi.sh \
  tests/run-ffi.sh; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASE_N=0
echo "=== SAFE-004: contract matrix ==="
while IFS=$'\t' read -r case_id contract_rule api src expect_rc _tier _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  case "$case_id" in
    read_path|rules|matrix|verify)
      anchor="$api"
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|gate)
      if [ ! -f "$src" ]; then
        echo "safe-ffi FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ffi)
      path="tests/$api"
      if [ ! -f "$path" ]; then
        echo "safe-ffi FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$api")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing hook $api" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$api" ]; then
        echo "safe-ffi FAIL: missing xref $api" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$api")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing xref $api" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-ffi FAIL: missing case $src ($case_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$contract_rule" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing rule $contract_rule" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
for kw in contract FFI memory runnable cstr_len cstring_new; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "safe-ffi-contract manifest OK (cases=${CASE_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== SAFE-004: contract cases (XLANG=$XLANG_BIN) ==="
FAIL=0
while IFS=$'\t' read -r case_id _rule _api src expect_rc _tier _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    case_*)
      set +e
      safe_ffi_run_case "$XLANG_BIN" "$src" "$expect_rc" "$case_id"
      rc=$?
      set -e
      if [ "$rc" -eq 0 ]; then
        RUN_OK=$((RUN_OK + 1))
        echo "safe-ffi-contract OK $case_id"
      elif [ "$rc" -eq 2 ]; then
        OBS=$((OBS + 1))
      else
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"
[ "$FAIL" -eq 0 ] || die "cases hard-fail=${FAIL}"

echo "=== SAFE-004: run-ffi.sh hook ==="
chmod +x tests/run-ffi.sh
if ./tests/run-ffi.sh; then
  RUN_OK=$((RUN_OK + 1))
  echo "safe-ffi-contract hook OK"
else
  die "run-ffi.sh hook failed (refuse soft SKIP→OK)"
fi

safe_ffi_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "safe-ffi-contract gate OK"
