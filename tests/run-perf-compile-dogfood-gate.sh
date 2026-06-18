#!/usr/bin/env bash
# PERF-004：编译器 dogfood 不回退门禁（固定 compile/check 用例 vs 基线）
#
# 检查：
#   1) manifest：compile-dogfood.tsv + 8 个源路径
#   2) Shu median ≤ tests/baseline/compile-dogfood.tsv（默认 SHU_PERF_FAIL_ON_COMPILE_REGRESSION=1）
#
# 用法：./tests/run-perf-compile-dogfood-gate.sh
# 烟测（不硬失败）：SHU_PERF_FAIL_ON_COMPILE_REGRESSION=0 ./tests/run-perf-compile-dogfood-gate.sh
# CI：run-ci-full-suite.sh 在 native Linux x86_64 调用本脚本（硬失败）
set -e
cd "$(dirname "$0")/.."

BASELINE="${SHU_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
FAIL_REG="${SHU_PERF_FAIL_ON_COMPILE_REGRESSION:-1}"

# 判断 shu/shu-c 是否可在本机 exec（与 perf-io-zig gate 一致）。
native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# manifest：case_id 与源路径（bash 3.2 兼容，不用关联数组）。
compile_dogfood_case_src() {
  case "$1" in
    loop_i32) echo tests/bench/loop_i32.su ;;
    mem_copy) echo tests/bench/mem_copy.su ;;
    struct_param) echo tests/bench/struct_param.su ;;
    call_boundary) echo tests/bench/call_boundary.su ;;
    perf_main) echo tests/perf-baseline/main.su ;;
    check_backend) echo compiler/src/asm/backend.su ;;
    check_parser) echo compiler/src/parser/parser.su ;;
    check_typeck) echo compiler/src/typeck/typeck.su ;;
    *) return 1 ;;
  esac
}

COMPILE_DOGFOOD_CASES="loop_i32 mem_copy struct_param call_boundary perf_main check_backend check_parser check_typeck"

echo "=== PERF-004: compile dogfood manifest ==="
if [ ! -f "$BASELINE" ]; then
  echo "perf-compile-dogfood gate FAIL: missing $BASELINE" >&2
  exit 1
fi
if [ ! -f analysis/perf-compile-dogfood-v1.md ]; then
  echo "perf-compile-dogfood gate FAIL: missing analysis/perf-compile-dogfood-v1.md" >&2
  exit 1
fi

missing=0
for case_id in $COMPILE_DOGFOOD_CASES; do
  src=$(compile_dogfood_case_src "$case_id") || true
  if [ -z "$src" ] || [ ! -f "$src" ]; then
    echo "perf-compile-dogfood gate FAIL: missing source for $case_id" >&2
    missing=$((missing + 1))
    continue
  fi
  if ! awk -F'\t' -v c="$case_id" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
    echo "perf-compile-dogfood gate FAIL: baseline missing case $case_id" >&2
    missing=$((missing + 1))
  fi
done
[ "$missing" -eq 0 ] || exit 1
echo "compile-dogfood manifest OK (8 cases)"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "perf-compile-dogfood gate SKIP bench (no native shu; run in Docker/Linux)" >&2
  exit 0
fi

echo "=== PERF-004: compile dogfood vs baseline (SHU=$SHU_BIN FAIL_REG=$FAIL_REG) ==="
chmod +x tests/run-perf-compile-dogfood.sh
SHU="$SHU_BIN" \
  SHU_PERF_FAIL_ON_COMPILE_REGRESSION="$FAIL_REG" \
  ./tests/run-perf-compile-dogfood.sh

echo "perf-compile-dogfood gate OK"
