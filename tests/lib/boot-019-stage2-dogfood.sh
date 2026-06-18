#!/usr/bin/env bash
# boot-019-stage2-dogfood.sh — BOOT-019：Stage2 parser/typeck dogfood 辅助
#
# 用法（source 后）：
#   boot019_check_one SHU tests/parser/two_functions.su
#   boot019_link_run_one SHU tests/option/main.su OUT_PATH
#   boot019_emit_report status check_ok link_ok skip

BOOT019_PREFIX="${SHU_BOOT019_PREFIX:-shu: [SHU_BOOT019]}"

# 对单个 .su 跑 shu check；失败返回 1。
boot019_check_one() {
  local shu="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$shu" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$shu" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}

# 尝试 -o 链接并运行；成功返回 0，链接失败返回 2，运行失败返回 1。
boot019_link_run_one() {
  local shu="$1"
  local src="$2"
  local out="$3"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$out" >/dev/null 2>&1; then
    return 2
  fi
  local ex=0
  "$out" >/dev/null 2>&1 || ex=$?
  if [ "$ex" -ne 0 ]; then
    echo "boot-019 FAIL: $src run exit=$ex" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
boot019_emit_report() {
  local status="$1"
  local check_ok="$2"
  local link_ok="$3"
  local skip="$4"
  echo "${BOOT019_PREFIX} status=${status} check_ok=${check_ok} link_ok=${link_ok} skip=${skip}"
}
