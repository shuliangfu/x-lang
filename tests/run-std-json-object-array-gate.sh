#!/usr/bin/env bash
# json-object-array: std.json object/array cursor/parse — leftover unused
# compiler-make →硬绿. Archive ID historically STD-034 (cursor); tracker names
# json-object-array to avoid collision with http-https STD-034.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c). Product object_array_parse.x -o
# exit0 = hard run (run=1). check = obs. Report: run=/obs=/skip= (legacy oa=
# folded into run=). G.7: complete existing resolve_shu; drop unused
# compiler-make.sh. PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-json-object-array-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_JOA_DOC:-analysis/archive/std/std-json-object-array-v1.md}"
MANIFEST="${XLANG_STD_JOA_TSV:-tests/baseline/std-json-object-array.tsv}"
MOD_X="std/json/mod.x"
JSON_X="std/json/json.x"
LIB="tests/lib/std-json-object-array.sh"
OA_X="tests/json/object_array_parse.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-json-object-array.sh
. tests/lib/std-json-object-array.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-json-object-array gate FAIL: $*" >&2
  std_joa_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== json-object-array: cursor/parse manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$JSON_X" "$OA_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in JsonCursor skip_value cursor_object_next 大对象 ZC; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

sym_miss="$(std_joa_symbols_ok "$MOD_X" "$JSON_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-json-object-array manifest OK"

if [ "${XLANG_STD_JOA_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_joa_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-json-object-array gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== json-object-array: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$OA_X" >/tmp/xlang_std_joa_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-json-object-array OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_joa_$$"
LOG="/tmp/xlang_std_joa_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$OA_X" -o "$OUT" >"$LOG" 2>&1
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
echo "std-json-object-array OK: product -o"

std_joa_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-json-object-array gate OK"
