#!/usr/bin/env bash
# gate-progress.sh — gate 实时进度输出（带时间戳，避免长时间无输出像卡住）
#
# 用法（source 后）：
#   gate_progress "message"
#   gate_progress_run "label" command arg1 arg2 ...
#   gate_run_timeout 120 command ...   # 有 timeout/gtimeout 时用，否则无界执行并 WARN

# 输出一行带时间戳的进度（立即 flush）。
gate_progress() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

# 带超时执行（Linux timeout / macOS gtimeout；均无则透传并 WARN）。
gate_run_timeout() {
  local secs="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$secs" "$@"
  else
    gate_progress "WARN: 无 timeout 命令，无界执行: $*"
    "$@"
  fi
}

# 执行命令并实时透传输出；失败返回命令 exit code。
gate_progress_run() {
  local label="$1"
  shift
  gate_progress "START: $label"
  set +e
  "$@" 2>&1
  local ec=$?
  set -e
  if [ "$ec" -eq 0 ]; then
    gate_progress "OK: $label"
  else
    gate_progress "FAIL($ec): $label" >&2
  fi
  return "$ec"
}

# 对可能很慢的步骤：命令 stdout/stderr 实时 tee 到终端，主线程每 interval 秒打心跳。
gate_progress_run_heartbeat() {
  local label="$1"
  local interval="${2:-15}"
  shift 2
  gate_progress "START: $label (live output + heartbeat every ${interval}s)"
  local logf="/tmp/shux_gate_hb_$$.log"
  : >"$logf"
  set +e
  # 勿 >>logf 后台吞输出：用 tee 同步刷终端，结束后再读 log 仅作备份。
  "$@" > >(tee "$logf") 2>&1 &
  local pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    sleep "$interval"
    if kill -0 "$pid" 2>/dev/null; then
      gate_progress "… still running: $label (pid=$pid)"
    fi
  done
  wait "$pid"
  local ec=$?
  set -e
  rm -f "$logf"
  if [ "$ec" -eq 0 ]; then
    gate_progress "OK: $label"
  else
    gate_progress "FAIL($ec): $label" >&2
  fi
  return "$ec"
}
