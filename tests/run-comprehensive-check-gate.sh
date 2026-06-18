#!/usr/bin/env bash
# STD-168：全面检查汇总门禁（文档 + NEXT-YELLOW + placeholder + 性能 weekly）
#
# 用法：./tests/run-comprehensive-check-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== STD-168: comprehensive check bundle ==="
chmod +x tests/run-doc-07-comprehensive-audit-gate.sh
chmod +x tests/run-placeholder-inventory-gate.sh
chmod +x tests/run-next-yellow-clear-gate.sh
chmod +x tests/run-doc-07-phase2-sync-gate.sh
chmod +x tests/run-doc-cookbook-expand-gate.sh
chmod +x tests/run-doc-07-stdlib-fulltable-gate.sh
chmod +x tests/lib/placeholder-inventory.sh

./tests/run-placeholder-inventory-gate.sh
./tests/run-doc-07-comprehensive-audit-gate.sh
./tests/run-next-yellow-clear-gate.sh
./tests/run-doc-07-phase2-sync-gate.sh
./tests/run-doc-cookbook-expand-gate.sh
./tests/run-doc-07-stdlib-fulltable-gate.sh
chmod +x tests/run-perf-weekly-gate.sh tests/run-perf-sqlite-gate.sh tests/lib/perf-sqlite.sh
./tests/run-perf-weekly-gate.sh

echo "shu: [SHU_COMPREHENSIVE_CHECK] status=ok"
echo "comprehensive-check gate OK"
