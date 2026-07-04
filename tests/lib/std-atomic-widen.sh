#!/usr/bin/env bash
# std-atomic-widen.sh — STD-146 manifest 与烟测辅助

STD146_PREFIX="${SHUX_STD146_ATOMIC_WIDEN_PREFIX:-shux: [SHUX_STD146_ATOMIC_WIDEN]}"

# 校验 manifest；echo 缺失数。
std_atomic_widen_symbols_ok() {
  local mod_x="$1"
  local atomic_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-atomic-widen FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/atomic/atomic_glue.c" ] || [ "$path" = "compiler/src/asm/runtime_atomic_glue.c" ]; then path="$atomic_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-atomic-widen FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-atomic-widen FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-atomic-widen FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-atomic-widen-v1.md" 2>/dev/null; then
          echo "std-atomic-widen FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 widen 烟测（需链接 atomic.o + runtime_atomic_glue.o）。
std_atomic_widen_run_smoke() {
  local shux="$1"
  local src="$2"
  local atomic_o="$3"
  local atomic_rt_o="${4:-}"
  local exe="/tmp/shux_std_atomic_widen_$$"
  local extra=()
  if [ -n "$atomic_rt_o" ] && [ -f "$atomic_rt_o" ]; then
    extra=("$atomic_rt_o")
  fi
  if ! "$shux" -L . "$src" -o "$exe" "$atomic_o" "${extra[@]}" >/dev/null 2>&1; then
    echo "std-atomic-widen FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" "$atomic_o" "${extra[@]}" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-atomic-widen FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_atomic_widen_emit_report() {
  local status="$1"
  local exec_ok="$2"
  local skip="$3"
  echo "${STD146_PREFIX} status=${status} exec=${exec_ok} skip=${skip}"
}
