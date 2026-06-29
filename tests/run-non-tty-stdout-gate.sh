#!/usr/bin/env bash
# C9 §5：非 TTY stdout 重定向下，shux 顶层 import 编译不应挂起。
#
# 目标：覆盖 shux -> sibling shux-c 委托路径，防止 argv[0] 仍是 shux 导致递归 fork/exec。
# 说明：该 gate 只要求“非 TTY 下不 timeout / 不被 SIGTERM 杀掉”；编译可成功也可正常报错退出。
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

SHU="${SHUX_C9_BIN:-./compiler/shux}"
TIMEOUT_SEC="${SHUX_C9_TIMEOUT:-20}"
TMP_SX="/tmp/shux_c9_non_tty_$$.sx"
TMP_OUT="/tmp/shux_c9_non_tty_$$.o"
TMP_LOG="/tmp/shux_c9_non_tty_$$.log"

[ -x "$SHU" ] || { gate_progress "FAIL: missing compiler $SHU"; exit 1; }

cleanup() {
  rm -f "$TMP_SX" "$TMP_OUT" "$TMP_LOG"
}
trap cleanup EXIT

cat > "$TMP_SX" <<'EOF'
const path = import("std.path");
function main(): i32 { return 0; }
EOF

set +e
timeout "$TIMEOUT_SEC" "$SHU" -L . "$TMP_SX" -o "$TMP_OUT" >"$TMP_LOG" 2>&1
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
