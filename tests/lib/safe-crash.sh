#!/usr/bin/env bash
# safe-crash.sh — SAFE-007 共享：崩溃证据包校验
#
# 用法（source 后）：
#   safe_crash_emit_report status bundle_path frames
#   safe_crash_grep_evidence logfile

SAFE_CRASH_PREFIX="${SHU_CRASH_EVIDENCE_PREFIX:-shu: [SHU_CRASH_EVIDENCE]}"

# 输出结构化证据报告行。
safe_crash_emit_report() {
  local status="$1"
  local bundle="${2:-}"
  local frames="${3:-0}"
  echo "${SAFE_CRASH_PREFIX} gate_status=${status} bundle=${bundle} frames=${frames}"
}

# 日志中须含 SHU_CRASH_EVIDENCE 摘要行。
safe_crash_grep_evidence() {
  local log="$1"
  grep -qF 'shu: [SHU_CRASH_EVIDENCE]' "$log" 2>/dev/null
}
