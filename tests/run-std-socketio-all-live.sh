#!/usr/bin/env bash
# STD-SOCKETIO-001 all-live：gate + 全部可选 live 编排（P3 收口）
#
# 启用：XLANG_SOCKETIO_ALL_LIVE=1 ./tests/run-std-socketio-all-live.sh
set -e
cd "$(dirname "$0")/.."

if [ "${XLANG_SOCKETIO_ALL_LIVE:-0}" != "1" ]; then
  echo "std-socketio all-live SKIP (set XLANG_SOCKETIO_ALL_LIVE=1 to enable)"
  exit 0
fi

echo "=== STD-SOCKETIO-001: gate ==="
./tests/run-std-socketio-gate.sh

echo "=== STD-SOCKETIO-001: mock live ==="
XLANG_SOCKETIO_LIVE=1 ./tests/run-std-socketio-live.sh

echo "=== STD-SOCKETIO-001: npm polling live ==="
XLANG_SOCKETIO_NPM=1 ./tests/run-std-socketio-npm-live.sh

echo "=== STD-SOCKETIO-001: npm WS live ==="
XLANG_SOCKETIO_NPM_WS=1 ./tests/run-std-socketio-npm-ws-live.sh

echo "=== STD-SOCKETIO-001: npm room live ==="
XLANG_SOCKETIO_NPM_ROOM=1 ./tests/run-std-socketio-npm-room-live.sh

echo "=== STD-SOCKETIO-001: npm mw live ==="
XLANG_SOCKETIO_NPM_MW=1 ./tests/run-std-socketio-npm-mw-live.sh

echo "=== STD-SOCKETIO-001: npm plugin live ==="
XLANG_SOCKETIO_NPM_PLUGIN=1 ./tests/run-std-socketio-npm-plugin-live.sh

echo "=== STD-SOCKETIO-001: cluster ring live ==="
XLANG_SOCKETIO_CLUSTER_RING=1 ./tests/run-std-socketio-cluster-ring-live.sh

echo "std-socketio all-live OK"
