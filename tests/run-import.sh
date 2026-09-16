#!/usr/bin/env bash
# import binding smoke: const mod = import(...) + select + missing-module NEG
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft bootstrap-link / soft bootstrap-min SKIP→OK / soft bstrict SIGSEGV retry).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_IMPORT_PREFIX:-xlang: [IMPORT]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "import FAIL: $*" >&2
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
  # Opt-in leftover Stage2 only (July-14 wrong-binary ban otherwise).
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

run_hello() {
  local tag="$1" src="$2"
  local exe="/tmp/xlang_import_${tag}_$$"
  local log="/tmp/xlang_import_${tag}_$$.log"
  local o_ec out
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  out=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" 2>&1)
  o_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$o_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$o_ec" -ne 0 ]; then
    die "$tag expected exit 0, got $o_ec"
  fi
  echo "$out" | grep -q "Hello World" || die "$tag expected Hello World in stdout"
  RUN_OK=$((RUN_OK + 1))
}

run_exit0() {
  local tag="$1" src="$2"
  local exe="/tmp/xlang_import_${tag}_$$"
  local log="/tmp/xlang_import_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
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
  elif [ "$r_ec" -ne 0 ]; then
    die "$tag expected exit 0, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
}

echo "=== import gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# POS: binding import + print_str path.
run_hello main tests/import/main.x
# POS: const types = import("core.types");
run_exit0 const_binding tests/import/const_binding.x
# POS: const io = import("std.io"); → io.print_str
run_hello const_select tests/import/const_select.x
# POS: binding import + module-prefixed call.
run_hello const_select_alias_fn tests/import/const_select_alias_fn.x

# NEG: missing module must hard-fail product -o with import diagnostic.
neg_src="tests/import/missing_module.x"
[ -f "$neg_src" ] || die "missing $neg_src"
neg_exe="/tmp/xlang_import_miss_$$"
neg_log="/tmp/xlang_import_miss_$$.log"
rm -f "$neg_exe" "$neg_log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$neg_src" -o "$neg_exe" >"$neg_log" 2>&1
neg_ec=$?
set -e
if [ "$neg_ec" -eq 124 ]; then
  die "missing_module timeout"
elif [ "$neg_ec" -eq 0 ]; then
  die "missing_module expected compile fail, got success"
fi
grep -qE "cannot open import|failed to parse import" "$neg_log" \
  || die "expected import error for missing module; $(tail -5 "$neg_log" 2>/dev/null | tr '\n' ' ')"
rm -f "$neg_exe" "$neg_log"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "import test OK"
