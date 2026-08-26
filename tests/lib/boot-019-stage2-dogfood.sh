#!/usr/bin/env bash
# boot-019-stage2-dogfood.sh — BOOT-019: Stage2 parser/typeck dogfood helpers
#
# Usage (after source):
#   boot019_check_one XLANG tests/parser/two_functions.x
#   boot019_link_run_one XLANG tests/option/main.x OUT_PATH [EXPECTED_EXIT]
#   boot019_expected_exit tests/option/main.x  # smoke exit contract
#   boot019_emit_report status check_ok link_ok skip
#
# honesty 2026-08-26: report fields check=/link=/skip=; check observational
# at gate; link+run hard (6/6). PLATFORM: SHARED archaeology.

BOOT019_PREFIX="${XLANG_BOOT019_PREFIX:-xlang: [XLANG_BOOT019]}"

# Run xlang check on one .x; return 1 on failure.
# Observational at gate (check paused 2026-08-05); callers may soft-note.
boot019_check_one() {
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

# Return the contracted process exit code for a smoke src
# (aligned with run-option / run-result / run-generic).
boot019_expected_exit() {
  case "$1" in
    tests/parser/binary_expr_return.x) echo 3 ;;
    tests/option/main.x) echo 102 ;;
    tests/result/main.x) echo 173 ;;
    tests/generic/main.x) echo 42 ;;
    *) echo 0 ;;
  esac
}

# Try -o link and run; 0=ok, 2=link fail, 1=run exit mismatch.
boot019_link_run_one() {
  local xlang="$1"
  local src="$2"
  local out="$3"
  local expect="${4:-0}"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$out" >/dev/null 2>&1; then
    return 2
  fi
  local ex=0
  "$out" >/dev/null 2>&1 || ex=$?
  if [ "$ex" -ne "$expect" ]; then
    echo "boot-019 FAIL: $src run exit=$ex (expected $expect)" >&2
    return 1
  fi
  return 0
}

# Emit structured report line: check=/link=/skip=.
boot019_emit_report() {
  local status="$1"
  local check_ok="$2"
  local link_ok="$3"
  local skip="$4"
  echo "${BOOT019_PREFIX} status=${status} check=${check_ok} link=${link_ok} skip=${skip}"
}
