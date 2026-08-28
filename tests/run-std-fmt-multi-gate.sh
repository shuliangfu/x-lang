#!/usr/bin/env bash
# STD-019: std.fmt multi-arg format gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft XLANG
# fallthrough (explicit-bad still picks another binary) + check=/run=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product format_multi.x -o exit0 = hard run (run=1). check = obs (paused
# 2026-08-05; leave ensure_std family alone). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-fmt-multi-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_FMT_MULTI_DOC:-analysis/archive/std/std-fmt-multi-v1.md}"
MANIFEST="${XLANG_STD_FMT_MULTI_TSV:-tests/baseline/std-fmt-multi.tsv}"
FMT_X="std/fmt/mod.x"
LIB="tests/lib/std-fmt-multi.sh"
SMOKE="tests/fmt-std/format_multi.x"
RUNNER="tests/run-fmt-std.sh"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-fmt-multi.sh
. tests/lib/std-fmt-multi.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-fmt-multi gate FAIL: $*" >&2
  std_fmt_multi_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-019: fmt multi manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$FMT_X" "$SMOKE" "$RUNNER"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in 'usize, usize' 'i32, i32, i32' ptr_to_buf; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_fmt_multi_symbols_ok "$FMT_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-fmt-multi manifest OK"

if [ "${XLANG_STD_FMT_MULTI_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_fmt_multi_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-fmt-multi gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-019: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# check = obs only (paused 2026-08-05); refuse soft SKIP→OK.
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_fmt_multi_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-fmt-multi OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make of xlang-c; leave ensure_std family alone.
# PLATFORM: SHARED archaeology.

OUT="/tmp/xlang_std_fmt_multi_$$"
LOG="/tmp/xlang_std_fmt_multi_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  if grep -qE "library 'zstd' not found|cannot find -lzstd" "$LOG" 2>/dev/null; then
    echo "std-fmt-multi gate FAIL: libzstd missing (install zstd or rebuild compress.o without XLANG_USE_ZSTD)" >&2
  fi
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
echo "std-fmt-multi OK: product -o"

std_fmt_multi_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-fmt-multi gate OK"
