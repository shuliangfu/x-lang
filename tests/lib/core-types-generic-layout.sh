#!/usr/bin/env bash
# core-types-generic-layout.sh — CORE-001 manifest 与烟测辅助
#
# 用法（source 后）：
#   core_types_gl_symbols_ok TYPES_SU TSV
#   core_types_gl_emit_report status generic_ok scalar_ok skip

CORE_TYPES_GL_PREFIX="${SHU_CORE_TYPES_GL_PREFIX:-shu: [SHU_CORE_TYPES_GL]}"

# 校验 manifest symbol/file；echo 缺失数，成功返回 0。
core_types_gl_symbols_ok() {
  local types_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local target="$types_su"
        if [ -n "${mod_path:-}" ] && [ "$mod_path" != "-" ]; then
          target="$mod_path"
        fi
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "core-types-generic-layout FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "core-types-generic-layout FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_types_gl_emit_report() {
  local status="$1"
  local generic_ok="$2"
  local scalar_ok="$3"
  local skip="$4"
  echo "${CORE_TYPES_GL_PREFIX} status=${status} generic=${generic_ok} scalar=${scalar_ok} skip=${skip}"
}
