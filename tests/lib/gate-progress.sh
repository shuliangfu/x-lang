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

# Bound a command by wall-clock seconds.
# PLATFORM: SHARED — Linux `timeout`, macOS Homebrew `gtimeout`, else Perl
# process-group kill (stock Perl on Darwin/Linux). Unbounded pass-through
# only when none exist. Exit 124 mirrors GNU timeout (callers treat as timeout).
# G.7: single authority for gate timeouts — extend here; do not fork helpers.
gate_run_timeout() {
  local secs="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=15 "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout --signal=TERM --kill-after=15 "$secs" "$@"
  elif command -v perl >/dev/null 2>&1; then
    # Fork + process-group kill: plain `alarm; exec` leaves grandchildren
    # (e.g. hung xlang_asm under a hook) alive on Darwin after SIGALRM.
    perl -e '
      use strict;
      use warnings;
      my $secs = shift @ARGV;
      my $pid = fork();
      die "fork: $!\n" unless defined $pid;
      if ($pid == 0) {
        setpgrp(0, 0);
        exec @ARGV;
        exit 127;
      }
      local $SIG{ALRM} = sub {
        kill "TERM", -$pid;
        sleep 1;
        kill "KILL", -$pid;
        waitpid($pid, 0);
        exit 124;
      };
      alarm $secs;
      waitpid($pid, 0);
      my $status = $?;
      alarm 0;
      if ($status & 127) {
        my $sig = $status & 127;
        exit 124 if $sig == 14 || $sig == 15 || $sig == 9;
        exit $sig;
      }
      exit($status >> 8);
    ' "$secs" "$@"
  else
    gate_progress "WARN: no timeout/gtimeout/perl; unbounded: $*"
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
  local logf="/tmp/xlang_gate_hb_$$.log"
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
