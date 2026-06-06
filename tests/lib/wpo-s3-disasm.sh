#!/usr/bin/env bash
# wpo-s3-disasm.sh — WPO-S3：_main 反汇编基线（同/跨模块小 struct helper 应内联，main 无 call make_pair/sum_pair）。
# 用法：source tests/lib/wpo-s3-disasm.sh
#   wpo_s3_main_has_helper_calls /path/to/binary

# shellcheck source=tests/lib/wpo-main-disasm.sh
. "$(dirname "${BASH_SOURCE[0]}")/wpo-main-disasm.sh"

# _main 是否仍 call/bl 到 make_pair 与 sum_pair（回归探测：内联失败时仍为 1）。
wpo_s3_main_has_helper_calls() {
  local exe="$1"
  wpo_main_calls_pat "$exe" 'make_pair([^_a-zA-Z0-9]|$)|[[:space:]]make_pair([^_a-zA-Z0-9]|$)' \
    && wpo_main_calls_pat "$exe" 'sum_pair([^_a-zA-Z0-9]|$)|[[:space:]]sum_pair([^_a-zA-Z0-9]|$)'
}

# stack promotion 启用后期望：_main 不再 call 上述 helper（占位，待编译器实装后默认开启）。
wpo_s3_main_no_helper_calls() {
  local exe="$1"
  wpo_main_no_calls_pat "$exe" 'make_pair|sum_pair'
}
