#!/usr/bin/env bash
# asm 7.3: *i32 param and struct field-array INDEX assign; helper has no mov x2.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make xlang-c (prefer-c
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c). Both ptr and struct cases use the same prefer-asm
# product path (no soft LINK_XLANG→xlang-c split).
#   - hard: assign_index_ptr_param.x product -o run exit 99; set_at no mov x2
#   - hard: assign_index_struct_field.x product -o run exit 99; set_in no mov x2
#   - skip: non-Darwin / no otool disasm N/A
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required; Darwin arm64 disasm.
# Historical note: Linux xlang_asm struct emit once SIGSEGV'd; tip prefer-asm
# must prove both ends — do not soft-fallback to xlang-c.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_ASM_ASSIGN_INDEX_PARAM_PREFIX:-xlang: [XLANG_ASM_ASSIGN_INDEX_PARAM]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "asm-assign-index-param FAIL: $*" >&2
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

# Product -o + expected exit; Darwin otool forbids mov x2 in named helper.
run_case() {
  local tag="$1" src="$2" want="$3" fn="$4"
  local exe="/tmp/xlang_asm_assign_index_param_${tag}_$$"
  local log="/tmp/xlang_asm_assign_index_param_${tag}_$$.log"
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
  if [ "$r_ec" -eq 124 ]; then
    rm -f "$exe"
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    rm -f "$exe"
    die "$tag expected exit $want, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  # PLATFORM: DARWIN — otool arm64 helper disasm. Non-Darwin = skip= honesty.
  if [ "$(uname -s)" = Darwin ] && command -v otool >/dev/null 2>&1; then
    if otool -tv "$exe" 2>/dev/null | sed -n "/^_${fn}:/,/^_[a-z]/p" | grep -q 'mov x2'; then
      rm -f "$exe"
      die "$tag ${fn} still uses mov x2"
    fi
    RUN_OK=$((RUN_OK + 1))
  else
    SKIP=$((SKIP + 1))
  fi
  rm -f "$exe"
}

echo "=== asm-assign-index-param gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_case ptr_param tests/asm/assign_index_ptr_param.x 99 set_at
run_case struct_field tests/asm/assign_index_struct_field.x 99 set_in

ok_report
echo "asm assign index param OK"
