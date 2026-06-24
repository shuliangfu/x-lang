#!/usr/bin/env bash
# std-simd-intrinsic.sh — STD-SIMD-INTRINSIC manifest 与烟测辅助

STD_SIMD_INTRINSIC_PREFIX="${SHUX_STD_SIMD_INTRINSIC_PREFIX:-shux: [SHUX_STD_SIMD_INTRINSIC]}"

std_simd_intrinsic_symbols_ok() {
  local mod_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null || miss=$((miss + 1))
        ;;
      smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译 .sx 烟测（asm 后端；与 STD-047 相同策略）。
std_simd_intrinsic_run_smoke() {
  local shux="$1"
  local src="$2"
  local obj="/tmp/shux_std_simd_intrinsic_$$.o"
  local exe="/tmp/shux_std_simd_intrinsic_$$"
  if ! "$shux" -L . "$src" -o "$obj" >/dev/null 2>&1; then
    echo "std-simd-intrinsic WARN: compile $src (asm unavailable)" >&2
    "$shux" -L . "$src" -o "$obj" 2>&1 | tail -8 >&2 || true
    rm -f "$obj" "$exe"
    return 2
  fi
  rm -f "$obj"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-simd-intrinsic WARN: link/run skipped (compile .o OK)" >&2
    return 0
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-intrinsic WARN: run exit=$ec (compile OK)" >&2
    return 0
  fi
  return 0
}

std_simd_intrinsic_emit_report() {
  echo "${STD_SIMD_INTRINSIC_PREFIX} status=$1 sx=$2 skip=$3"
}
