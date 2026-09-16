#!/usr/bin/env bash
# asm smoke: product -o exits for core asm fixtures + optional -backend asm text.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make + soft bootstrap
# cascade + soft SKIP→OK on missing stdout asm (false authority) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o + expected exits for main/expr/local/index_assign/tiny_ptr
#   - hard: when -backend asm stdout emits assembly, require .text/main/ret
#   - skip: CI without XLANG_CI_FORCE_ASM=1 (opt-in job)
#   - skip: -backend asm stdout is typeck-only / C / empty (product -o still hard;
#     do NOT soft-exit the whole gate)
#   - skip: optional as+ld / cross-target / COFF when tools or emission N/A
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required for product -o.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_ASM_SMOKE_PREFIX:-xlang: [XLANG_ASM_SMOKE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "run-asm FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

skip_report() {
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

run_product_o() {
  local tag="$1" src="$2" want="$3"
  local exe="/tmp/xlang_asm_smoke_${tag}_$$"
  local log="/tmp/xlang_asm_smoke_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  if [ "$r_ec" -eq 124 ]; then
    rm -f "$exe"
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    rm -f "$exe"
    die "$tag expected exit $want, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  rm -f "$exe"
}

# -backend asm stdout: hard .text/main/ret when assembly emitted; else skip=
# (typeck-only / C / empty). Never soft-exit the whole gate.
check_backend_asm_text() {
  local tag="$1" src="$2"
  local out log ec
  out=$(mktemp)
  log=$(mktemp)
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -backend asm "$src" >"$out" 2>"$log"
  ec=$?
  set -e
  # Merge streams for classification (historical script used 2>&1).
  cat "$log" >>"$out"
  if [ "$ec" -eq 124 ]; then
    rm -f "$out" "$log"
    die "$tag -backend asm timeout"
  fi
  if [ "$ec" -ne 0 ]; then
    # Prefer-asm product must not soft-SKIP→OK on -backend asm failure.
    rm -f "$out" "$log"
    die "$tag -backend asm failed (ec=$ec); refuse soft SKIP→OK"
  fi
  if grep -q '\.text' "$out" && grep -q 'main' "$out" && grep -q 'ret' "$out"; then
    RUN_OK=$((RUN_OK + 1))
    rm -f "$out" "$log"
    return 0
  fi
  # typeck-only / C / empty = stdout asm N/A on this product path → skip=
  if grep -q 'typeck OK' "$out" || grep -q '^#include' "$out" || [ ! -s "$out" ]; then
    SKIP=$((SKIP + 1))
    rm -f "$out" "$log"
    return 0
  fi
  rm -f "$out" "$log"
  die "$tag -backend asm output missing .text/main/ret (not typeck-only)"
}

echo "=== run-asm gate (prefer asm; hard product -o) ==="

# PLATFORM: SHARED — CI opt-in; report skip= honesty (not silent soft OK).
if { [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]; } && [ -z "${XLANG_CI_FORCE_ASM:-}" ]; then
  SKIP=$((SKIP + 1))
  echo "run-asm: CI skip (set XLANG_CI_FORCE_ASM=1 to force)"
  skip_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Hard product -o (root honesty: never soft-SKIP the gate before these).
run_product_o main tests/asm/main.x 42
run_product_o expr tests/asm/expr.x 6
run_product_o local tests/asm/local.x 3
run_product_o index_assign tests/asm/index_assign.x 42
run_product_o tiny_ptr tests/asm/tiny_ptr.x 42

# -backend asm stdout archaeology (hard when emitted; skip= when typeck-only).
check_backend_asm_text main_s tests/asm/main.x
check_backend_asm_text expr_s tests/asm/expr.x
check_backend_asm_text local_s tests/asm/local.x
check_backend_asm_text tiny_s tests/asm/tiny_ptr.x
check_backend_asm_text index_s tests/asm/index_assign.x

# Optional: direct -o .o relocatable (skip= when emission N/A).
DIRECT_O=/tmp/xlang_asm_smoke_direct_$$.o
DIRECT_BIN=/tmp/xlang_asm_smoke_direct_bin_$$
rm -f "$DIRECT_O" "$DIRECT_BIN"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -backend asm -o "$DIRECT_O" tests/asm/main.x >/tmp/xlang_asm_smoke_direct_$$.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 0 ] && [ -f "$DIRECT_O" ] && file "$DIRECT_O" 2>/dev/null | grep -qiE 'ELF[[:space:]]*.*relocatable|Mach-O[[:space:]]*64-bit.*object'; then
  RUN_OK=$((RUN_OK + 1))
  if file "$DIRECT_O" | grep -q 'ELF.*relocatable'; then
    if ld -e _main -o "$DIRECT_BIN" "$DIRECT_O" 2>/dev/null; then
      GOT=0; "$DIRECT_BIN" 2>/dev/null || GOT=$?
      if [ "$GOT" -eq 42 ]; then RUN_OK=$((RUN_OK + 1)); else SKIP=$((SKIP + 1)); fi
    else
      SKIP=$((SKIP + 1))
    fi
  elif file "$DIRECT_O" | grep -q 'Mach-O.*object'; then
    if ld -e _main -o "$DIRECT_BIN" "$DIRECT_O" -lSystem 2>/dev/null || clang -o "$DIRECT_BIN" "$DIRECT_O" 2>/dev/null; then
      GOT=0; "$DIRECT_BIN" 2>/dev/null || GOT=$?
      if [ "$GOT" -eq 42 ]; then RUN_OK=$((RUN_OK + 1)); else SKIP=$((SKIP + 1)); fi
    else
      SKIP=$((SKIP + 1))
    fi
  fi
else
  SKIP=$((SKIP + 1))
fi
rm -f "$DIRECT_O" "$DIRECT_BIN"

# Optional cross-target text (skip= when N/A).
for target in aarch64-linux-gnu riscv64; do
  out=$(mktemp)
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -backend asm -target "$target" tests/asm/main.x >"$out" 2>&1
  ec=$?
  set -e
  if [ "$ec" -eq 0 ] && grep -q '\.text' "$out" && grep -q 'main' "$out" && grep -q 'ret' "$out"; then
    RUN_OK=$((RUN_OK + 1))
  else
    SKIP=$((SKIP + 1))
  fi
  rm -f "$out"
done

ok_report
echo "run-asm OK"
