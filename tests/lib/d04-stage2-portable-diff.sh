#!/usr/bin/env bash
# d04-stage2-portable-diff.sh — D-04：Stage1/Stage2 portable 子集两代 diff 辅助
#
# 用法（source 后）：
#   d04_stage_binaries_ready
#   d04_outcome_check SHUX src
#   d04_outcome_link_run SHUX src expect_exit case_id
#   d04_emit_report status cases_ok cases_fail skip

D04_PREFIX="${SHUX_D04_PREFIX:-shux: [SHUX_D04]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")"
# shellcheck source=tests/lib/boot-019-stage2-dogfood.sh
. "$_LIB_DIR/boot-019-stage2-dogfood.sh"
# shellcheck source=tests/lib/comp-riscv64.sh
. "$_LIB_DIR/comp-riscv64.sh"

# 链接回退 shux-c（与 BOOT-019/015 runner 一致）。
d04_export_link_shux_if_needed() {
  if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
    if [ -x ./compiler/shux-c ]; then
      export SHUX_LINK_SHUX=./compiler/shux-c
    fi
  fi
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) ;;
    *)
      if [ -x ./compiler/shux-c ]; then
        export SHUX_LINK_SHUX=./compiler/shux-c
      fi
      ;;
  esac
}

# 判断 stage1/stage2 是否可用于两代 diff（Linux native ELF）。
d04_stage_binaries_ready() {
  local s1="${SHUX_D04_STAGE1:-compiler/shux_asm_stage1}"
  local s2="${SHUX_D04_STAGE2:-compiler/shux_asm2}"
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "$s1" ] && [ -x "$s2" ] || return 1
  comp_riscv64_native_shu "$s1" || return 1
  comp_riscv64_native_shu "$s2" || return 1
  return 0
}

# 对单个 .x 跑 check，输出稳定 outcome 标签：check:pass | check:fail。
d04_outcome_check() {
  local shux="$1"
  local src="$2"
  if boot019_check_one "$shux" "$src"; then
    echo "check:pass"
  else
    echo "check:fail"
  fi
}

# 对单个 .x 跑 link+run，输出：link:ok:EXIT | link:skip | link:fail:CODE。
d04_outcome_link_run() {
  local shux="$1"
  local src="$2"
  local expect="${3:-0}"
  local case_id="${4:-d04}"
  local out="${TESTS_OUT_DIR:-tests/.out}/d04_${case_id}_$$"
  mkdir -p "$(dirname "$out")"
  local lr=0
  boot019_link_run_one "$shux" "$src" "$out" "$expect" || lr=$?
  case "$lr" in
    0) echo "link:ok:${expect}" ;;
    2) echo "link:skip" ;;
    *) echo "link:fail:${lr}" ;;
  esac
  rm -f "$out" 2>/dev/null || true
}

# 输出结构化报告行。
d04_emit_report() {
  local status="$1"
  local cases_ok="$2"
  local cases_fail="$3"
  local skip="$4"
  echo "${D04_PREFIX} status=${status} cases_ok=${cases_ok} cases_fail=${cases_fail} skip=${skip}"
}
