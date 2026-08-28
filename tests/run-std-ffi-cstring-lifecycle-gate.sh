#!/usr/bin/env bash
# STD-055: std.ffi CString lifecycle + error-code gate — honesty soft auto-make →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft ensure_std_c_o / soft auto-make (`xlang_compiler_make … || true`) +
# check=/run=/safe004=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse
# soft SKIP→OK / soft auto-make / prefer-c / soft ensure rebuild). Product
# cstring_try_new.x -o exit0 + SAFE-004 regression = hard run (both folded
# into run=). check / host-C archaeology = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-ffi-cstring-lifecycle-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_FFI_CSTRING_DOC:-analysis/archive/std/std-ffi-cstring-lifecycle-v1.md}"
MANIFEST="${XLANG_STD_FFI_CSTRING_TSV:-tests/baseline/std-ffi-cstring-lifecycle.tsv}"
VECTORS="${XLANG_STD_FFI_CSTRING_VECTORS:-tests/baseline/std-ffi-cstring-lifecycle-vectors.tsv}"
MOD_X="std/ffi/mod.x"
FFI_IMPL="std/ffi/ffi.x"
LIB="tests/lib/std-ffi-cstring-lifecycle.sh"
SMOKE_X="tests/std-ffi/cstring_try_new.x"
SMOKE_C="tests/std-ffi/cstring_lifecycle_ok.c"
SAFE_HOOK="tests/run-safe-ffi-contract-gate.sh"
MIN_APIS=4
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-ffi-cstring-lifecycle.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-ffi-cstring gate FAIL: $*" >&2
  std_ffi_cstring_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-055: ffi cstring lifecycle manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$FFI_IMPL" "$SMOKE_X" "$SMOKE_C" "$SAFE_HOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-055 FFI_ERR_OOM cstring_try_new TYPE-004; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_ffi_cstring_symbols_ok "$MOD_X" "$FFI_IMPL" "$FFI_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-ffi-cstring manifest OK"

if [ "${XLANG_STD_FFI_CSTRING_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_ffi_cstring_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-ffi-cstring gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-055: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o + SAFE-004 hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_ffi_cstring_run_c_smoke "$FFI_IMPL"; then
  echo "std-ffi-cstring c smoke OK (observational)"
else
  echo "std-ffi-cstring OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std055_ffi_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-ffi-cstring OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std055_ffi_cstr_$$"
LOG="/tmp/xlang_std055_ffi_cstr_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-ffi-cstring OK: product -o"

echo "=== STD-055: SAFE-004 regression ==="
set +e
chmod +x "$SAFE_HOOK"
"$SAFE_HOOK" >/tmp/std_ffi_safe004_regress.log 2>&1
safe_ec=$?
set -e
if [ "$safe_ec" -eq 0 ] && grep -q 'safe-ffi-contract gate OK' /tmp/std_ffi_safe004_regress.log; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-ffi-cstring OK: SAFE-004"
else
  tail -15 /tmp/std_ffi_safe004_regress.log >&2 || true
  die "SAFE-004 regression (refuse soft SKIP→OK)"
fi

std_ffi_cstring_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-ffi-cstring gate OK"
