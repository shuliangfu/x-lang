#!/usr/bin/env bash
# std-sqlite.sh — STD-010 共享：API 校验与 typeck 烟测

STD_SQLITE_PREFIX="${SHUX_STD_SQLITE_PREFIX:-shux: [SHUX_STD_SQLITE]}"

# 检查 mod.sx 是否导出指定函数。
std_sqlite_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# 对草案 .sx 跑 shux check；失败返回 1。
std_sqlite_run_typeck() {
  local shux="$1"
  local src="$2"
  local tag="${3:-typeck}"
  if [ ! -f "$src" ]; then
    echo "std-sqlite FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" check -L . "$src" >/dev/null 2>&1; then
    "$shux" check -L . "$src" 2>&1 | tail -8 >&2 || true
    echo "std-sqlite FAIL: check $tag ($src)" >&2
    return 1
  fi
  return 0
}

# 输出结构化预研报告行。
std_sqlite_emit_report() {
  local status="$1"
  local apis="$2"
  local layers="$3"
  local typeck="$4"
  echo "${STD_SQLITE_PREFIX} status=${status} apis=${apis} layers=${layers} typeck=${typeck}"
}

# 判断本机能否直接执行给定 shux 二进制。
std_sqlite_native_shu() {
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

# 解析可用 shux；失败返回 1。
std_sqlite_resolve_shu() {
  if [ -n "${SHUX:-}" ] && std_sqlite_native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if std_sqlite_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}
