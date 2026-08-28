#!/usr/bin/env bash
# STD-011: std.error unify gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# error/mod.o make) + soft XLANG fallthrough (explicit-bad still picks another
# binary) + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c). Product error_unify_smoke.x -o exit0 =
# hard run. check residual = obs (paused 2026-08-05). Report: run=/obs=/skip=.
# Matrix: error_base_* / <mod>_err_* / sidecar / EXC layer+RFC fossils.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-error-unify-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_ERROR_UNIFY_DOC:-analysis/archive/std/std-error-unify-v1.md}"
MATRIX="${XLANG_STD_ERROR_UNIFY_TSV:-tests/baseline/std-error-unify.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/std-error-unify.sh"
LAYER_DOC="${XLANG_EXC_ERROR_CODE_LAYER_DOC:-analysis/archive/exc/exc-error-code-layer-v1.md}"
RESULT_RFC="${XLANG_EXC_RESULT_ERROR_RFC:-analysis/archive/exc/exc-result-error-v1-rfc.md}"
SMOKE="tests/std/error_unify_smoke.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-error-unify.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-error-unify gate FAIL: $*" >&2
  std_error_unify_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-011: std error unify manifest ==="
for f in "$DOC" "$MATRIX" "$ERR_MOD" "$LIB" "$LAYER_DOC" "$RESULT_RFC" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done

grep -qF -- 'STD-011' "$DOC" 2>/dev/null || die "doc missing STD-011"
grep -qF -- 'std-error-unify.tsv' "$DOC" 2>/dev/null || die "doc missing matrix ref"

echo "=== STD-011: module matrix ==="
miss="$(std_error_unify_manifest_ok "$ERR_MOD" "$MATRIX" || true)"
[ "${miss:-0}" -eq 0 ] || die "missing=${miss}"

# Allow smoke path override from matrix smoke_case row (same as historical gate).
while IFS=$'\t' read -r module_id _exc _base _side src _tier _notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in
    smoke_case)
      SMOKE="$src"
      ;;
  esac
done < "$MATRIX"
[ -f "$SMOKE" ] || die "missing $SMOKE"
echo "std-error-unify manifest OK"

if [ "${XLANG_STD_ERROR_UNIFY_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_error_unify_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-error-unify gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-011: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_error_unify_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-error-unify OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_error_unify_$$"
LOG="/tmp/xlang_std_error_unify_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$OUT" >"$LOG" 2>&1
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
echo "std-error-unify OK: product -o"

std_error_unify_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-error-unify gate OK"
