#!/usr/bin/env bash
# std-async-language.sh — STD-041 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_alang_symbols_ok MOD_SX TSV
#   std_alang_emit_report status run_ok mod_ok skip_1m
#   std_alang_run_smoke SHUX_BIN SX OUT

STD_ALANG_PREFIX="${SHUX_STD_ASYNC_LANGUAGE_PREFIX:-shux: [SHUX_STD_ASYNC_LANGUAGE]}"

# 校验 manifest symbol/file；echo 缺失数，成功返回 0。
std_alang_symbols_ok() {
  local mod_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$mod_sx" 2>/dev/null; then
          echo "std-async-language FAIL: missing '$anchor' in $mod_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-async-language FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测；成功返回 0。
std_alang_run_smoke() {
  local shux="$1"
  local sx="$2"
  local out="$3"
  rm -f "$out"
  if ! "$shux" -L . "$sx" -o "$out" >/tmp/std_alang_smoke.log 2>&1; then
    cat /tmp/std_alang_smoke.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "std-async-language FAIL: $sx exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_alang_emit_report() {
  local status="$1"
  local run_ok="$2"
  local mod_ok="$3"
  local skip_1m="$4"
  echo "${STD_ALANG_PREFIX} status=${status} run=${run_ok} mod=${mod_ok} skip_1m=${skip_1m}"
}
