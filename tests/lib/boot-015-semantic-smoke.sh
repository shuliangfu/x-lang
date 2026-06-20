#!/usr/bin/env bash
# boot-015-semantic-smoke.sh — BOOT-015：vec/map/heap 语义自举 smoke 辅助
#
# 用法（source 后）：
#   boot015_check_one SHU tests/vec/main.sx
#   boot015_link_run_one SHU tests/vec/main.sx OUT_PATH
#   boot015_emit_report status check_ok link_ok skip

BOOT015_PREFIX="${SHUX_BOOT015_PREFIX:-shux: [SHUX_BOOT015]}"

# 对单个 .sx 跑 shux check；失败返回 1。
boot015_check_one() {
  local shux="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$shux" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$shux" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}

# 尝试 -o 链接并运行；成功返回 0，链接失败返回 2，运行失败返回 1。
boot015_link_run_one() {
  local shux="$1"
  local src="$2"
  local out="$3"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$out" >/dev/null 2>&1; then
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

# 输出结构化报告行。
boot015_emit_report() {
  local status="$1"
  local check_ok="$2"
  local link_ok="$3"
  local skip="$4"
  echo "${BOOT015_PREFIX} status=${status} check_ok=${check_ok} link_ok=${link_ok} skip=${skip}"
}
