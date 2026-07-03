#!/usr/bin/env bash
# C2 §5：native self-host 泛型类型实参数量诊断门禁
#
# 目标：验证 ./compiler/shux 在真实宿主上对 wrong_type_args.sx 给出 expects/got 诊断。
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh
# shellcheck source=tests/lib/ci-host.sh
source tests/lib/ci-host.sh

SHU="${SHUX_C2_BIN:-./compiler/shux}"
SRC="tests/generic/wrong_type_args.sx"

[ -f "$SRC" ] || { gate_progress "FAIL: missing $SRC"; exit 1; }
[ -x "$SHU" ] || { gate_progress "FAIL: missing compiler $SHU"; exit 1; }
if ! ci_native_shu "$SHU"; then
  gate_progress "typeck-generic-args-gate SKIP (no native shux)"
  exit 0
fi

set +e
ERR=$("$SHU" -L . "$SRC" 2>&1)
EC=$?
set -e

if [ "$EC" -eq 0 ]; then
  echo "$ERR" >&2
  gate_progress "FAIL: wrong_type_args unexpectedly succeeded"
  exit 1
fi

echo "$ERR" | grep -q "generic function 'id' expects 1 type arguments, got 2" || {
  echo "$ERR" >&2
  gate_progress "FAIL: missing expects/got generic diagnostic"
  exit 1
}

echo "$ERR" | grep -q "4:26" || {
  echo "$ERR" >&2
  gate_progress "FAIL: missing source location for generic diagnostic"
  exit 1
}

gate_progress "typeck-generic-args-gate OK (native self-host generic expects/got diagnostic)"
