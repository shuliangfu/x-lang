#!/usr/bin/env bash
# std-async-io-cps.sh — STD-042 async IO + CPS suspend helpers.
#
# Usage (after source):
#   std_async_io_cps_symbols_ok MOD_X IO_X SCHED_C IO_C TSV
#   std_async_io_cps_run_smoke XLANG SRC [TAG]
#   std_async_io_cps_check_emit XLANG SRC
#   std_async_io_cps_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ASYNC_IO_CPS_PREFIX="${XLANG_STD_ASYNC_IO_CPS_PREFIX:-xlang: [XLANG_STD_ASYNC_IO_CPS]}"

# Validate manifest symbol/file/smoke anchors.
# Echo miss count; return 0 when miss=0.
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
          compiler/seeds/runtime_scheduler_glue.from_x.c) mod_path="$sched_c" ;;
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

# Compile and run .x smoke.
# Prefer callers pin XLANG_LINK_XLANG to product asm before invoke.
# Tip product UNDEF for std_async_* is gate-obs (not this helper's soft OK).
std_async_io_cps_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_async_io_cps_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-async-io-cps FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-async-io-cps FAIL: compile $src" >&2
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
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

# Check await IO emit contains suspend_io + async submit markers.
# Return 1 on -E tool fail or missing markers (callers may map miss → obs).
std_async_io_cps_check_emit() {
  local xlang="$1"
  local src="$2"
  local out
  if [ ! -f "$src" ]; then
    echo "std-async-io-cps FAIL: missing emit src $src" >&2
    return 1
  fi
  if ! out="$("$xlang" -E "$src" 2>&1)"; then
    echo "std-async-io-cps FAIL: -E $src" >&2
    echo "$out" | tail -12 >&2
    return 1
  fi
  if ! echo "$out" | grep -qF 'xlang_async_cps_suspend_io'; then
    echo "std-async-io-cps FAIL: emit missing xlang_async_cps_suspend_io" >&2
    return 1
  fi
  if ! echo "$out" | grep -qF 'xlang_io_submit_read_async'; then
    echo "std-async-io-cps FAIL: emit missing xlang_io_submit_read_async" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired align=/io_uring=/emit=).
std_async_io_cps_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ASYNC_IO_CPS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
