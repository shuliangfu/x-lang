#!/usr/bin/env bash
# std-async-context.sh — std.async ↔ std.context spawn/bind helpers.
#
# Usage (after source):
#   std_async_context_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ASYNC_CONTEXT_PREFIX="${XLANG_STD_ASYNC_CONTEXT_PREFIX:-xlang: [XLANG_STD_ASYNC_CTX]}"

# Structured report line (honesty: run=/obs=/skip=; retired x=/check=).
std_async_context_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ASYNC_CONTEXT_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
