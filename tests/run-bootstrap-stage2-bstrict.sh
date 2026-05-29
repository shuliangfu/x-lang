#!/usr/bin/env bash
# M5：B-strict Stage2 验收（仓库根目录包装 compiler/verify-selfhost-stage2-bstrict.sh）。
# 用法：./tests/run-bootstrap-stage2-bstrict.sh

set -e
cd "$(dirname "$0")/.."
chmod +x compiler/verify-selfhost-stage2-bstrict.sh
exec sh compiler/verify-selfhost-stage2-bstrict.sh
