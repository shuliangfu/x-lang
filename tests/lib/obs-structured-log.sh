#!/usr/bin/env bash
# obs-structured-log.sh — OBS-003 共享：结构化/bracket 日志行校验
#
# 用法（source 后）：
#   obs_struct_log_line_valid 'shu: level=info component=x event=1'
#   obs_struct_log_bracket_valid 'shu: [SHU_COMPILE_PHASE_TIMING] parse_ms=1'

# 校验 `shu: level=L component=C …` 结构化行。
obs_struct_log_line_valid() {
  local line="$1"
  echo "$line" | grep -qE '^shu: level=(debug|info|warn|error) component=[A-Za-z0-9_.]+ .+'
}

# 校验 `shu: [COMPONENT] kv…` 遗留行。
obs_struct_log_bracket_valid() {
  local line="$1"
  echo "$line" | grep -qE '^shu: \[[A-Z0-9_]+\] .+'
}
