#!/usr/bin/env bash
# BOOT-004：自举/编译失败日志 → 流水线阶段分类器
#
# 读取 tests/baseline/bootstrap-stage-patterns.tsv，对 log 文本匹配 regex，
# 输出 stage、建议 repro case_id，供 CI 与本地诊断使用。
#
# 用法：
#   ./tests/lib/bootstrap-stage-diag.sh /path/to/ci.log
#   ./tests/lib/bootstrap-stage-diag.sh --stdin < ci.log
#   cat ci.log | ./tests/lib/bootstrap-stage-diag.sh --stdin
#
# 输出（stdout，可 source）：
#   SHUX_BOOT_STAGE=parser
#   SHUX_BOOT_REPRO=parser_second_pass
#   SHUX_BOOT_PATTERN=ci_banner_parser_second
#   SHUX_BOOT_CONFIDENCE=classified
#
# 环境：
#   SHUX_BOOT_STAGE_PATTERNS — 覆盖模式表路径
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PATTERNS="${SHUX_BOOT_STAGE_PATTERNS:-$ROOT/tests/baseline/bootstrap-stage-patterns.tsv}"

read_log() {
  if [ "${1:-}" = "--stdin" ]; then
    cat
  elif [ -n "${1:-}" ] && [ -f "$1" ]; then
    cat "$1"
  elif [ -n "${1:-}" ]; then
    echo "bootstrap-stage-diag: not a file: $1" >&2
    return 1
  else
    echo "bootstrap-stage-diag: usage: $0 [--stdin | logfile]" >&2
    return 1
  fi
}

# 对整段 log 按 priority 选最优匹配（priority 越小越优先）。
bootstrap_stage_classify() {
  local log="$1"
  local best_prio=999999
  local best_stage=""
  local best_repro=""
  local best_pid=""

  while IFS=$'\t' read -r pid regex stage repro prio notes; do
    [ -z "${pid:-}" ] && continue
    case "$pid" in \#*) continue ;; esac
    [ -z "${regex:-}" ] && continue
    # shellcheck disable=SC1083
    if printf '%s' "$log" | grep -qE "$regex"; then
      local p="${prio:-999}"
      if [ "$p" -lt "$best_prio" ]; then
        best_prio="$p"
        best_stage="$stage"
        best_repro="$repro"
        best_pid="$pid"
      fi
    fi
  done < "$PATTERNS"

  if [ -n "$best_stage" ]; then
    echo "SHUX_BOOT_STAGE=$best_stage"
    echo "SHUX_BOOT_REPRO=$best_repro"
    echo "SHUX_BOOT_PATTERN=$best_pid"
    echo "SHUX_BOOT_CONFIDENCE=classified"
    echo "bootstrap-stage-diag: stage=$best_stage repro=$best_repro pattern=$best_pid" >&2
    return 0
  fi

  echo "SHUX_BOOT_STAGE=unknown"
  echo "SHUX_BOOT_REPRO=full_ci"
  echo "SHUX_BOOT_PATTERN="
  echo "SHUX_BOOT_CONFIDENCE=low"
  echo "bootstrap-stage-diag: no pattern match — try ./tests/run-bootstrap-repro.sh full_ci" >&2
  return 1
}

main() {
  if [ ! -f "$PATTERNS" ]; then
    echo "bootstrap-stage-diag FAIL: missing $PATTERNS" >&2
    return 1
  fi
  local log
  log="$(read_log "${1:-}")"
  bootstrap_stage_classify "$log"
}

# 被 source 时不自动执行。
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
