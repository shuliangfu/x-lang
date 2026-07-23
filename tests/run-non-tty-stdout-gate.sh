#!/usr/bin/env bash
# C9 §5：非 TTY stdout 重定向下，xlang 顶层 import 编译不应挂起。
#
# 目标：覆盖 xlang -> sibling xlang-c 委托路径，防止 argv[0] 仍是 xlang 导致递归 fork/exec。
# 说明：该 gate 只要求“非 TTY 下不 timeout / 不被 SIGTERM 杀掉”；编译可成功也可正常报错退出。
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

XLANG_COMPILER="${XLANG_C9_BIN:-./compiler/xlang}"
TIMEOUT_SEC="${XLANG_C9_TIMEOUT:-20}"
TMP_X="/tmp/xlang_c9_non_tty_$$.x"
TMP_OUT="/tmp/xlang_c9_non_tty_$$.o"
TMP_LOG="/tmp/xlang_c9_non_tty_$$.log"

[ -x "$XLANG_COMPILER" ] || { gate_progress "FAIL: missing compiler $XLANG_COMPILER"; exit 1; }

cleanup() {
  rm -f "$TMP_X" "$TMP_OUT" "$TMP_LOG"
}
trap cleanup EXIT

cat > "$TMP_X" <<'EOF'
const path = import("std.path");
function main(): i32 { return 0; }
EOF

set +e
timeout "$TIMEOUT_SEC" "$XLANG_COMPILER" -L . "$TMP_X" -o "$TMP_OUT" >"$TMP_LOG" 2>&1
ec=$?
set -e

case "$ec" in
  124|137|143)
    tail -40 "$TMP_LOG" >&2 || true
    gate_progress "FAIL: non-TTY stdout compile hung or was killed (rc=$ec)"
    exit 1
    ;;
esac

if [ ! -s "$TMP_LOG" ] && [ ! -e "$TMP_OUT" ]; then
  gate_progress "FAIL: compile returned rc=$ec but produced neither log nor output"
  exit 1
fi

gate_progress "non-tty-stdout-gate OK (rc=$ec; no timeout under redirected stdout)"
