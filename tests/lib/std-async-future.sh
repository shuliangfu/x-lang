#!/usr/bin/env bash
# std-async-future.sh — STD-041 Future/Poll helpers.
#
# Usage (after source):
#   std_async_future_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ASYNC_FUTURE_PREFIX="${XLANG_STD_ASYNC_FUTURE_PREFIX:-xlang: [XLANG_STD_ASYNC_FUTURE]}"

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=/emit=).
std_async_future_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ASYNC_FUTURE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
