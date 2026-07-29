#!/usr/bin/env bash
# build_tool.sh — host build_tool binary from pinned seeds (11.0.3 · wave718)
#
# Authority (G.7):
#   Single implementation for assembling compiler/build_tool. Makefile
#   `build-tool` and repo-root xlang-build.sh call this script only.
#   Does NOT duplicate product link object lists (phase1/final stay Make).
#
# Usage (compiler directory, or via make -C compiler build-tool):
#   ./scripts/build_tool.sh
#
# Env:
#   CC, CFLAGS — same defaults as Makefile / cc_inc_tu.sh
#   XLANG_BUILD_TOOL_REGEN=1 — try ./xlang -x -E to refresh build_gen +
#     build_runtime_x_gen (falls back to seeds/ on failure)
#
# PLATFORM: SHARED — host-cc residual for G-05 entry until BC retires build_tool C.
# Wave: 718 Track MG · pairs with Makefile thin leaf + xlang-build direct call.

set -euo pipefail
cd "$(dirname "$0")/.."

CC="${CC:-cc}"
# Match Makefile `CFLAGS ?= -Wall -Wextra -I. -Iinclude -Isrc`
CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"

log() { echo "build-tool: $*" >&2; }

if [ "${XLANG_BUILD_TOOL_REGEN:-0}" = "1" ] && [ -x ./xlang ]; then
  log "regen build_gen + build_runtime_x_gen via ./xlang build -x -E"
  ./xlang build -x -E -L .. ../build.x > build_gen.c || cp -f seeds/build_gen.c build_gen.c
  ./xlang build -x -E -L .. ../build_runtime_x.x > build_runtime_x_gen.c \
    || cp -f seeds/build_runtime_x_gen.c build_runtime_x_gen.c
else
  cp -f seeds/build_gen.c build_gen.c
  cp -f seeds/build_runtime_x_gen.c build_runtime_x_gen.c
fi
cp -f seeds/build_runner_gen.c build_runner_gen.c

# shellcheck disable=SC2086
$CC $CFLAGS -Wno-unused -c build_gen.c -o build_tool.o
sh scripts/cc_inc_tu.sh seeds/build_tool_libc_bridge.from_x.c build_tool_libc_bridge.o
# shellcheck disable=SC2086
$CC $CFLAGS -c build_runner_gen.c -o build_runner.o
# shellcheck disable=SC2086
$CC $CFLAGS -Wno-unused -c build_runtime_x_gen.c -o build_runtime_x.o
sh scripts/cc_inc_tu.sh seeds/build_tool_main.from_x.c build_tool_main.o
# shellcheck disable=SC2086
$CC $CFLAGS -o build_tool \
  build_tool_main.o build_runner.o build_tool.o build_runtime_x.o build_tool_libc_bridge.o -lc

echo "build_tool OK（./build_tool ./xlang [asm|legacy]；G-05 pinned seeds）"
