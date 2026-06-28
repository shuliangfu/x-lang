#!/usr/bin/env bash
# bootstrap-symbol-visibility.sh — V7：bootstrap 中间产物符号可见性审计
#
# 说明：完整 shux_asm / stage1 作为编译器单体**必然**导出 pipeline_/typeck_；
# 本脚本严格检查 **partial seed .o** 与 **import_alias.c** 过渡桩，防止跨代劫持。
#
# 用法（source 后）：
#   bootstrap_symbol_visibility_check_partial <path.o>
#   bootstrap_symbol_visibility_check_import_alias <path.c>

# partial seed .o：全局符号须在白名单内（seed_mega、backend T 符号等）。
bootstrap_symbol_visibility_check_partial() {
  local obj="$1"
  if [ ! -f "$obj" ]; then
    echo "bootstrap-symbol-visibility SKIP partial: missing $obj" >&2
    return 0
  fi
  if ! command -v nm >/dev/null 2>&1; then
    echo "bootstrap-symbol-visibility SKIP partial: no nm" >&2
    return 0
  fi
  local wl="${SHUX_SYM_VIS_PARTIAL_WL:-seed_mega|asm_|shux_|backend_|platform_elf_}"
  local bad
  bad="$(nm -g --defined-only "$obj" 2>/dev/null \
    | grep -E ' typeck_| pipeline_' \
    | grep -vE "$wl" || true)"
  if [ -n "$bad" ]; then
    echo "bootstrap-symbol-visibility FAIL partial $obj:" >&2
    echo "$bad" >&2
    return 1
  fi
  echo "bootstrap-symbol-visibility OK partial $obj"
  return 0
}

# import_alias.c：实现须 static，仅 std_* / shux_* 前缀导出。
bootstrap_symbol_visibility_check_import_alias() {
  local cfile="$1"
  if [ ! -f "$cfile" ]; then
    echo "bootstrap-symbol-visibility SKIP alias: missing $cfile" >&2
    return 0
  fi
  if grep -E '^[^/]*\b(typeck_|pipeline_)[a-zA-Z0-9_]+\s*\(' "$cfile" 2>/dev/null | grep -qv static; then
    echo "bootstrap-symbol-visibility FAIL: non-static typeck_/pipeline_ in $cfile" >&2
    return 1
  fi
  echo "bootstrap-symbol-visibility OK alias $(basename "$cfile")"
  return 0
}

# 完整二进制：仅统计/告警，默认不 FAIL（键 C 前人工审计用）。
bootstrap_symbol_visibility_audit_binary() {
  local bin="$1"
  if [ ! -f "$bin" ]; then
    echo "bootstrap-symbol-visibility SKIP binary: missing $bin" >&2
    return 0
  fi
  if ! command -v nm >/dev/null 2>&1; then
    return 0
  fi
  local n
  n="$(nm -g --defined-only "$bin" 2>/dev/null | grep -cE ' typeck_| pipeline_' || true)"
  echo "bootstrap-symbol-visibility INFO $bin: typeck_/pipeline_ globals=$n"
  if [ "${SHUX_SYM_VIS_STRICT:-0}" = "1" ] && [ "$n" -gt 0 ]; then
    echo "bootstrap-symbol-visibility FAIL strict: $bin has $n internal globals" >&2
    return 1
  fi
  return 0
}
