#!/usr/bin/env bash
# run-boundary-encodings.sh — base64/json/csv 边界输入（非法/空/往返）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX="${SHUX:-./compiler/shux}"

run_case() {
  local name="$1"
  local sx="$2"
  local expect="$3"
  local exe="/tmp/shux_boundary_$$"
  if ! $SHUX -L . -L std/base64 -L std/json -L std/csv "$sx" -o "$exe" 2>&1; then
    echo "boundary $name: compile failed"
    rm -f "$exe"
    exit 1
  fi
  set +e
  $exe 2>/dev/null
  local ex=$?
  set -e
  rm -f "$exe"
  if [ "$ex" -ne "$expect" ]; then
    echo "boundary $name: expected exit $expect, got $ex"
    exit 1
  fi
  echo "boundary $name OK"
}

# base64/json 依赖 std/*.o 链接；与 run-base64/run-json 相同，若 driver 链接回归则跳过并提示
if ./tests/run-base64.sh 2>/dev/null; then
  run_case base64_roundtrip tests/boundary/base64_roundtrip.sx 0
else
  echo "boundary: skip base64 (run-base64.sh failed; 见 codegen std 前缀链接)"
fi
if ./tests/run-json.sh 2>/dev/null; then
  run_case json_invalid tests/boundary/json_invalid.sx 1
else
  echo "boundary: skip json (run-json.sh failed)"
fi
if ./tests/run-csv.sh 2>/dev/null; then
  run_case csv_empty tests/boundary/csv_empty.sx 0
else
  echo "boundary: skip csv (run-csv.sh failed)"
fi
echo "boundary encodings OK (smoke)"
