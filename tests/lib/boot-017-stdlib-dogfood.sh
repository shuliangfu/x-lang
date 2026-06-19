#!/usr/bin/env bash
# boot-017-stdlib-dogfood.sh — BOOT-017：std/core 分模块 check 耗时辅助
#
# 用法（source 后）：
#   boot017_resolve_shu
#   boot017_list_modules MATRIX_TSV
#   boot017_emit_report status modules slow p50 p95 skip

BOOT017_PREFIX="${SHUX_BOOT017_PREFIX:-shux: [SHUX_BOOT017_STDLIB_DOGFOOD]}"

# 判断 shux 是否可在本机执行。
boot017_native_shu() {
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

# 解析 check 用 shux（优先 shux-c）。
boot017_resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if boot017_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  if [ -n "${SHUX:-}" ] && boot017_native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  return 1
}

# 从 BOOT-013 矩阵列出 module 行（module_id layer）；每行一个模块。
boot017_list_modules() {
  local tsv="$1"
  while IFS=$'\t' read -r item_id kind anchor layer _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|read_path|matrix|report|lib|runner|gate) continue ;; esac
    [ "$kind" = "module" ] || continue
    printf '%s\t%s\n' "$anchor" "$layer"
  done < "$tsv"
}

# 输出结构化报告行。
boot017_emit_report() {
  local status="$1"
  local modules="$2"
  local slow="$3"
  local p50="$4"
  local p95="$5"
  local skip="$6"
  echo "${BOOT017_PREFIX} status=${status} modules=${modules} slow=${slow} p50=${p50} p95=${p95} skip=${skip}"
}
