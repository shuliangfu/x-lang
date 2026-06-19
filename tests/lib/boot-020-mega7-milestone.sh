#!/usr/bin/env bash
# boot-020-mega7-milestone.sh — BOOT-020 mega7 替换里程碑辅助
#
# 用法（source 后）：
#   boot020_source_symbols_ok BASELINE THIN_SRC
#   boot020_emit_report status symbol_ok mega7_ok skip

BOOT020_PREFIX="${SHUX_BOOT020_PREFIX:-shux: [SHUX_BOOT020]}"

# Darwin 回退：校验 thin_c 源文件含 baseline 所列符号名；echo 缺失数。
boot020_source_symbols_ok() {
  local baseline="$1"
  local thin_src="$2"
  local miss=0
  local kind sym
  if [ ! -f "$baseline" ] || [ ! -f "$thin_src" ]; then
    echo "boot-020 FAIL: missing baseline or thin source" >&2
    echo 999
    return 1
  fi
  while IFS=$'\t' read -r kind sym _rest; do
    [ "$kind" = "symbol" ] || continue
    [ -n "$sym" ] || continue
    if ! grep -qF "$sym" "$thin_src" 2>/dev/null; then
      echo "boot-020 FAIL: thin source missing symbol $sym" >&2
      miss=$((miss + 1))
    fi
  done < "$baseline"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
boot020_emit_report() {
  local status="$1"
  local symbol_ok="$2"
  local mega7_ok="$3"
  local skip="$4"
  echo "${BOOT020_PREFIX} status=${status} symbol=${symbol_ok} mega7=${mega7_ok} skip=${skip}"
}
