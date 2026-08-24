#!/usr/bin/env bash
# STD-031：std.websocket 门禁（委托 run-std-net-ws-gate.sh）
#
# 用法：./tests/run-std-websocket-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
exec ./tests/run-std-net-ws-gate.sh "$@"
