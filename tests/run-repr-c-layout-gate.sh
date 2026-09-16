#!/usr/bin/env bash
# B-03 v1: #[repr(C)] C ABI layout smoke (u8+u32 implicit padding must
# typeck/compile). Negative: missing #[repr(C)] / allow(padding) must typeck
# fail. Positive: tests/lexer/repr_c_layout_smoke.x returns 43.
#
# Honesty: leftover XLANG seed fallthrough (`if [ ! -x "$XLANG" ]; then
# XLANG=./compiler/xlang`) retired. Leftover XLANG_REPR_C_LAYOUT_FAIL=0
# (soft SKIP→OK) retired. Prefer xlang_asm; pin XLANG_LINK_XLANG.
# Explicit-bad XLANG / missing native = hard die. Compile/run failure stays
# hard. G.7: complete existing resolve_shu; converge dod_native_exe.
#
# Usage: ./tests/run-repr-c-layout-gate.sh
# Report: run=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

GOOD="tests/lexer/repr_c_layout_smoke.x"
BAD="/tmp/xlang_repr_c_layout_bad.$$.x"
OUT="/tmp/xlang_repr_c_layout.$$.out"
PREFIX="xlang: [XLANG_REPR_C_LAYOUT]"
RUN_OK=0
SKIP=1

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
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

die() {
  echo "repr-c-layout-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG seed fallthrough / soft SKIP→OK / soft auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG seed fallthrough / soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

[ -f "$GOOD" ] || die "missing $GOOD"

# Negative: without repr(C)/allow(padding), u8+u32 must typeck-fail
# (implicit padding). PLATFORM: SHARED — product typeck contract.
cat > "$BAD" << 'EOF'
struct BadHeader {
  tag: u8
  len: u32
}
function main(): i32 {
  return 0;
}
EOF

if "$XLANG_BIN" build -o /dev/null "$BAD" 2>/tmp/xlang_repr_c_layout_neg.log; then
  rm -f "$BAD" 2>/dev/null || true
  die "expected typeck error for struct without #[repr(C)]"
fi
rm -f "$BAD" 2>/dev/null || true
RUN_OK=$((RUN_OK + 1))

rm -f "$OUT" 2>/dev/null || true
if ! "$XLANG_BIN" build -o "$OUT" "$GOOD" 2>/tmp/xlang_repr_c_layout.log; then
  echo "repr-c-layout-gate FAIL: compile $GOOD" >&2
  tail -n 8 /tmp/xlang_repr_c_layout.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  die "compile $GOOD"
fi

if [ ! -x "$OUT" ]; then
  die "no executable $OUT"
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 43 ]; then
  die "expected exit 43 (1+42), got $rc"
fi
RUN_OK=$((RUN_OK + 1))
SKIP=0

echo "repr-c-layout-gate OK (#[repr(C)] allows C padding + main returns 43)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
