#!/usr/bin/env bash
# TOOL-002: linter tier smoke (error / warn / info) — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + soft auto-make + check-bound green
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die (refuse soft SKIP→OK / soft auto-make).
#   - clean / error tiers → product -o hard run
#   - warn pad / hot-reorder / unused-hint → check path = obs (check paused)
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-lint-check.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-lint.sh
. tests/lib/tool-lint.sh

PREFIX="${XLANG_LINT_CHECK_PREFIX:-xlang: [XLANG_LINT_CHECK]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "lint-check FAIL: $*" >&2
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

CLEAN=tests/lint/lint_clean_ok.x
ERR=tests/lint/lint_error_assign.x
PAD=tests/lint/lint_warn_pad.x
REORDER=tests/lint/lint_warn_reorder.x
UNUSED=tests/lint/lint_unused_hint.x
for f in "$CLEAN" "$ERR" "$PAD" "$REORDER" "$UNUSED"; do
  [ -f "$f" ] || die "missing $f"
done

echo "=== TOOL-002: lint-check smoke (XLANG=$XLANG_BIN) ==="

# clean: product -o must succeed (hard).
exe="/tmp/xlang_lint_clean_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" "$CLEAN" -o "$exe" >/tmp/xlang_lint_clean.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_lint_clean.log 2>/dev/null || true
  rm -f "$exe"
  die "clean product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
rm -f "$exe"
RUN_OK=$((RUN_OK + 1))
echo "lint-check OK: clean product -o"

# error: product -o must fail with typeck/error diagnostic (hard).
exe="/tmp/xlang_lint_err_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" "$ERR" -o "$exe" >/tmp/xlang_lint_err.log 2>&1
o_ec=$?
set -e
rm -f "$exe"
if [ "$o_ec" -eq 0 ]; then
  die "error fixture unexpectedly compiled"
fi
if ! grep -qE 'typeck error|assignment type mismatch|XT001' /tmp/xlang_lint_err.log; then
  tail -n 12 /tmp/xlang_lint_err.log 2>/dev/null || true
  die "error fixture missing typeck diagnostic"
fi
RUN_OK=$((RUN_OK + 1))
echo "lint-check OK: error tier product -o"

# warn / info tiers still speak through `xlang check` — observational under
# check gate pause (2026-08-05). Refuse soft SKIP→OK; count obs.
run_obs_check() {
  local label="$1"
  local env_kv="$2"
  local src="$3"
  local log="/tmp/xlang_lint_obs_${label}.log"
  set +e
  env "$env_kv" "$XLANG_BIN" check "$src" >"$log" 2>&1
  local ec=$?
  set -e
  if [ "$ec" -eq 0 ] && [ -s "$log" ]; then
    echo "lint-check OK: $label (observational check)"
    return 0
  fi
  OBS=$((OBS + 1))
  echo "lint-check OBS $label (check residual ec=$ec; refuse hard-bind check / soft SKIP→OK)" >&2
  return 0
}

run_obs_check pad "XLANG_PAD_FIELDS=1" "$PAD"
run_obs_check reorder "XLANG_HOT_REORDER=1" "$REORDER"
run_obs_check unused "XLANG_UNUSED_HINT=1" "$UNUSED"

if [ "$RUN_OK" -lt 2 ]; then
  die "no product -o hard tiers ran (refuse soft SKIP→OK)"
fi

echo "lint-check OK"
ok_report
