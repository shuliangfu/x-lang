#!/usr/bin/env bash
# STD-145：std.test 统一 test runner 门禁
#
# 用法：./tests/run-std-test-runner-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-test-runner-v1.md"
MANIFEST="tests/baseline/std-test-runner-manifest.tsv"
MOD_SX="std/test/mod.sx"
TEST_SX="std/test/test.sx"
LIB="tests/lib/std-test-runner.sh"
SMOKE_SX="tests/std-test/runner_smoke.sx"

# shellcheck source=tests/lib/std-test-runner.sh
. "$LIB"

echo "=== STD-145: std.test runner manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$TEST_SX" "$SMOKE_SX" std/test/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-test-runner gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-145 runner_case runner_finish SHUX_TEST_SUMMARY; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-test-runner gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "runner_reset" std/test/README.md 2>/dev/null; then
  echo "std-test-runner gate FAIL: README missing runner_reset" >&2
  exit 1
fi

sym_miss="$(std_test_runner_symbols_ok "$MOD_SX" "$TEST_SX" "$MANIFEST" || true)"
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
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-test-runner gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_test_runner_emit_report "fail" 0 0
    exit 1
  fi
  if std_test_runner_run_smoke "$SHUX_BIN" "$SMOKE_SX" "$TEST_O"; then
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
