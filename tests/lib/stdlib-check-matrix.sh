#!/usr/bin/env bash
# stdlib-check-matrix.sh — BOOT-013：单模块 shux check 辅助
#
# 用法（source 后）：
#   stdlib_cm_resolve_shu
#   stdlib_cm_check_module SHUX mod_name
#   stdlib_cm_emit_report status core_ok std_ok fail skip

STDLIB_CM_PREFIX="${SHUX_STDLIB_CHECK_PREFIX:-shux: [SHUX_STDLIB_CHECK]}"

# 将模块名解析为物理 mod.sx 路径（std.db.sqlite → std/db/sqlite/mod.sx）。
stdlib_cm_mod_to_path() {
  local mod="$1"
  local layer="$2"
  local rel
  rel=$(printf '%s' "${mod#${layer}.}" | tr '.' '/')
  echo "${layer}/${rel}/mod.sx"
}

# 判断 shux 是否可在本机执行（避免 Linux ELF 在 macOS 上误判）。
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

# 解析 typeck 用 shux（优先本机可执行的 shux-c）。
stdlib_cm_resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  if [ -n "${SHUX:-}" ] && stdlib_cm_native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  return 1
}

# 对单个模块跑 check；成功 0，失败 1。
stdlib_cm_check_module() {
  local shux="$1"
  local mod="$2"
  local safe="${mod//./_}"
  local tmp="/tmp/shux_stdlib_cm_${safe}_$$.sx"
  cat >"$tmp" <<EOF
// BOOT-013 auto check probe for ${mod}
const _m = import("${mod}");
function main(): i32 {
  return 0;
}
EOF
  if ! "$shux" check -L . "$tmp" >/dev/null 2>&1; then
    "$shux" check -L . "$tmp" 2>&1 | tail -6 >&2 || true
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
