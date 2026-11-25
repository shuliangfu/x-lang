#!/usr/bin/env bash
# tip_cold_run_logged.sh — run a tip-cold/L4 script and append real L4_END_RC.
# Hard rule (2026-10-25): NEVER echo L4_END_RC=0 unconditionally.
# Usage: tip_cold_run_logged.sh <logfile> <script> [args...]
set -u
LOG="${1:?log}"; shift
SCRIPT="${1:?script}"; shift
: >"$LOG" 2>/dev/null || true
set +e
bash "$SCRIPT" "$@" >>"$LOG" 2>&1
rc=$?
set -e
echo "L4_END_RC=$rc" >>"$LOG"
exit "$rc"
