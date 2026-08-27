#!/usr/bin/env bash
# TYPE-004: FFI type-bridge smoke (putchar + cstr) — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c (xlang-c before asm) +
# soft auto-make retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make).
#   - tests/ffi/putchar.x product -o (exit 0 or 65) = hard run
#   - tests/ffi/contract_null_cstr.x product -o exit0 = hard run
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-type-ffi-bridge.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/type-ffi-bridge.sh
. tests/lib/type-ffi-bridge.sh
# shellcheck source=tests/lib/safe-ffi.sh
. tests/lib/safe-ffi.sh

PREFIX="${XLANG_TYPE_FFI_PREFIX:-xlang: [XLANG_TYPE_FFI_BRIDGE]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "type-ffi-bridge FAIL: $*" >&2
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
    # Explicit XLANG that is not native = hard die (refuse soft fallthrough).
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

echo "=== TYPE-004: FFI bridge smoke (XLANG=$XLANG_BIN) ==="

# i32 → putchar (scalar bridge) — product -o hard.
exe="/tmp/xlang_ffi_bridge_putchar_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . tests/ffi/putchar.x -o "$exe" >/tmp/xlang_ffi_bridge_putchar.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_ffi_bridge_putchar.log 2>/dev/null || true
  die "compile putchar.x failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
rc=$?
set -e
rm -f "$exe"
# putchar returns the written char (65 for 'A') or 0 on some hosts — both OK.
if [ "$rc" -ne 65 ] && [ "$rc" -ne 0 ]; then
  die "putchar exit=$rc (expect 0 or 65)"
fi
RUN_OK=$((RUN_OK + 1))
echo "type-ffi-bridge OK putchar"

# *u8 cstr_len (pointer bridge) — reuse safe-ffi product -o path.
if safe_ffi_run_case "$XLANG_BIN" tests/ffi/contract_null_cstr.x 0 cstr_u8; then
  RUN_OK=$((RUN_OK + 1))
  echo "type-ffi-bridge OK cstr_u8"
else
  die "contract_null_cstr.x (refuse soft SKIP→OK)"
fi

if [ "$RUN_OK" -lt 1 ]; then
  die "no cases ran (refuse soft SKIP→OK)"
fi

echo "type-ffi-bridge OK"
ok_report
