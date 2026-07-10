#!/usr/bin/env bash
# std-async-io-cps.sh — STD-042 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_async_io_cps_symbols_ok MOD_X IO_X SCHED_C IO_C TSV
#   std_async_io_cps_run_smoke SHUX_BIN X TAG
#   std_async_io_cps_check_emit SHUX_BIN X
#   std_async_io_cps_emit_report status align_ok io_uring_ok emit_ok skip

STD_ASYNC_IO_CPS_PREFIX="${SHUX_STD_ASYNC_IO_CPS_PREFIX:-shux: [SHUX_STD_ASYNC_IO_CPS]}"

# 校验 manifest symbol/file；echo 缺失数。
std_async_io_cps_symbols_ok() {
  local mod_x="$1"
  local io_x="$2"
  local sched_c="$3"
  local io_c="$4"
  local tsv="$5"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/async/mod.x) mod_path="$mod_x" ;;
          std/io/mod.x) mod_path="$io_x" ;;
          compiler/src/asm/runtime_scheduler_glue.inc) mod_path="$sched_c" ;;
          std/io/mod.x) mod_path="$io_x" ;;
          std/io/io.c) mod_path="$io_c" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-async-io-cps FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-async-io-cps FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .x。
std_async_io_cps_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_async_io_cps_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-async-io-cps FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-async-io-cps FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-async-io-cps FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 检查 await IO emit 含 suspend_io + async submit。
std_async_io_cps_check_emit() {
  local shux="$1"
  local src="$2"
  local out
  if [ ! -f "$src" ]; then
    echo "std-async-io-cps FAIL: missing emit src $src" >&2
    return 1
  fi
  if ! out="$("$shux" -E "$src" 2>&1)"; then
    echo "std-async-io-cps FAIL: -E $src" >&2
    echo "$out" | tail -12 >&2
    return 1
  fi
  if ! echo "$out" | grep -qF 'shux_async_cps_suspend_io'; then
    echo "std-async-io-cps FAIL: emit missing shux_async_cps_suspend_io" >&2
    return 1
  fi
  if ! echo "$out" | grep -qF 'shux_io_submit_read_async'; then
    echo "std-async-io-cps FAIL: emit missing shux_io_submit_read_async" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_async_io_cps_emit_report() {
  local status="$1"
  local align_ok="$2"
  local io_uring_ok="$3"
  local emit_ok="$4"
  local skip="$5"
  echo "${STD_ASYNC_IO_CPS_PREFIX} status=${status} align=${align_ok} io_uring=${io_uring_ok} emit=${emit_ok} skip=${skip}"
}
