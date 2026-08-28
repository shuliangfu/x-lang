#!/usr/bin/env bash
# std.process leftover runner: tests/process/*.x product -o
# (main exit 99; remaining exit 0; spawn_wait Windows skip).
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q xlang-c || make`
# + ensure_std_c_o process.o) + bootstrap-link wrap (prefer-c) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / leftover XLANG fallthrough / soft
# auto-make / soft ensure). Check path = obs= (check gate paused 2026-08-05).
# Product `-o` live smokes must match expected exit. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-process.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_PROCESS_PREFIX:-xlang: [PROCESS]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "process FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# G.7: complete the existing per-script resolve_shu family (dod_native_exe);
# do not fork a third resolver. Explicit XLANG that is missing/non-native
# returns 1 (caller hard-dies; refuse leftover XLANG fallthrough).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

run_product() {
  local tag="$1" src="$2"
  local expect="${3:-0}"
  local exe="/tmp/xlang_process_$$_${tag}"
  local log="/tmp/xlang_process_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    tail -n 12 "$log" 2>/dev/null || true
    rm -f "$exe"
    die "$tag product -o failed (ec=$o_ec; refuse leftover auto-make / bootstrap-link wrap / ensure_std_c_o)"
  fi
  set +e
  "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  [ "$r_ec" -eq "$expect" ] || die "$tag runnable exit=$r_ec (expected $expect)"
  RUN_OK=$((RUN_OK + 1))
}

# spawn_simple + waitpid: POSIX hard; Windows no /bin/true = honest skip.
# PLATFORM: WINDOWS skip is N/A (not soft SKIP→OK of a missing compiler).
run_spawn_wait() {
  local tag="spawn_wait" src="tests/process/spawn_wait.x"
  local exe="/tmp/xlang_process_$$_${tag}"
  local log="/tmp/xlang_process_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    case "$(uname -s 2>/dev/null)" in
      MINGW*|MSYS*|CYGWIN*|*Windows*)
        echo "process test spawn_wait: SKIP (no true on Windows)"
        SKIP=$((SKIP + 1))
        rm -f "$exe" "$log"
        return 0
        ;;
      *)
        tail -n 12 "$log" 2>/dev/null || true
        rm -f "$exe"
        die "$tag product -o failed (ec=$o_ec; refuse leftover auto-make)"
        ;;
    esac
  fi
  set +e
  "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$r_ec" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
    return 0
  fi
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*|*Windows*)
      echo "process test spawn_wait: SKIP (no true on Windows)"
      SKIP=$((SKIP + 1))
      ;;
    *)
      die "$tag runnable exit=$r_ec (expected 0)"
      ;;
  esac
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== process leftover (prefer asm; hard; refuse leftover auto-make) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft auto-make)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . tests/process/main.x >/tmp/xlang_process_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "process OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

run_product exit tests/process/main.x 99
run_product args tests/process/args.x
run_product setenv_unsetenv tests/process/setenv_unsetenv.x
run_product getpid tests/process/getpid.x
run_product getppid tests/process/getppid.x
run_product getcwd tests/process/getcwd.x
run_product chdir tests/process/chdir.x
run_product self_exe_path tests/process/self_exe_path.x
run_product zerocopy tests/process/zerocopy.x
run_spawn_wait
run_product exec_fail tests/process/exec_fail.x
run_product xplat_behavior tests/process/xplat_behavior.x

ok_report
echo "process test OK (all)"
rm -f /tmp/xlang_process_$$_*
