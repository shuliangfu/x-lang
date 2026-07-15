#!/usr/bin/env bash
# shux-backend-wrap.sh — 将 SHUX_BACKEND_WRAP_ARGS（如 -backend c）注入到真实编译器调用。
# 由 bootstrap-link-shux.sh 在 Darwin 等宿主上设置 RUN_SHUX 为本包装。
set -e
REAL="${SHUX_BACKEND_WRAP_REAL:-./compiler/shux_asm}"
# shell-split backend args (e.g. "-backend c")
# shellcheck disable=SC2086
exec "$REAL" ${SHUX_BACKEND_WRAP_ARGS:-} "$@"
