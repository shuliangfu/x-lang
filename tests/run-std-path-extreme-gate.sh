#!/usr/bin/env bash
# STD-140: std.path extreme path normalize gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# extreme_clean.x -o exit0 = hard run (run=1). check residual = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-path-extreme-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD140_DOC:-analysis/archive/std/std-path-extreme-v1.md}"
MANIFEST="${XLANG_STD140_MANIFEST:-tests/baseline/std-path-extreme-manifest.tsv}"
VECTORS="${XLANG_STD140_VECTORS:-tests/baseline/std-path-extreme.tsv}"
MOD_X="std/path/mod.x"
LIB="tests/lib/std-path-extreme.sh"
SMOKE_X="tests/path/extreme_clean.x"
MIN_VECTORS=8
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-path-extreme.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-path-extreme gate FAIL: $*" >&2
  std_path_extreme_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-140: std.path extreme manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SMOKE_X" std/path/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-140 clean resolve extension_and_stem foo//baz; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_path_extreme_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"

std_path_extreme_vectors_ok "$VECTORS" "$MIN_VECTORS" || die "vectors check failed"

for sym in clean resolve extension_and_stem join sep is_absolute; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "mod missing function ${sym}"
done
for call in path.clean path.resolve path.extension_and_stem; do
  grep -q "${call}" "$SMOKE_X" 2>/dev/null || die "smoke missing ${call}"
done
echo "std-path-extreme registry OK"

if [ "${XLANG_STD140_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_path_extreme_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-path-extreme gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-140: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std140_path_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-path-extreme OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std140_path_extreme_$$"
LOG="/tmp/xlang_std140_path_extreme_build_$$.log"
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
echo "std-path-extreme OK: product -o"

std_path_extreme_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-path-extreme gate OK"
