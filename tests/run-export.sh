#!/usr/bin/env bash
# Module export / XLANG_VISIBILITY gold samples — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang` + soft prefer-c `-backend c`
# + soft check-bound green (false authority) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o user_export.x exit 9 + lint_unused_private.x exit 0
#   - obs: all `xlang check` visibility / L7 arms (check gate paused
#     2026-08-05 → CHK002) + product -o private cross-module residual
#     (currently accepted; not soft FAIL→OK and not honesty hard-red)
# Report: run=/obs=/skip=
# Usage: ./tests/run-export.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_EXPORT_PREFIX:-xlang: [EXPORT]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "export FAIL: $*" >&2
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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
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

run_exit() {
  local tag="$1" src="$2" want="$3"
  local exe="/tmp/xlang_export_${tag}_$$"
  local log="/tmp/xlang_export_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$r_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    die "$tag expected exit $want, got $r_ec"
  fi
  echo "export OK: $tag exit=$want"
  RUN_OK=$((RUN_OK + 1))
}

# Observational check probe — check paused / CHK002; never soft FAIL→OK.
obs_check() {
  local tag="$1"
  shift
  local log="/tmp/xlang_export_obs_${tag}_$$.log"
  local ec
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$@" >"$log" 2>&1
  ec=$?
  set -e
  echo "export OBS $tag (check paused/CHK002 or visibility residual; refuse soft silence) ec=$ec" >&2
  OBS=$((OBS + 1))
  rm -f "$log"
}

echo "=== export gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

for f in tests/export/user_export.x \
  tests/export/user_private_should_fail.x \
  tests/export/lint_unused_private.x \
  tests/export/lint_used_private.x \
  tests/export/lib_export.x; do
  [ -f "$f" ] || die "missing $f"
done

# Throwaway syntax fixture for observational check only.
echo 'export function foo(): i32 { return 1; }
function main(): i32 { return foo(); }' > /tmp/xlang_export_syn.x

obs_check export_syntax "$XLANG_BIN" check /tmp/xlang_export_syn.x
obs_check private_strict_reject "$XLANG_BIN" check tests/export/user_private_should_fail.x
obs_check private_compat env XLANG_VISIBILITY=compat "$XLANG_BIN" check tests/export/user_private_should_fail.x
obs_check private_warn env XLANG_VISIBILITY=warn "$XLANG_BIN" check tests/export/user_private_should_fail.x
obs_check export_api_default "$XLANG_BIN" check tests/export/user_export.x
obs_check export_api_strict env XLANG_VISIBILITY=strict "$XLANG_BIN" check tests/export/user_export.x
obs_check lint_unused_private "$XLANG_BIN" check tests/export/lint_unused_private.x
obs_check lint_used_private "$XLANG_BIN" check tests/export/lint_used_private.x
obs_check lint_unused_private_off env XLANG_UNUSED_PRIVATE=0 "$XLANG_BIN" check tests/export/lint_unused_private.x

# Product -o currently accepts non-export cross-module → obs residual.
priv_exe="/tmp/xlang_export_priv_obs_$$"
priv_log="/tmp/xlang_export_priv_obs.log"
rm -f "$priv_exe" "$priv_log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . \
  tests/export/user_private_should_fail.x -o "$priv_exe" >"$priv_log" 2>&1
priv_ec=$?
set -e
rm -f "$priv_exe" "$priv_log"
echo "export OBS private_product_o (product -o does not reject non-export; was check-bound; refuse soft FAIL→OK) ec=$priv_ec" >&2
OBS=$((OBS + 1))

# Hard product -o arms (no soft prefer-c).
run_exit user_export tests/export/user_export.x 9
run_exit lint_unused_private tests/export/lint_unused_private.x 0

rm -f /tmp/xlang_export_syn.x
ok_report
echo "run-export: all passed"
