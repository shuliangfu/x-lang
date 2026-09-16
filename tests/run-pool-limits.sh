#!/usr/bin/env bash
# Side-car grow-pool / dynamic-limit boundary smoke — honesty soft→硬绿.
#
# Exceeds historical hard caps (16 params, 96 stmts, 256 funcs, 32 #if depth).
# Invoked by run-b06-ast-pool-gate / run-all.sh.
#
# Honesty: soft auto-make + prefer-c / bootstrap-link wrap to xlang-c (false
# authority; hid asm ld tip residuals) retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: static + generated pool-limit cases with expected exit codes
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_POOL_LIMITS_PREFIX:-xlang: [XLANG_POOL_LIMITS]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-180}"
RUN_OK=0
OBS=0
SKIP=0
GEN_DIR="${TMPDIR:-/tmp}/xlang_pool_limits_gen_$$"
mkdir -p "$GEN_DIR"
trap 'rm -rf "$GEN_DIR"' EXIT

die() {
  echo "pool-limits FAIL: $*" >&2
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

# Product -o hard green. Return 0=ok, 1=hard fail, 2=obs.
# NOTE: keep errexit off across non-zero returns (bash 3.2 + set -e).
run_expect_exit() {
  local src="$1"
  local expect="$2"
  local label="$3"
  local out="$GEN_DIR/out_${label}"
  local err="$GEN_DIR/err_${label}.log"
  local o_ec r_ec
  # Remaining args = optional extra compiler flags (e.g. -DLx for deep_if).
  # PLATFORM: SHARED — bash 3.2 + set -u: empty "${arr[@]}" is unbound; branch.
  shift 3 || true
  rm -f "$out"
  if [ "$#" -gt 0 ]; then
    gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" "$@" "$src" -o "$out" >"$err" 2>&1
  else
    gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  fi
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "pool-limits FAIL: $label -o timeout" >&2
    return 1
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "pool-limits FAIL: $label -o ec=$o_ec; $(tail -4 "$err" 2>/dev/null | tr '\n' ' ')" >&2
    return 1
  fi
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$out" >/dev/null 2>&1
  r_ec=$?
  if [ "$r_ec" -eq 124 ]; then
    echo "pool-limits FAIL: $label run timeout" >&2
    return 1
  fi
  if [ "$r_ec" -ne "$expect" ]; then
    echo "pool-limits FAIL: $label expected exit $expect, got $r_ec" >&2
    return 1
  fi
  echo "pool-limits OK: $label exit=$expect"
  return 0
}

echo "=== pool-limits (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

for f in \
  tests/pool-limits/many_params.x \
  tests/pool-limits/many_fields.x \
  tests/pool-limits/nested_loops.x \
  tests/pool-limits/nested_loops_8.x \
  tests/pool-limits/many_call_args.x \
  tests/pool-limits/many_import_select.x
do
  [ -f "$f" ] || die "missing $f"
done

set +e
run_expect_exit tests/pool-limits/many_params.x 19 many_params
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_params"
RUN_OK=$((RUN_OK + 1))

set +e
run_expect_exit tests/pool-limits/many_fields.x 19 many_fields
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_fields"
RUN_OK=$((RUN_OK + 1))

set +e
run_expect_exit tests/pool-limits/nested_loops.x 6 nested_loops
prc=$?
set -e
[ "$prc" -eq 0 ] || die "nested_loops"
RUN_OK=$((RUN_OK + 1))

set +e
run_expect_exit tests/pool-limits/nested_loops_8.x 8 nested_loops_8
prc=$?
set -e
[ "$prc" -eq 0 ] || die "nested_loops_8"
RUN_OK=$((RUN_OK + 1))

set +e
run_expect_exit tests/pool-limits/many_call_args.x 64 many_call_args
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_call_args"
RUN_OK=$((RUN_OK + 1))

set +e
run_expect_exit tests/pool-limits/many_import_select.x 9 many_import_select
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_import_select"
RUN_OK=$((RUN_OK + 1))

# 30 locals (historical AsmFuncCtx locals[24] hard cap)
{
  echo "// generated: many_locals"
  echo "function main(): i32 {"
  i=0
  while [ "$i" -lt 30 ]; do
    echo "  let v${i}: i32 = ${i};"
    i=$((i + 1))
  done
  echo "  return v29;"
  echo "}"
} > "$GEN_DIR/many_locals.x"
set +e
run_expect_exit "$GEN_DIR/many_locals.x" 29 many_locals
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_locals"
RUN_OK=$((RUN_OK + 1))

# 100 block stmts (historical stmt_order 96 hard cap)
{
  echo "// generated: many_block_stmts"
  echo "function main(): i32 {"
  i=0
  while [ "$i" -lt 100 ]; do
    echo "  let s${i}: i32 = ${i};"
    i=$((i + 1))
  done
  echo "  return s99;"
  echo "}"
} > "$GEN_DIR/many_block_stmts.x"
set +e
run_expect_exit "$GEN_DIR/many_block_stmts.x" 99 many_block_stmts
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_block_stmts"
RUN_OK=$((RUN_OK + 1))

# 260 top-level funcs (historical module func 256 hard cap).
# fn259 returns 42: process exit is u8; return 259 would truncate to 3.
{
  echo "// generated: many_funcs (260); fn259 returns 42 (exit code is u8)"
  i=258
  while [ "$i" -ge 0 ]; do
    echo "function fn${i}(): i32 { return ${i}; }"
    i=$((i - 1))
  done
  echo "function fn259(): i32 { return 42; }"
  echo "function main(): i32 { return fn259(); }"
} > "$GEN_DIR/many_funcs.x"
set +e
run_expect_exit "$GEN_DIR/many_funcs.x" 42 many_funcs
prc=$?
set -e
[ "$prc" -eq 0 ] || die "many_funcs"
RUN_OK=$((RUN_OK + 1))

# #if nest depth 40 (historical preprocess stack[32] hard cap)
DEPTH=40
{
  echo "// generated: deep_if_nest depth=$DEPTH"
  i=1
  while [ "$i" -le "$DEPTH" ]; do
    echo "#if L${i}"
    i=$((i + 1))
  done
  echo "function main(): i32 { return 40; }"
  i=$DEPTH
  while [ "$i" -ge 1 ]; do
    echo "#endif"
    i=$((i - 1))
  done
} > "$GEN_DIR/deep_if_nest.x"
# Build -DLx flags as positional args (bash 3.2 + set -u safe).
set --
i=1
while [ "$i" -le "$DEPTH" ]; do
  set -- "$@" "-DL${i}"
  i=$((i + 1))
done
set +e
run_expect_exit "$GEN_DIR/deep_if_nest.x" 40 deep_if_nest "$@"
prc=$?
set -e
[ "$prc" -eq 0 ] || die "deep_if_nest"
RUN_OK=$((RUN_OK + 1))

echo "pool-limits test OK"
ok_report
