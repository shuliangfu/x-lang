#!/usr/bin/env bash
# 测试 core.fmt（fmt_i32、usize/isize/指针 *_to_buf）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

$RUN_SHUX -L . tests/fmt/main.sx -o /tmp/shux_fmt 2>&1
exitcode=0
/tmp/shux_fmt >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -eq 42 ] || { echo "run-fmt FAIL: expected exit 42 (fmt_i32(42)), got $exitcode"; exit 1; }
echo "fmt test OK"
