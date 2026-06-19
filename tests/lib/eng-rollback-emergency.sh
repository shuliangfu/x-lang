#!/usr/bin/env bash
# eng-rollback-emergency.sh — ENG-006 共享：SLA、playbook 锚点、烟测 hook 存在性
#
# 用法（source 后）：
#   eng_rollback_prefix
#   eng_rollback_sla_minutes
#   eng_rollback_smoke_hook_ok run-portable-suite.sh

# 演练/门禁 stderr 前缀。
eng_rollback_prefix() {
  echo "shux: [SHUX_ROLLBACK_DRILL]"
}

# 回滚 SLA 总预算（分钟）。
eng_rollback_sla_minutes() {
  echo "${SHUX_ROLLBACK_SLA_MINUTES:-30}"
}

# 烟测 hook 脚本存在且可执行路径检查（相对 tests/）。
eng_rollback_smoke_hook_ok() {
  local script="$1"
  local path="tests/$script"
  [ -n "$script" ] && [ -f "$path" ]
}

# playbook 须含 R1/R2/R3 与烟测章节锚点。
eng_rollback_playbook_ok() {
  local pb="${1:-tests/templates/eng-rollback-playbook.txt}"
  [ -f "$pb" ] || return 1
  grep -qF 'R1 — tag' "$pb" || return 1
  grep -qF 'R2 — main' "$pb" || return 1
  grep -qF 'R3 — baseline' "$pb" || return 1
  grep -qF '烟测' "$pb" || return 1
  return 0
}

# 列出最近 N 个 v* tag（供演练输出；无 tag 不失败）。
eng_rollback_list_recent_tags() {
  local n="${1:-5}"
  git tag -l 'v*' --sort=-v:refname 2>/dev/null | head -n "$n"
}
