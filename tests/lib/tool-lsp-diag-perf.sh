#!/usr/bin/env bash
# tool-lsp-diag-perf.sh — TOOL-004 共享：LSP 大文件诊断性能辅助
#
# 用法（source 后）：
#   tool_lsp_send_frame BODY
#   tool_lsp_count_funcs SU_FILE
#   tool_lsp_count_completion_items OUT_FILE
#   tool_lsp_ms_now

# 发送单条 LSP 消息帧。
tool_lsp_send_frame() {
  local body="$1"
  local len
  len=$(printf '%s' "$body" | wc -c | tr -d ' \n')
  printf 'Content-Length: %d\r\n\r\n%s' "$len" "$body"
}

# 统计 .su 文件中顶层 function 声明数（粗匹配 `function name`）。
tool_lsp_count_funcs() {
  local f="$1"
  grep -cE '^function [A-Za-z_][A-Za-z0-9_]*\(' "$f" 2>/dev/null || echo 0
}

# 统计 completion 响应中 CompletionItem 条数。
tool_lsp_count_completion_items() {
  local out_file="$1"
  grep -o '"label":' "$out_file" 2>/dev/null | wc -l | tr -d ' \n'
}

# 返回毫秒时间戳（python3 perf_counter * 1000）。
tool_lsp_ms_now() {
  python3 -c 'import time; print(int(time.perf_counter()*1000))'
}

# manifest 中 opts 行数。
tool_lsp_opt_count() {
  local man="${1:-tests/baseline/tool-lsp-diag-perf.tsv}"
  awk -F'\t' '$2=="opts" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}
