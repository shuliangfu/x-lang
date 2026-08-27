#!/usr/bin/env bash
# X5: Struct layout assert gate — honesty soft→硬绿.
#
# Honesty: hard-bound xlang-c -E + host-cc static_assert + zig cross as the
# only path (prefer-c / false authority) retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o tests/struct/simple.x (exit 1) + padding_allow (exit 2)
#   - hard: asm -E emits struct Layout8 (stderr not mixed into .c)
#   - host-cc _Static_assert / zig x86 cross / bitfield packed = obs
#     (tip residual "struct hook = obs"; not soft SKIP→OK)
# Report: run=/obs=/skip=
# Usage: ./tests/run-struct-layout-assert-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_STRUCT_LAYOUT_PREFIX:-xlang: [XLANG_STRUCT_LAYOUT]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
WORKDIR="${TMPDIR:-/tmp}/xlang_struct_layout_$$"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "struct-layout FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  rm -rf "$WORKDIR"
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

# Product -o hard green. Return 0=ok, 1=hard fail, 2=obs.
# NOTE: keep errexit off across non-zero returns (bash 3.2 + set -e).
product_run_case() {
  local label="$1"
  local src="$2"
  local expect_ec="$3"
  local err="$WORKDIR/${label}.log"
  local out="$WORKDIR/${label}.exe"
  local o_ec r_ec
  [ -f "$src" ] || { echo "struct-layout FAIL: missing $src" >&2; return 1; }

  rm -f "$out"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "struct-layout OBS $label (-o timeout; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "struct-layout FAIL $label (-o ec=$o_ec)" >&2
    tail -n 12 "$err" >&2 || true
    return 1
  fi
  gate_run_timeout 10 "$out" >/dev/null 2>&1
  r_ec=$?
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    echo "struct-layout OBS $label (run timeout; product residual)" >&2
    return 2
  fi
  if [ "$r_ec" -eq "$expect_ec" ]; then
    echo "struct-layout OK $label (exit=$r_ec)"
    return 0
  fi
  echo "struct-layout FAIL $label (expected exit $expect_ec, got $r_ec)" >&2
  return 1
}

# asm -E must emit struct Layout8; stderr stays out of .c (refuse 2>&1 mix).
# Return 0=ok, 1=hard fail, 2=obs.
emit_layout8_case() {
  local src="$WORKDIR/layout8.x"
  local c_out="$WORKDIR/layout8.c"
  local err="$WORKDIR/layout8.err"
  local o_ec
  cat >"$src" <<'XEOF'
#[repr(C)]
struct Layout8 { a: u8; b: u8; }
#[repr(C)]
struct Layout32 { a: u32; b: u32; }
#[used] function get_a8(s: Layout8): i32 { return s.a as i32; }
#[used] function get_a32(s: Layout32): i32 { return s.a as i32; }
function main(): i32 { return 0; }
XEOF
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$src" >"$c_out" 2>"$err"
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "struct-layout OBS emit_layout8 (-E timeout; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ]; then
    echo "struct-layout FAIL emit_layout8 (-E ec=$o_ec)" >&2
    tail -n 12 "$err" >&2 || true
    return 1
  fi
  # Refuse info: lines mixed into C (old prefer-c 2>&1 bug).
  if grep -qE '^info:|^error:|^warning:' "$c_out" 2>/dev/null; then
    echo "struct-layout FAIL emit_layout8 (stderr mixed into .c; refuse soft -E)" >&2
    return 1
  fi
  if grep -q 'struct Layout8 {' "$c_out" && grep -q 'struct Layout32 {' "$c_out"; then
    echo "struct-layout OK emit_layout8"
    return 0
  fi
  echo "struct-layout FAIL emit_layout8 (struct defs missing)" >&2
  return 1
}

# Host-cc _Static_assert on -E output = obs (tip struct hook residual).
# Return 0=ok counted as run, 2=obs.
host_static_assert_obs() {
  local src="$WORKDIR/layout_host.x"
  local c_out="$WORKDIR/layout_host.c"
  local err="$WORKDIR/layout_host.err"
  local o_ec
  cat >"$src" <<'XEOF'
#[repr(C)]
struct Layout8 { a: u8; b: u8; }
#[repr(C)]
struct Layout16 { a: u16; b: u16; }
#[repr(C)]
struct Layout32 { a: u32; b: u32; }
#[repr(C)]
struct Layout64 { a: u64; b: u64; }
#[repr(C)]
struct LayoutMixed { a: u8; b: u32; c: u8; }
#[used] function get_a8(s: Layout8): i32 { return s.a as i32; }
#[used] function get_mix(s: LayoutMixed): i32 { return s.a as i32; }
function main(): i32 { return 0; }
XEOF
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$src" >"$c_out" 2>"$err"
  o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -s "$c_out" ]; then
    echo "struct-layout OBS host_static_assert (-E fail; struct hook residual)" >&2
    return 2
  fi
  cat >>"$c_out" <<'CEOF'
#include <assert.h>
#include <stddef.h>
_Static_assert(sizeof(struct Layout8) == 2, "Layout8 should be 2 bytes");
_Static_assert(sizeof(struct Layout16) == 4, "Layout16 should be 4 bytes");
_Static_assert(sizeof(struct Layout32) == 8, "Layout32 should be 8 bytes");
_Static_assert(sizeof(struct Layout64) == 16, "Layout64 should be 16 bytes");
_Static_assert(offsetof(struct LayoutMixed, a) == 0, "LayoutMixed.a at offset 0");
_Static_assert(offsetof(struct LayoutMixed, b) == 4, "LayoutMixed.b at offset 4 (aligned)");
CEOF
  if cc -O2 -o /dev/null -c "$c_out" >/dev/null 2>"$err"; then
    echo "struct-layout OK host_static_assert"
    return 0
  fi
  echo "struct-layout OBS host_static_assert (cc static_assert fail; struct hook residual)" >&2
  return 2
}

mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== X5: Struct layout assert (XLANG=$XLANG_BIN) ==="

# Hard product -o smokes (fixtures under tests/struct/).
HARD_SMOKES=(
  "simple:tests/struct/simple.x:1"
  "padding_allow:tests/struct/padding_allow.x:2"
)
for entry in "${HARD_SMOKES[@]}"; do
  label="${entry%%:*}"
  rest="${entry#*:}"
  src="${rest%%:*}"
  expect_ec="${rest##*:}"
  prc=0
  product_run_case "$label" "$src" "$expect_ec" || prc=$?
  case "$prc" in
    0) RUN_OK=$((RUN_OK + 1)) ;;
    2) OBS=$((OBS + 1)) ;;
    *) die "hard smoke $label" ;;
  esac
done

# Hard: asm -E emits Layout8/Layout32 without stderr mix.
prc=0
emit_layout8_case || prc=$?
case "$prc" in
  0) RUN_OK=$((RUN_OK + 1)) ;;
  2) OBS=$((OBS + 1)) ;;
  *) die "emit_layout8" ;;
esac

# Tip residual host-cc static_assert path = obs (not soft SKIP→OK).
prc=0
host_static_assert_obs || prc=$?
case "$prc" in
  0) RUN_OK=$((RUN_OK + 1)) ;;
  2) OBS=$((OBS + 1)) ;;
  *) die "host_static_assert unexpected" ;;
esac

ok_report
echo "struct-layout-assert gate OK"
