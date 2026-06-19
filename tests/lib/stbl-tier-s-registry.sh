#!/usr/bin/env bash
# stbl-tier-s-registry.sh — STBL-001：Tier-S manifest 注册表校验辅助
#
# 用法（source 后）：
#   stbl_tier_s_validate_api_manifest MOD TSV
#   stbl_tier_s_validate_feature_manifest MOD TSV
#   stbl_tier_s_validate_module MOD MANIFEST KIND
#   stbl_tier_s_emit_report status covered sym_miss

STBL_TIER_S_PREFIX="${SHUX_STBL_TIER_S_PREFIX:-shux: [SHUX_STBL_TIER_S]}"

# api 型 manifest：每行一个符号，须在 mod.sx 存在 function 定义。
stbl_tier_s_validate_api_manifest() {
  local mod="$1"
  local tsv="$2"
  local miss=0
  local sym
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac
    # 跳过带制表符的元数据行。
    case "$line" in
      *$'\t'*) continue ;;
    esac
    sym="$line"
    if ! grep -qE "function ${sym}[[:space:](]" "$mod" 2>/dev/null; then
      echo "stbl-tier-s FAIL: missing function ${sym} in $mod (from $tsv)" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# feature 型 manifest：解析 kind=symbol|api 行，校验 anchor 在 mod 或 src 列文件。
stbl_tier_s_validate_feature_manifest() {
  local default_mod="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path src_col
  while IFS=$'\t' read -r item_id kind anchor mod_path src_col _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*|min_*|read_path|clock_*|precision|timezone|api_surface|verify|zc_*|large_*|doc|gate|lib|hook_*|smoke_*|cross_*|test_*|impl_*|lifecycle_*|win_*|pipe_*|spawn_*|heap_*|map_*|vec_*|global_*|sidecar_*|smoke_case) continue ;;
    esac
    case "$kind" in
      symbol|api)
        local target="$default_mod"
        if [ -n "${mod_path:-}" ] && [ "$mod_path" != "-" ]; then
          target="$mod_path"
        elif [ -n "${src_col:-}" ] && [ "$src_col" != "-" ]; then
          target="$src_col"
        fi
        if [ ! -f "$target" ]; then
          echo "stbl-tier-s FAIL: missing target $target ($item_id)" >&2
          miss=$((miss + 1))
          continue
        fi
        if ! grep -qE "(function ${anchor}[[:space:](]|${anchor})" "$target" 2>/dev/null; then
          echo "stbl-tier-s FAIL: missing anchor '${anchor}' in $target ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol_*)
        # std-error-unify：symbol_io_err 等行，anchor 为符号名。
        if [ -n "${anchor:-}" ] && [ "$anchor" != "-" ]; then
          local err_mod="${default_mod}"
          if [ -n "${mod_path:-}" ] && [ "$mod_path" != "-" ]; then
            err_mod="$mod_path"
          fi
          if ! grep -qE "function ${anchor}[[:space:](]" "$err_mod" 2>/dev/null; then
            echo "stbl-tier-s FAIL: missing symbol ${anchor} in $err_mod" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
    esac
    # std-error-unify 模块矩阵行：module_id 为 std.*，base_fn 在 error mod。
    case "$item_id" in
      std.*)
        if [ -n "${kind:-}" ] && [ "$kind" = "Layer C" ] || [ "$kind" = "Layer C+B" ] || [ "$kind" = "Layer B" ]; then
          :
        fi
        ;;
    esac
  done < "$tsv"

  # std-error-unify 专用：module 行 base_fn 在 std/error/mod.sx。
  if grep -q '^std\.io' "$tsv" 2>/dev/null; then
    local module_id exc_layer base_fn sidecar_fn src
    while IFS=$'\t' read -r module_id exc_layer base_fn sidecar_fn src _rest; do
      [ -z "${module_id:-}" ] && continue
      case "$module_id" in
        std.*)
          if [ -n "$base_fn" ] && [ "$base_fn" != "-" ]; then
            if ! grep -qE "function ${base_fn}\\(" "$default_mod" 2>/dev/null; then
              echo "stbl-tier-s FAIL: missing error_base ${base_fn} in $default_mod" >&2
              miss=$((miss + 1))
            fi
          fi
          if [ -n "$src" ] && [ "$src" != "-" ] && [ ! -f "$src" ]; then
            echo "stbl-tier-s FAIL: missing module src $src" >&2
            miss=$((miss + 1))
          fi
          ;;
      esac
    done < "$tsv"
  fi

  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 按 kind 分发单模块 manifest 校验；echo 缺失符号数。
stbl_tier_s_validate_module() {
  local mod="$1"
  local manifest="$2"
  local kind="$3"
  case "$kind" in
    api) stbl_tier_s_validate_api_manifest "$mod" "$manifest" ;;
    feature) stbl_tier_s_validate_feature_manifest "$mod" "$manifest" ;;
    *)
      echo "stbl-tier-s FAIL: unknown kind '$kind'" >&2
      echo 1
      return 1
      ;;
  esac
}

# 输出结构化报告行。
stbl_tier_s_emit_report() {
  local status="$1"
  local covered="$2"
  local sym_miss="$3"
  echo "${STBL_TIER_S_PREFIX} status=${status} covered=${covered} sym_miss=${sym_miss}"
}
