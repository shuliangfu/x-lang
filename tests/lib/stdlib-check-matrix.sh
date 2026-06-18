#!/usr/bin/env bash
# stdlib-check-matrix.sh — BOOT-013：单模块 shu check 辅助
#
# 用法（source 后）：
#   stdlib_cm_resolve_shu
#   stdlib_cm_check_module SHU mod_name
#   stdlib_cm_emit_report status core_ok std_ok fail skip

STDLIB_CM_PREFIX="${SHU_STDLIB_CHECK_PREFIX:-shu: [SHU_STDLIB_CHECK]}"

# 判断 shu 是否可在本机执行（避免 Linux ELF 在 macOS 上误判）。
stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 解析 typeck 用 shu（优先本机可执行的 shu-c）。
stdlib_cm_resolve_shu() {
  local cand
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  if [ -n "${SHU:-}" ] && stdlib_cm_native_shu "$SHU"; then
    echo "$SHU"
    return 0
  fi
  return 1
}

# 对单个模块跑 check；成功 0，失败 1。
stdlib_cm_check_module() {
  local shu="$1"
  local mod="$2"
  local safe="${mod//./_}"
  local tmp="/tmp/shu_stdlib_cm_${safe}_$$.su"
  cat >"$tmp" <<EOF
// BOOT-013 auto check probe for ${mod}
const _m = import("${mod}");
function main(): i32 {
  return 0;
}
EOF
  if ! "$shu" check -L . "$tmp" >/dev/null 2>&1; then
    "$shu" check -L . "$tmp" 2>&1 | tail -6 >&2 || true
    rm -f "$tmp"
    return 1
  fi
  rm -f "$tmp"
  return 0
}

# 输出结构化 check 矩阵报告行。
stdlib_cm_emit_report() {
  local status="$1"
  local core_ok="$2"
  local std_ok="$3"
  local fail="$4"
  local skip="$5"
  echo "${STDLIB_CM_PREFIX} status=${status} core=${core_ok} std=${std_ok} fail=${fail} skip=${skip}"
}
