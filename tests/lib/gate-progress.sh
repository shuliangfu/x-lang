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
        # ALRM/TERM = our bound (alarm handler already exit 124).
        # SIGKILL from outside (Darwin jetsam / OOM) is not a timeout —
        # 137 matches shells (128+9). Do not report Killed:9 as timeout.
        exit 124 if $sig == 14 || $sig == 15;
        exit 137 if $sig == 9;
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

# ---------------------------------------------------------------------------
# Intra-script case pool (bash 3.2 portable; no wait -n).
#
# PLATFORM: SHARED — default serial. Darwin auto-uses 2 when the outer
# XLANG_BSTRICT_JOBS pool is 1 or 2, so 45-case asm gates drop ~840s → ~420s.
# When outer JOBS>=4, auto inner=1 so total concurrent xlang_asm stays ≤4.
# Explicit XLANG_GATE_CASE_JOBS always wins (capped at 4).
#
# G.7: single authority for gate case parallelism — extend here; do not
# fork a second pool helper. Callers: source this file, then
#   gate_case_pool_begin
#   gate_case_submit run_case tag src ...
#   gate_case_pool_finish || die "case pool failed"
# jobs=1 path is a straight call (parent RUN_OK still works).
# ---------------------------------------------------------------------------
_GATE_CASE_JOBS=1
_GATE_CASE_PIDS=""
_GATE_CASE_RUNNING=0
_GATE_CASE_DIR=""
_GATE_CASE_FAIL=0

gate_case_jobs() {
  local inner outer cap
  outer="${XLANG_BSTRICT_JOBS:-1}"
  case "$outer" in
    ''|*[!0-9]*) outer=1 ;;
  esac
  if [ "$outer" -lt 1 ]; then
    outer=1
  fi

  if [ -n "${XLANG_GATE_CASE_JOBS:-}" ]; then
    inner="$XLANG_GATE_CASE_JOBS"
  else
    inner=1
    case "$(uname -s 2>/dev/null)" in
      Darwin)
        # PLATFORM: MACOS — 18-core/64GB: overlap 45 serial -o inside one script
        # when the outer bstrict pool is small. Outer JOBS>=4 already saturates.
        if [ "$outer" -le 2 ]; then
          inner=2
        fi
        ;;
    esac
  fi
  case "$inner" in
    ''|*[!0-9]*) inner=1 ;;
  esac
  if [ "$inner" -lt 1 ]; then
    inner=1
  fi
  if [ "$inner" -gt 4 ]; then
    inner=4
  fi

  if [ -z "${XLANG_GATE_CASE_JOBS:-}" ]; then
    cap=4
    if [ $((outer * inner)) -gt "$cap" ]; then
      inner=$((cap / outer))
      if [ "$inner" -lt 1 ]; then
        inner=1
      fi
    fi
  fi
  echo "$inner"
}

gate_case_pool_begin() {
  _GATE_CASE_JOBS="$(gate_case_jobs)"
  _GATE_CASE_PIDS=""
  _GATE_CASE_RUNNING=0
  _GATE_CASE_FAIL=0
  _GATE_CASE_DIR=""
  if [ "$_GATE_CASE_JOBS" -gt 1 ]; then
    _GATE_CASE_DIR="$(mktemp -d /tmp/xlang_gate_case.XXXXXX)"
    echo "gate-progress: CASE_JOBS=${_GATE_CASE_JOBS} dir=${_GATE_CASE_DIR}"
  fi
}

_gate_case_reap() {
  local p new_pids w
  new_pids=""
  _GATE_CASE_RUNNING=0
  for p in $_GATE_CASE_PIDS; do
    if kill -0 "$p" 2>/dev/null; then
      new_pids="${new_pids} ${p}"
      _GATE_CASE_RUNNING=$((_GATE_CASE_RUNNING + 1))
    else
      set +e
      wait "$p"
      w=$?
      set -e
      if [ "$w" -ne 0 ]; then
        _GATE_CASE_FAIL=1
      fi
    fi
  done
  _GATE_CASE_PIDS="$new_pids"
}

gate_case_submit() {
  if [ "$_GATE_CASE_JOBS" -le 1 ]; then
    "$@"
    return $?
  fi
  while [ "$_GATE_CASE_RUNNING" -ge "$_GATE_CASE_JOBS" ]; do
    _gate_case_reap
    if [ "$_GATE_CASE_FAIL" -ne 0 ]; then
      return 1
    fi
    if [ "$_GATE_CASE_RUNNING" -ge "$_GATE_CASE_JOBS" ]; then
      sleep 0.2
    fi
  done
  (
    set +e
    "$@"
    ec=$?
    if [ "$ec" -eq 0 ]; then
      echo ok >"${_GATE_CASE_DIR}/ok.${2:-x}.$$"
      exit 0
    fi
    echo fail >"${_GATE_CASE_DIR}/fail.${2:-x}.$$"
    exit "$ec"
  ) &
  _GATE_CASE_PIDS="${_GATE_CASE_PIDS} $!"
  _GATE_CASE_RUNNING=$((_GATE_CASE_RUNNING + 1))
  return 0
}

gate_case_pool_finish() {
  local p w n_ok
  if [ "$_GATE_CASE_JOBS" -le 1 ]; then
    return 0
  fi
  for p in $_GATE_CASE_PIDS; do
    set +e
    wait "$p"
    w=$?
    set -e
    if [ "$w" -ne 0 ]; then
      _GATE_CASE_FAIL=1
    fi
  done
  _GATE_CASE_PIDS=""
  _GATE_CASE_RUNNING=0
  n_ok=0
  if [ -n "$_GATE_CASE_DIR" ] && [ -d "$_GATE_CASE_DIR" ]; then
    n_ok=$(ls -1 "$_GATE_CASE_DIR"/ok.* 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "$_GATE_CASE_DIR"
  fi
  _GATE_CASE_DIR=""
  # Parent RUN_OK was not updated in subshells; report submitted successes.
  if [ -n "$n_ok" ] && [ "$n_ok" -gt 0 ]; then
    RUN_OK="$n_ok"
  fi
  if [ "$_GATE_CASE_FAIL" -ne 0 ]; then
    return 1
  fi
  return 0
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
