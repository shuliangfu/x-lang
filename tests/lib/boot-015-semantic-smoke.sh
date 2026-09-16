#!/usr/bin/env bash
# boot-015-semantic-smoke.sh — BOOT-015: vec/map/heap semantic smoke helpers
#
# Usage (after source):
#   boot015_check_one XLANG tests/vec/main.x
#   boot015_link_run_one XLANG tests/vec/main.x OUT_PATH
#   boot015_emit_report status run_ok obs skip
#
# honesty 2026-08-28: report fields run=/obs=/skip= (gate hard-green =
# product -o link+run); check is observational at gate (obs++).
# PLATFORM: SHARED archaeology.

BOOT015_PREFIX="${XLANG_BOOT015_PREFIX:-xlang: [XLANG_BOOT015]}"

# Run xlang check on one .x; return 1 on failure.
# Observational at gate (check paused 2026-08-05); callers count as obs.
boot015_check_one() {
  local xlang="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$xlang" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$xlang" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}

# Try -o link and run; 0=ok, 2=link fail, 1=run fail.
boot015_link_run_one() {
  local xlang="$1"
  local src="$2"
  local out="$3"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$out" >/dev/null 2>&1; then
    return 2
  fi
  local ex=0
  "$out" >/dev/null 2>&1 || ex=$?
  if [ "$ex" -ne 0 ]; then
    echo "boot-015 FAIL: $src run exit=$ex" >&2
    return 1
  fi
  return 0
}

# Emit structured report line: run=/obs=/skip=.
boot015_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${BOOT015_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
