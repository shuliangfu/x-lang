#!/usr/bin/env bash
# core-api.sh — CORE-014：core 全模块 manifest 注册表校验辅助
#
# 用法（source 后）：
#   core_api_validate_api_manifest MOD TSV
#   core_api_validate_feature_manifest MOD TSV
#   core_api_validate_module MOD MANIFEST KIND
#   core_api_matrix_ok MATRIX_TSV
#   core_api_emit_report status covered sym_miss gate_miss

CORE_API_PREFIX="${SHUX_CORE_API_PREFIX:-shux: [SHUX_CORE_API]}"

# api 型 manifest：每行一个符号，须在 mod.sx 存在 function 定义。
core_api_validate_api_manifest() {
  local mod="$1"
  local tsv="$2"
  local miss=0
  local sym
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac
    case "$line" in
      *$'\t'*) continue ;;
    esac
    sym="$line"
    if ! grep -qE "function ${sym}[[:space:](]" "$mod" 2>/dev/null; then
      echo "core-api FAIL: missing function ${sym} in $mod (from $tsv)" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# feature 型 manifest：校验 mod_path 匹配当前模块的 symbol 行。
core_api_validate_feature_manifest() {
  local mod="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor row_mod _notes
  while IFS=$'\t' read -r item_id kind anchor row_mod _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        local target="$mod"
        if [ -n "${row_mod:-}" ] && [ "$row_mod" != "-" ]; then
          target="$row_mod"
        fi
        if [ "$target" != "$mod" ]; then
          continue
        fi
        if [ "$anchor" = "unwrap_or<T>" ]; then
          if ! grep -qF 'function unwrap_or<T>' "$mod" 2>/dev/null; then
            echo "core-api FAIL: missing generic unwrap_or in $mod" >&2
            miss=$((miss + 1))
          fi
        elif ! grep -qF "$anchor" "$mod" 2>/dev/null; then
          echo "core-api FAIL: missing '${anchor}' in $mod ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 按 kind 分发单模块 manifest 校验；echo 缺失符号数。
core_api_validate_module() {
  local mod="$1"
  local manifest="$2"
  local kind="$3"
  case "$kind" in
    api) core_api_validate_api_manifest "$mod" "$manifest" ;;
    feature) core_api_validate_feature_manifest "$mod" "$manifest" ;;
    *)
      echo "core-api FAIL: unknown kind '$kind'" >&2
      echo 1
      return 1
      ;;
  esac
}

# 校验 BOOT-013 矩阵含 11 个 core 模块行。
core_api_matrix_ok() {
  local matrix="$1"
  local miss=0
  local expect
  for expect in core_builtin core_debug core_fmt core_mem core_option core_result \
    core_slice core_types core_cmp core_iterator core_str; do
    if ! grep -qF "$expect" "$matrix" 2>/dev/null; then
      echo "core-api FAIL: stdlib-check-matrix missing row '$expect'" >&2
      miss=$((miss + 1))
    fi
  done
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_api_emit_report() {
  local status="$1"
  local covered="$2"
  local sym_miss="$3"
  local gate_miss="$4"
  echo "${CORE_API_PREFIX} status=${status} covered=${covered} sym_miss=${sym_miss} gate_miss=${gate_miss}"
}
