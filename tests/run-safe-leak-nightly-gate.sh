#!/usr/bin/env bash
# SAFE-005: leak nightly manifest — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c only + soft auto-make + fossil
# top-level DOC retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - manifest + ## Gate + cases = hard.
#   - Linux+ASAN smoke = hard run; non-Linux / no ASAN = skip= (platform N/A).
# Report: run=/obs=/skip=
# PLATFORM: LINUX ASAN primary; Darwin/Windows skip — Ubuntu gold still required.
# Usage: ./tests/run-safe-leak-nightly-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-leak.sh
. tests/lib/safe-leak.sh

DOC="${XLANG_LEAK_DOC:-analysis/archive/safe/safe-leak-nightly-v1.md}"
MANIFEST="${XLANG_LEAK_MANIFEST:-tests/baseline/safe-leak-nightly.tsv}"
MIN_CASES=3

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-leak-nightly gate FAIL: $*" >&2
  safe_leak_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== SAFE-005: leak nightly manifest (archive DOC) ==="
if [ -f analysis/safe-leak-nightly-v1.md ]; then
  die "top-level DOC resurrected (live = archive/safe/)"
fi
for f in "$DOC" "$MANIFEST" tests/lib/safe-leak.sh tests/run-safe-leak-nightly.sh \
  tests/leak/no_leak_heap.x tests/leak/no_leak_ffi.x tests/leak/no_leak_arena.x; do
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
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$item_id" in
    read_path|asan|cases|report|schedule)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|gate|runner)
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    workflow)
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing workflow $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing workflow $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$anchor" ]; then
        echo "safe-leak FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    probe)
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing probe $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
for kw in leak nightly ASAN report runnable XLANG_LEAK_NIGHTLY; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
grep -qF 'run-safe-leak-nightly.sh' .github/workflows/ci-nightly.yml 2>/dev/null \
  || die "ci-nightly.yml missing leak runner"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "safe-leak-nightly manifest OK (cases=${CASE_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# PLATFORM: LINUX — ASAN night path; Darwin/Windows = skip (not soft silence).
if [ "$(uname -s)" = "Linux" ] && safe_leak_asan_ok; then
  echo "=== SAFE-005: ASAN smoke (XLANG=$XLANG_BIN) ==="
  if safe_leak_run_x "$XLANG_BIN" tests/leak/no_leak_heap.x case_heap; then
    RUN_OK=$((RUN_OK + 1))
    echo "safe-leak-nightly run OK case_heap"
  else
    # Tip product residual under ASAN → obs (not soft SKIP→OK).
    echo "safe-leak-nightly OBS case_heap (ASAN/product residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "safe-leak-nightly SKIP smoke (non-Linux or no ASAN; platform N/A)" >&2
  SKIP=$((SKIP + 1))
fi

echo "safe-leak-nightly gate OK"
safe_leak_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
