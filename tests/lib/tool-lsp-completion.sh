#!/usr/bin/env bash
# tool-lsp-completion.sh — TOOL-003 共享：LSP completion 烟测辅助
#
# 用法（source 后）：
#   tool_lsp_send_frame BODY          # 打印 Content-Length 帧
#   tool_lsp_completion_has_label OUT LABEL
#   tool_lsp_completion_count_items OUT

# 发送单条 LSP 消息帧（Content-Length + CRLF + body）。
tool_lsp_send_frame() {
  local body="$1"
  local len
  len=$(printf '%s' "$body" | wc -c | tr -d ' \n')
  printf 'Content-Length: %d\r\n\r\n%s' "$len" "$body"
}

# 校验 completion 响应 JSON 是否含指定 label。
tool_lsp_completion_has_label() {
  local out_file="$1"
  local label="$2"
  if ! grep -qF "\"label\":\"${label}\"" "$out_file" 2>/dev/null; then
    echo "tool-lsp-completion FAIL: missing label=${label}" >&2
    return 1
  fi
  return 0
}

# 粗算 CompletionItem 条数（按 "label": 出现次数）。
tool_lsp_completion_count_items() {
  local out_file="$1"
  grep -o '"label":' "$out_file" 2>/dev/null | wc -l | tr -d ' \n'
}

# 统计 manifest 中 tiers 行数。
tool_lsp_tier_count() {
  local man="${1:-tests/baseline/tool-lsp-completion.tsv}"
  awk -F'\t' '$2=="tiers" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 统计 manifest 中 expect 行数。
tool_lsp_expect_count() {
  local man="${1:-tests/baseline/tool-lsp-completion.tsv}"
  awk -F'\t' '$2=="expect" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}
