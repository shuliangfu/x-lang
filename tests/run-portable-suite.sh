#!/usr/bin/env bash
# run-portable-suite.sh — Tier P 便携测试套件（全平台必过）。
#
# 统一 .su / shu-c 测试，不区分平台写业务代码；平台专有能力在子脚本内自动 N/A。
# 由 tests/run-ci-full-suite.sh 在所有 job 上调用。
#
# 用法：./tests/run-portable-suite.sh [--with-c-regression]
set -e
cd "$(dirname "$0")/.."

WITH_C_REGRESSION=0
for arg in "$@"; do
  case "$arg" in
    --with-c-regression) WITH_C_REGRESSION=1 ;;
    -h|--help)
      echo "Usage: $0 [--with-c-regression]"
      exit 0
      ;;
    *)
      echo "run-portable-suite: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

echo "run-portable-suite: Tier P (host=$(ci_host_summary))"

# 非 x86_64 / MSYS2：-o 链接优先 shu-c（与 bootstrap-link-shu 一致）。
if ci_is_arm64_host || ci_is_windows_msys; then
  export SHULANG_LINK_SHU=./compiler/shu-c
fi

run_grep() {
  local log="$1"
  local pattern="$2"
  shift 2
  "$@" | tee "$log"
  grep -q "$pattern" "$log"
}

echo "── M-3 region typeck ──"
chmod +x tests/run-typeck-region.sh
run_grep /tmp/typeck_region.log 'region typeck OK' ./tests/run-typeck-region.sh

echo "── migrate SU gen gate ──"
chmod +x tests/run-migrate-su-gen-gate.sh
run_grep /tmp/migrate_su_gen.log 'migrate su gen gate OK' ./tests/run-migrate-su-gen-gate.sh

echo "── M-4 linear typeck ──"
chmod +x tests/run-typeck-linear.sh
run_grep /tmp/typeck_linear.log 'linear typeck OK' ./tests/run-typeck-linear.sh

echo "── ZC-3 slice field ──"
chmod +x tests/run-slice-field.sh tests/run-slice.sh
run_grep /tmp/slice_field.log 'slice field OK' ./tests/run-slice-field.sh
run_grep /tmp/slice_full.log 'slice test OK' ./tests/run-slice.sh

echo "── stdlib import ──"
chmod +x tests/run-stdlib-import.sh
run_grep /tmp/stdlib_import.log 'stdlib-import test OK' ./tests/run-stdlib-import.sh

echo "── IO unified gate (同一套 .su 全平台) ──"
chmod +x tests/run-io-unified-gate.sh
./tests/run-io-unified-gate.sh | tee /tmp/io_unified_gate.log
grep -q 'io unified gate OK' /tmp/io_unified_gate.log

if [ "$WITH_C_REGRESSION" -eq 1 ]; then
  echo "── portable C regression (run-portable-c) ──"
  chmod +x tests/run-portable-c.sh
  ./tests/run-portable-c.sh | tee /tmp/portable_c.log
  grep -q 'run-portable-c OK' /tmp/portable_c.log
fi

echo "run-portable-suite OK (Tier P)"
