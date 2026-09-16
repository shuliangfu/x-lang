#!/usr/bin/env bash
# phase-e-soft-audit.sh — 阶段 E 软退役 manifest 审计。
#
# 用法（source）：
#   . tests/lib/phase-e-soft-audit.sh
#   phase_e_soft_audit_manifest tests/baseline/phase-e-soft-retire.tsv || exit 1
#
# wave honesty (2026-08-24 #5): Makefile deleted MG wave941 —
# DRIVER_SEED faces live in compiler/mk/driver_seed_*.mk（refuse resurrect）。

# 审计 phase-e-soft-retire.tsv。
phase_e_soft_audit_manifest() {
  local manifest="${1:-tests/baseline/phase-e-soft-retire.tsv}"
  local miss=0
  local item_id e_task path status replacement check_type notes

  if [ ! -f "$manifest" ]; then
    echo "phase-e-soft: missing manifest $manifest" >&2
    return 1
  fi

  while IFS=$'\t' read -r item_id e_task path status replacement check_type notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    # Skip top-level DOC rows moved to archive (gate pins archive DOC).
    case "$path" in
      analysis/phase-e-soft-*|analysis/phase-e-e0*|analysis/phase-c-c0*)
        continue
        ;;
      compiler/Makefile)
        # Makefile physically deleted — live face checked via mk audit below.
        continue
        ;;
      compiler/seeds/runtime.from_x.c)
        # Monofile retired wave321 — must stay absent.
        if [ -f "$path" ]; then
          echo "phase-e-soft: runtime.from_x.c resurrected ($item_id)" >&2
          miss=$((miss + 1))
        fi
        continue
        ;;
    esac
    case "$check_type" in
      exists)
        if [ ! -f "$path" ]; then
          echo "phase-e-soft manifest missing file: $path ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      not_exists)
        if [ -f "$path" ]; then
          echo "phase-e-soft manifest should not exist (soft_retired): $path ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep)
        if [ ! -f "$path" ] || ! grep -q "$notes" "$path" 2>/dev/null; then
          echo "phase-e-soft manifest grep fail: $path need '$notes' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      gate_ref)
        if [ ! -f "$path" ]; then
          echo "phase-e-soft manifest missing gate: $path ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      phase_e_marker)
        if [ ! -f "$path" ]; then
          echo "phase-e-soft manifest missing: $path ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -q 'Phase E soft-retired' "$path" 2>/dev/null; then
          echo "phase-e-soft missing Phase E marker in $path ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      *)
        echo "phase-e-soft unknown check_type: $check_type ($item_id)" >&2
        miss=$((miss + 1))
        ;;
    esac
  done < "$manifest"

  if [ "$miss" -gt 0 ]; then
    echo "phase-e-soft: $miss manifest item(s) failed" >&2
    return 1
  fi
  return 0
}

# 统计 manifest 中 soft_retired 条目数。
phase_e_soft_count_retired() {
  local manifest="${1:-tests/baseline/phase-e-soft-retire.tsv}"
  awk -F'\t' '$4=="soft_retired" || $4=="hard_retired" { c++ } END { print c+0 }' "$manifest"
}

# 统计仍 active 的 compiler .c 条目（manifest 登记）。
phase_e_soft_count_active() {
  local manifest="${1:-tests/baseline/phase-e-soft-retire.tsv}"
  awk -F'\t' '$4=="active" && $3 ~ /\.c$/ { c++ } END { print c+0 }' "$manifest"
}

# 审计 mk 默认 seed 不含 C parser/typeck/codegen .o（C-06 / E-03）。
# wave honesty: compiler/Makefile deleted — authority = driver_seed_composites.mk
# + driver_seed_mode_objs.mk.
phase_e_soft_audit_makefile_no_c_frontend() {
  local mf="${1:-compiler/mk/driver_seed_composites.mk}"
  local mode="${2:-compiler/mk/driver_seed_mode_objs.mk}"
  if [ -f compiler/Makefile ]; then
    echo "phase-e-soft: compiler/Makefile resurrected (use mk/driver_seed_*.mk + ./xbuild)" >&2
    return 1
  fi
  if [ ! -f "$mf" ]; then
    echo "phase-e-soft: missing $mf" >&2
    return 1
  fi
  if grep -qE 'src/parser/parser\.o|src/typeck/typeck\.o|src/codegen/codegen\.o' "$mf" 2>/dev/null; then
    # Allow only inside comments / LEGACY bags — product DRIVER_SEED_OBJS must not embed them.
    if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$mf" | grep -qE 'src/parser/parser\.o|src/typeck/typeck\.o|src/codegen/codegen\.o'; then
      echo "phase-e-soft: DRIVER_SEED_OBJS embeds C frontend .o" >&2
      return 1
    fi
  fi
  if [ -f "$mode" ]; then
    if ! grep -q 'DRIVER_SEED_FRONTEND_EXTRA' "$mode" 2>/dev/null; then
      echo "phase-e-soft: $mode missing DRIVER_SEED_FRONTEND_EXTRA" >&2
      return 1
    fi
  elif ! grep -q 'DRIVER_SEED_FRONTEND_EXTRA' "$mf" 2>/dev/null; then
    echo "phase-e-soft: missing DRIVER_SEED_FRONTEND_EXTRA in mk faces" >&2
    return 1
  fi
  return 0
}

# 审计构建规则不含 -include lsp_io_extern.h / lsp_gen_extern.h（E-01）。
phase_e_soft_audit_no_extern_h_include() {
  local miss=0
  local f
  for f in compiler/mk/driver_seed_composites.mk compiler/mk/driver_seed_mode_objs.mk \
    compiler/scripts/build_xlang_asm.sh; do
    [ -f "$f" ] || continue
    if grep -qE 'lsp_io_extern\.h|lsp_gen_extern\.h' "$f" 2>/dev/null; then
      echo "phase-e-soft: $f still references lsp_*_extern.h" >&2
      miss=$((miss + 1))
    fi
  done
  if [ -f compiler/Makefile ] && grep -qE 'lsp_io_extern\.h|lsp_gen_extern\.h' compiler/Makefile 2>/dev/null; then
    echo "phase-e-soft: compiler/Makefile still references lsp_*_extern.h" >&2
    miss=$((miss + 1))
  fi
  if [ "$miss" -gt 0 ]; then
    return 1
  fi
  return 0
}
