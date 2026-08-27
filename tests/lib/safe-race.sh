#!/usr/bin/env bash
# safe-race.sh — SAFE-006 shared helpers (honesty soft→硬绿).
#
# Usage (source):
#   safe_race_tsan_ok
#   safe_race_run_x XLANG_BIN src tag
#   safe_race_run_probe
#   safe_race_emit_report status run obs skip
# PLATFORM: SHARED product -o; LINUX TSAN probe experimental.

SAFE_RACE_PREFIX="${XLANG_RACE_DETECT_PREFIX:-xlang: [XLANG_RACE_DETECT]}"

# Detect whether cc supports -fsanitize=thread.
# PLATFORM: LINUX primary for TSAN; Darwin often N/A.
safe_race_tsan_ok() {
  local tmp="/tmp/xlang_race_tsan_probe_$$.c"
  local out="/tmp/xlang_race_tsan_probe_$$"
  cat >"$tmp" <<'EOF'
#include <pthread.h>
static void *f(void *a) { (void)a; return 0; }
int main(void) { pthread_t t; pthread_create(&t, 0, f, 0); pthread_join(t, 0); return 0; }
EOF
  if cc -fsanitize=thread -pthread "$tmp" -o "$out" 2>/dev/null; then
    if ! "$out" >/dev/null 2>&1; then
      rm -f "$tmp" "$out"
      return 1
    fi
    rm -f "$tmp" "$out"
    return 0
  fi
  rm -f "$tmp" "$out"
  return 1
}

# Compile and run positive .x case; expect exit 0.
safe_race_run_x() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-race}"
  local exe="/tmp/xlang_safe_race_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "safe-race FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "safe-race FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

# Intentional race probe; TSAN should detect (non-zero exit).
# Returns 0=ok, 1=fail, 2=skip (toolchain).
safe_race_run_probe() {
  local exe="/tmp/xlang_race_probe_$$"
  if ! cc -fsanitize=thread -pthread tests/safe/race_probe.c -o "$exe" 2>/dev/null; then
    echo "safe-race probe SKIP: compile" >&2
    return 2
  fi
  local ec=0
  TSAN_OPTIONS="${TSAN_OPTIONS:-halt_on_error=1:exitcode=66}" "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "safe-race probe OK (detected intentional race ec=$ec)"
    return 0
  fi
  echo "safe-race probe FAIL: intentional race not detected" >&2
  return 1
}

# Emit structured gate report line.
safe_race_emit_report() {
  local status="$1"
  local run="${2:-0}"
  local obs="${3:-0}"
  local skip="${4:-0}"
  echo "${SAFE_RACE_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip}"
}
