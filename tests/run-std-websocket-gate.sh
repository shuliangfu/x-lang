#!/usr/bin/env bash
# STD-031：std.websocket 门禁（委托 run-std-net-ws-gate.sh）
#
# 用法：./tests/run-std-websocket-gate.sh
set -e
cd "$(dirname "$0")/.."
exec ./tests/run-std-net-ws-gate.sh "$@"
