#!/usr/bin/env bash
# safe-race.sh — SAFE-006 共享：TSAN 探测器与正例烟测辅助
#
# 用法（source 后）：
#   safe_race_tsan_ok
#   safe_race_run_x SHUX_BIN src tag
#   safe_race_run_probe
#   safe_race_emit_report status cases_ok cases_fail probe_status

SAFE_RACE_PREFIX="${SHUX_RACE_DETECT_PREFIX:-shux: [SHUX_RACE_DETECT]}"

# 检测 cc 是否支持 -fsanitize=thread。
safe_race_tsan_ok() {
  local tmp="/tmp/shux_race_tsan_probe_$$.c"
  local out="/tmp/shux_race_tsan_probe_$$"
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

# 编译并运行正例 .x；期望退出码 0。
safe_race_run_x() {
  local shux="$1"
  local src="$2"
  local tag="${3:-race}"
  local exe="/tmp/shux_safe_race_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "safe-race FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shux" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
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

# 运行故意竞争 probe；TSAN 应检出（非 0 退出）。
safe_race_run_probe() {
  local exe="/tmp/shux_race_probe_$$"
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

# 输出结构化实验线报告行。
safe_race_emit_report() {
  local status="$1"
  local cases_ok="$2"
  local cases_fail="$3"
  local probe_status="$4"
  echo "${SAFE_RACE_PREFIX} status=${status} cases_ok=${cases_ok} cases_fail=${cases_fail} probe=${probe_status}"
}
