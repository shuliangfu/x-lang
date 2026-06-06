#!/usr/bin/env bash
# 从 build_asm/typeck.o 导出 layout 符号子集 → typeck_asm_layout_partial.o（与 build_shu_asm.sh 一致）。
# 供 strict 链与 typeck_su_no_layout_partial 分工：layout 走 asm EMIT_HEAVY，编排走 typeck_su.o。
# 用法：source tests/lib/s2-typeck-layout-partial.sh && s2_rebuild_typeck_layout_partial

s2_rebuild_typeck_layout_partial() {
  local tck="${1:-compiler/build_asm/typeck.o}"
  local partial="${2:-compiler/build_asm/typeck_asm_layout_partial.o}"
  local syms="${3:-compiler/build_asm/typeck_asm_layout_export.txt}"

  if [ ! -f "$tck" ] || [ ! -s "$tck" ]; then
    echo "s2 layout-partial: missing $tck" >&2
    return 1
  fi

  mkdir -p "$(dirname "$partial")"
  cat >"$syms" <<'EOF'
_typeck_struct_layout_metrics
_typeck_validate_struct_layouts_zero_padding
_ensure_struct_layout_from_struct_lit
_typeck_merge_dep_struct_layouts_into_entry
_entry_module_find_struct_layout_index
_typeck_find_layout_idx_by_type_name
EOF

  echo "s2 layout-partial: ld -r -exported_symbols_list $syms $tck -> $partial"
  if ! ld -r -exported_symbols_list "$syms" -o "$partial" "$tck" 2>"${partial}.err"; then
    echo "s2 layout-partial FAIL: ld -r failed (see ${partial}.err)" >&2
    tail -n 8 "${partial}.err" 2>/dev/null || true
    return 1
  fi
  return 0
}
