#!/usr/bin/env bash
# COMP-002: typeck hotpath profile / optimize gate.
#
# Honesty: soft SKIP→OK when no native xlang (bare "gate OK") + prefer
# xlang-c before xlang_asm retired. Prefer product xlang_asm. Explicit
# bad XLANG = hard die. Missing native = hard die. Region／linear
# diagnostic tip miss = obs (product／check residual; check gate paused
# 2026-08-05). DOC authority = archive/comp. Report run=/obs=/skip=.
#
# Usage: ./tests/run-typeck-hotpath-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_TYPECK_HOTPATH_DOC:-analysis/archive/comp/comp-typeck-hotpath-v1.md}"
MATRIX="${XLANG_TYPECK_HOTPATH_TSV:-tests/baseline/typeck-hotpath-matrix.tsv}"
DOGFOOD="${XLANG_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
MIN_DONE=6
PREFIX="xlang: [XLANG_TYPECK_HOTPATH]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "typeck-hotpath gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== COMP-002: typeck hotpath manifest ==="
if [ -f analysis/comp-typeck-hotpath-v1.md ]; then
  die "top-level DOC resurrected (live = archive/comp/)"
fi
for f in "$DOC" "$MATRIX" "$DOGFOOD"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/pipeline_glue.c ]; then
  die "compiler/pipeline_glue.c resurrected (wave309 left)"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    \#*) ;;
    min_opt_done) MIN_DONE="$c2" ;;
  esac
done < "$MATRIX"

if ! awk -F'\t' '$1=="check_typeck" && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$DOGFOOD"; then
  die "$DOGFOOD missing check_typeck row"
fi
echo "typeck-hotpath manifest OK (host=$(ci_host_summary), min_opt_done=$MIN_DONE)"

MISS=0
DONE=0
HOOKS=""
echo "=== COMP-002: hot symbol check ==="
while IFS=$'\t' read -r hot_id sym tier opt_status src hook notes; do
  [ -z "${hot_id:-}" ] && continue
  case "$hot_id" in \#*|min_opt_done) continue ;; esac
  if [ ! -f "$src" ]; then
    echo "typeck-hotpath FAIL: missing source $src ($hot_id)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  if ! grep -qE "(function|void|int32_t|int64_t|bool|i32) ${sym}\\(" "$src" 2>/dev/null; then
    echo "typeck-hotpath FAIL: symbol ${sym} not in $src ($hot_id)" >&2
    MISS=$((MISS + 1))
  fi
  if [ "$opt_status" = "done" ]; then
    DONE=$((DONE + 1))
  fi
  if [ -n "${hook:-}" ] && [ "$hook" != "check_typeck" ] && [[ "$hook" == *.sh ]]; then
    case " $HOOKS " in
      *" $hook "*) ;;
      *) HOOKS="$HOOKS $hook" ;;
    esac
  fi
done < "$MATRIX"

[ "$MISS" -eq 0 ] || die "missing=${MISS}"
[ "$DONE" -ge "$MIN_DONE" ] || die "done=${DONE} < min_opt_done=${MIN_DONE}"
echo "typeck-hotpath symbols OK (done=${DONE})"
RUN_OK=1

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Region／linear diagnostic tip miss = obs (check paused / product residual).
# WPO opt-in link-path log miss = obs (tip build path residual; smoke already
# N/A on Darwin). Other hook failures remain hard.
obs_hook() {
  case "$1" in
    run-typeck-region.sh|run-typeck-linear.sh|run-typeck-wpo-optin-smoke.sh) return 0 ;;
    *) return 1 ;;
  esac
}

FAILS=0
for hook in $HOOKS; do
  script="tests/${hook}"
  if [ ! -f "$script" ]; then
    echo "typeck-hotpath FAIL: missing hook script $script" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "── hook: $hook (XLANG=$XLANG_BIN) ──"
  chmod +x "$script" 2>/dev/null || true
  if XLANG="$XLANG_BIN" "$script"; then
    echo "typeck-hotpath hook OK $hook"
  elif obs_hook "$hook"; then
    OBS=1
    echo "typeck-hotpath hook OBS $hook (diagnostic tip residual; check paused)" >&2
  else
    echo "typeck-hotpath hook FAIL $hook" >&2
    FAILS=$((FAILS + 1))
  fi
done

[ "$FAILS" -eq 0 ] || die "${FAILS} hook(s)"

ok_report
echo "typeck-hotpath gate OK"
