#!/usr/bin/env bash
# STD-145：std.test 统一 test runner 门禁
#
# 用法：./tests/run-std-test-runner-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-test-runner-v1.md"
MANIFEST="tests/baseline/std-test-runner-manifest.tsv"
MOD_SU="std/test/mod.su"
TEST_C="std/test/test.c"
LIB="tests/lib/std-test-runner.sh"
SMOKE_SU="tests/std-test/runner_smoke.su"

# shellcheck source=tests/lib/std-test-runner.sh
. "$LIB"

echo "=== STD-145: std.test runner manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$TEST_C" "$SMOKE_SU" std/test/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-test-runner gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-145 runner_case runner_finish SHU_TEST_SUMMARY; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-test-runner gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "runner_reset" std/test/README.md 2>/dev/null; then
  echo "std-test-runner gate FAIL: README missing runner_reset" >&2
  exit 1
fi

sym_miss="$(std_test_runner_symbols_ok "$MOD_SU" "$TEST_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_test_runner_emit_report "fail" 0 0
  exit 1
fi
echo "std-test-runner registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/test/test.o
TEST_O="$(cd compiler && pwd)/../std/test/test.o"

EXEC_OK=0
SKIP=0
SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-test-runner gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_test_runner_emit_report "fail" 0 0
    exit 1
  fi
  if std_test_runner_run_smoke "$SHU_BIN" "$SMOKE_SU" "$TEST_O"; then
    EXEC_OK=1
  else
    std_test_runner_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_test_runner_emit_report "ok" "$EXEC_OK" "$SKIP"
echo "std-test-runner gate OK"
