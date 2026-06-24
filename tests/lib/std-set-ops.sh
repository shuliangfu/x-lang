#!/usr/bin/env bash
# std-set-ops.sh — STD-129 manifest 与烟测辅助

STD_SET_OPS_PREFIX="${SHUX_STD129_SET_OPS_PREFIX:-shux: [SHUX_STD129_SET_OPS]}"

# 校验 manifest 条目。
std_set_ops_symbols_ok() {
  local mod_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_sx" 2>/dev/null; then
          echo "std-set-ops FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-set-ops FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_set_ops_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_set_ops_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-set-ops FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# 输出 gate 报告。
std_set_ops_emit_report() {
  echo "${STD_SET_OPS_PREFIX} status=$1 sx=$2 skip=$3"
}
