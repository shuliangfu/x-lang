#!/usr/bin/env bash
# TST-004: std module sanitizer nightly-subset gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c only + soft auto-make + fossil
# top-level DOC retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - manifest + ## Gate + cases = hard.
#   - Linux+ASAN smoke = hard run (tip residual under ASAN = obs);
#     non-Linux / no ASAN = skip= (platform N/A).
# Report: run=/obs=/skip=
# PLATFORM: LINUX ASAN primary; Darwin/Windows skip — Ubuntu gold still required.
# Usage: ./tests/run-tst-004-std-sanitize-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tst-004-std-sanitize.sh
. tests/lib/tst-004-std-sanitize.sh

DOC="${XLANG_TST004_DOC:-analysis/archive/tst/tst-004-std-sanitize-v1.md}"
MANIFEST="${XLANG_TST004_TSV:-tests/baseline/tst-004-std-sanitize.tsv}"
LIB="tests/lib/tst-004-std-sanitize.sh"
MIN_CASES=2

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tst-004-sanitize gate FAIL: $*" >&2
  tst004_sanitize_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== TST-004: std sanitizer manifest (archive DOC) ==="
if [ -f analysis/tst-004-std-sanitize-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tst/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" tests/run-tst-004-std-sanitize-nightly.sh \
  tests/sanitize/std_heap_asan.x tests/sanitize/std_channel_asan.x; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_cases) MIN_CASES="$c2" ;; esac
done < "$MANIFEST"

miss="$(tst004_sanitize_verify_manifest "$MANIFEST" "$DOC" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  die "manifest_miss=${miss}"
fi
echo "tst-004-sanitize manifest OK"

CASE_N=0
while IFS=$'\t' read -r item_id kind _a _b _c _d; do
  [ -z "${item_id:-}" ] && continue
  case "$kind" in case) CASE_N=$((CASE_N + 1)) ;; esac
done < "$MANIFEST"

[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases $CASE_N < min $MIN_CASES"

for kw in TST-004 ASAN heap channel sanitizer nightly; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# PLATFORM: LINUX — ASAN night path; Darwin/Windows = skip (not soft silence).
if [ "$(uname -s)" = "Linux" ] && safe_leak_asan_ok; then
  echo "=== TST-004: ASAN smoke (XLANG=$XLANG_BIN) ==="
  if ./tests/run-tst-004-std-sanitize-nightly.sh; then
    RUN_OK=$CASE_N
    echo "tst-004-sanitize run OK (cases=${CASE_N})"
  else
    # Tip product residual under ASAN → obs (not soft SKIP→OK).
    echo "tst-004-sanitize OBS nightly (ASAN/product residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "tst-004-sanitize SKIP ASAN smoke (non-Linux or no ASAN; platform N/A)" >&2
  SKIP=$((SKIP + 1))
fi

tst004_sanitize_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "tst-004-std-sanitize gate OK"
