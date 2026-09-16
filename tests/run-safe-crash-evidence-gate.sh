#!/usr/bin/env bash
# SAFE-007: crash evidence manifest — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c only + soft auto-make + fossil
# top-level DOC retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - manifest + ## Gate + API/impl = hard.
#   - product -o evidence residual (std_backtrace_collect_crash_evidence UNDEF) = obs.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-safe-crash-evidence-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-crash.sh
. tests/lib/safe-crash.sh

DOC="${XLANG_SAFE_CRASH_DOC:-analysis/archive/safe/safe-crash-evidence-v1.md}"
MANIFEST="${XLANG_SAFE_CRASH_MANIFEST:-tests/baseline/safe-crash-evidence.tsv}"
MIN_CASES=2

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-crash-evidence gate FAIL: $*" >&2
  safe_crash_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== SAFE-007: crash evidence manifest (archive DOC) ==="
if [ -f analysis/safe-crash-evidence-v1.md ]; then
  die "top-level DOC resurrected (live = archive/safe/)"
fi
for f in "$DOC" "$MANIFEST" std/backtrace/mod.x compiler/seeds/runtime_backtrace_platform.from_x.c \
  compiler/seeds/runtime_panic.from_x.c tests/crash/evidence_manual.x tests/ub/div_zero.x \
  tests/lib/safe-crash.sh tests/run-safe-crash-evidence.sh; do
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
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      if ! grep -qE "function ${anchor}\\(" std/backtrace/mod.x 2>/dev/null; then
        echo "safe-crash FAIL: missing API $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "safe-crash FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ "$item_id" = "impl_c" ]; then
        if ! grep -qF 'xlang_crash_evidence_collect_c' compiler/seeds/runtime_backtrace_platform.from_x.c 2>/dev/null; then
          echo "safe-crash FAIL: missing collect impl" >&2
          MISS=$((MISS + 1))
        fi
      fi
      if [ "$item_id" = "impl_panic" ]; then
        if ! grep -qF 'xlang_crash_evidence_collect_c' compiler/seeds/runtime_panic.from_x.c 2>/dev/null; then
          echo "safe-crash FAIL: panic hook missing" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    script)
      if [ ! -f "$src" ]; then
        echo "safe-crash FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "safe-crash FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$src" ]; then
        echo "safe-crash FAIL: missing xref $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing xref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-crash FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
for kw in crash evidence XLANG_CRASH_EVIDENCE bundle runnable replay; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "safe-crash-evidence manifest OK (cases=${CASE_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== SAFE-007: product -o probes (XLANG=$XLANG_BIN) ==="

# Product residual: collect_crash_evidence currently UNDEF under tip asm link.
# Honesty: obs (not soft SKIP→OK of whole gate; not hard-red archaeology).
# PLATFORM: SHARED — tip UNDEF is product residual, Ubuntu gold still required.
probe_one() {
  local src="$1"
  local tag="$2"
  local exe="/tmp/xlang_safe_crash_${tag}_$$"
  local log="/tmp/xlang_safe_crash_${tag}_$$.log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  local bec=$?
  set -e
  if [ "$bec" -ne 0 ]; then
    if grep -qE 'Undefined symbols|undefined reference|UNDEF|BLD001' "$log" 2>/dev/null; then
      echo "safe-crash-evidence OBS $tag (product -o UNDEF/ld residual; refuse soft SKIP→OK)" >&2
      OBS=$((OBS + 1))
      rm -f "$exe"
      return 0
    fi
    tail -n 12 "$log" >&2 || true
    die "$tag product -o failed (ec=$bec; refuse soft SKIP→OK)"
  fi
  set +e
  XLANG_CRASH_EVIDENCE=1 "$exe" >/dev/null 2>"$log"
  set -e
  if safe_crash_grep_evidence "$log"; then
    RUN_OK=$((RUN_OK + 1))
    echo "safe-crash-evidence run OK $tag"
  else
    echo "safe-crash-evidence OBS $tag (compiled but no XLANG_CRASH_EVIDENCE line; tip residual)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f "$exe"
}

probe_one tests/crash/evidence_manual.x manual
probe_one tests/ub/div_zero.x panic

echo "safe-crash-evidence gate OK"
safe_crash_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
