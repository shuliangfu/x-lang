#!/usr/bin/env bash
# safe-crash.sh — SAFE-007 shared helpers (honesty soft→硬绿).
#
# Usage (source):
#   safe_crash_emit_report status run obs skip
#   safe_crash_grep_evidence logfile
# PLATFORM: SHARED archaeology.

SAFE_CRASH_PREFIX="${XLANG_CRASH_EVIDENCE_PREFIX:-xlang: [XLANG_CRASH_EVIDENCE]}"

# Emit structured gate report line (OBS-003 bracket compatible).
safe_crash_emit_report() {
  local status="$1"
  local run="${2:-0}"
  local obs="${3:-0}"
  local skip="${4:-0}"
  echo "${SAFE_CRASH_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip}"
}

# Log must contain XLANG_CRASH_EVIDENCE summary line.
safe_crash_grep_evidence() {
  local log="$1"
  grep -qF 'xlang: [XLANG_CRASH_EVIDENCE]' "$log" 2>/dev/null
}
