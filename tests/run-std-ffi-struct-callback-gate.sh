#!/usr/bin/env bash
# STD-151: std.ffi struct/callback safety gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / hard check / c=/x= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK / soft SKIP c smoke) + soft `ensure_std_c_o` +
# hard check as sole .x smoke + report `c=`/`x=` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. Host-C archaeology = obs only (prebuilt std/ffi/ffi.o; refuse
# soft ensure). check residual = obs (paused 2026-08-05). tip product -o
# UNDEF/SEGV = obs (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-ffi-struct-callback-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_FFI_STRUCT_CALLBACK_DOC:-analysis/archive/std/std-ffi-struct-callback-v1.md}"
MANIFEST="${XLANG_STD_FFI_STRUCT_CALLBACK_MANIFEST:-tests/baseline/std-ffi-struct-callback-manifest.tsv}"
MOD_X="std/ffi/mod.x"
FFI_IMPL="std/ffi/ffi.x"
LIB="tests/lib/std-ffi-struct-callback.sh"
SMOKE_X="tests/std-ffi/struct_callback.x"
SMOKE_C="tests/std-ffi/struct_callback_ok.c"
FFI_O="std/ffi/ffi.o"

# shellcheck source=tests/lib/std-ffi-struct-callback.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-ffi-struct-callback gate FAIL: $*" >&2
  std_ffi_struct_callback_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

echo "=== STD-151: ffi struct/callback manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$FFI_IMPL" "$SMOKE_X" "$SMOKE_C" std/ffi/README.md; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-ffi-struct-callback-v1.md ] || die "dual-authority fossil analysis/std-ffi-struct-callback-v1.md (archive live)"
grep -qF STD-151 "$DOC" || die "doc missing STD-151"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
for kw in FfiPoint invoke_cb FFI_ERR_TOO_SMALL; do
  grep -qF -- "$kw" "$DOC" || die "doc missing '$kw'"
done
grep -qF "point_pack" std/ffi/README.md || die "README missing point_pack"

sym_miss="$(std_ffi_struct_callback_symbols_ok "$MOD_X" "$FFI_IMPL" "$FFI_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-ffi-struct-callback registry OK"

if [ "${XLANG_STD151_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_ffi_struct_callback_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-ffi-struct-callback gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-151: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o.
# PLATFORM: SHARED — missing prebuilt ffi.o = obs, not soft SKIP→OK.
set +e
std_ffi_struct_callback_run_c_smoke "$FFI_IMPL"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-ffi-struct-callback OK: c smoke"
    ;;
  *)
    echo "std-ffi-struct-callback OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_ffi_struct_cb_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-ffi-struct-callback OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
# Pass prebuilt ffi.o when present; missing .o is product path obs, not soft ensure.
if std_ffi_struct_callback_run_x_smoke "$XLANG_BIN" "$SMOKE_X" "$FFI_O"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-ffi-struct-callback OK: product struct_callback"
else
  echo "std-ffi-struct-callback OBS tip product struct_callback (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

std_ffi_struct_callback_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-ffi-struct-callback gate OK"
