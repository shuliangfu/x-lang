#!/usr/bin/env bash
# boot-016-std-asm-symbols.sh — BOOT-016：shux_asm Top-N std .o 符号完整性辅助
#
# 用法（source 后）：
#   boot016_nm_has_symbol OBJ SYM
#   boot016_verify_std_objs RUNTIME TSV
#   boot016_emit_report status obj_ok sym_miss runtime_miss skip

BOOT016_PREFIX="${SHUX_BOOT016_PREFIX:-shux: [SHUX_BOOT016]}"

# 判断 .o 中是否已定义符号 sym（兼容 macOS `_` 前缀与 GNU nm）。
boot016_nm_has_symbol() {
  local obj="$1"
  local sym="$2"
  if [ ! -f "$obj" ]; then
    return 1
  fi
  if ! command -v nm >/dev/null 2>&1; then
    return 1
  fi
  nm -g --defined-only "$obj" 2>/dev/null | awk '{print $NF}' | grep -qE "^_?${sym}$"
}

# 构建单个 std .o（相对仓库根路径）。
boot016_ensure_obj() {
  local obj_rel="$1"
  local mk_target="../${obj_rel}"
  if [ ! -f "$obj_rel" ]; then
    make -C compiler -q "$mk_target" 2>/dev/null || make -C compiler "$mk_target" >/dev/null 2>&1
  fi
  [ -f "$obj_rel" ]
}

# 校验 runtime.c 含 getter 与 obj_rel；echo 缺失数。
boot016_verify_runtime_paths() {
  local rt="$1"
  local tsv="$2"
  local miss=0
  local item_id kind obj_rel anchor getter _notes
  while IFS=$'\t' read -r item_id kind obj_rel anchor getter _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      std_obj)
        if [ -n "$getter" ] && [ "$getter" != "-" ]; then
          if ! grep -qF "$getter" "$rt" 2>/dev/null; then
            echo "boot-016 FAIL: runtime missing getter $getter ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        if ! grep -qF "$obj_rel" "$rt" 2>/dev/null; then
          echo "boot-016 FAIL: runtime missing obj path $obj_rel ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
boot016_emit_report() {
  local status="$1"
  local obj_ok="$2"
  local sym_miss="$3"
  local runtime_miss="$4"
  local skip="$5"
  echo "${BOOT016_PREFIX} status=${status} obj_ok=${obj_ok} sym_miss=${sym_miss} runtime_miss=${runtime_miss} skip=${skip}"
}
