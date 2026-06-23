#!/usr/bin/env bash
# progress-run.sh — 长命令实时 progress + tee 包装（阶段 G phase0-stream）
#
# 用法：
#   ./tests/lib/progress-run.sh <label> <logfile> -- <command...>
#   ./tests/lib/progress-run.sh "L1 bstrict" /tmp/bstrict.log -- make -C compiler bootstrap-driver-bstrict
#
# 环境：
#   SHUX_PROGRESS_QUIET=1 — 不打印子命令 stdout（仍写入 log）
#   SHUX_PROGRESS_EST=... — 可选预计耗时提示（仅展示）
#   SHUX_PROGRESS_TIMEOUT_SEC=N — 可选超时秒数（依赖宿主 timeout/gtimeout；124=超时）

set -euo pipefail

if [ "$#" -lt 4 ] || [ "${3:-}" != "--" ]; then
  echo "usage: $0 <label> <logfile> -- <command...>" >&2
  exit 2
fi

LABEL="$1"
LOG="$2"
shift 3

progress() {
  echo "[$(date +%H:%M:%S)] $*"
}

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
: >"$LOG"

progress "START $LABEL"
if [ -n "${SHUX_PROGRESS_EST:-}" ]; then
  progress "EST $SHUX_PROGRESS_EST"
fi
progress "CMD $*"
progress "LOG $LOG"

# 可选超时：124 表示 timeout(1) 杀进程。
run_cmd() {
  if [ "${SHUX_PROGRESS_QUIET:-0}" = "1" ]; then
    stdbuf -oL -eL "$@" >>"$LOG" 2>&1
  else
    stdbuf -oL -eL "$@" 2>&1 | tee -a "$LOG"
  fi
  return "${PIPESTATUS[0]}"
}

progress_timeout_cmd() {
  local to="${SHUX_PROGRESS_TIMEOUT_SEC:-}"
  local timeout_bin=""
  if [ -n "$to" ] && [ "$to" != "0" ]; then
    if command -v timeout >/dev/null 2>&1; then
      timeout_bin=timeout
    elif command -v gtimeout >/dev/null 2>&1; then
      timeout_bin=gtimeout
    fi
    if [ -n "$timeout_bin" ]; then
      progress "TIMEOUT ${to}s"
      run_cmd "$timeout_bin" "$to" "$@"
      return $?
    fi
    progress "WARN timeout unavailable; SHUX_PROGRESS_TIMEOUT_SEC ignored"
  fi
  run_cmd "$@"
}

set +e
progress_timeout_cmd "$@"
RC=$?
set -e

if [ "$RC" -eq 0 ]; then
  progress "OK $LABEL (exit 0)"
elif [ "$RC" -eq 124 ]; then
  progress "TIMEOUT $LABEL (exit 124)"
else
  progress "FAIL $LABEL (exit $RC)"
fi
exit "$RC"
