#!/usr/bin/env bash
# C-08：main 薄入口 + driver/*.x + build.x + runtime 盘点（聚合门禁）。
#
# 用法：./tests/run-c08-runtime-driver-gate.sh
# 环境：SHUX_C08_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C08_FAIL:-0}
run_gate() {
  local script="$1"
  chmod +x "$script"
  if ! "$script"; then
    echo "c08 gate FAIL: $script" >&2
    [ "$FAIL" = "1" ] && exit 1
    return 1
  fi
  return 0
}

echo "=== C-08: runtime → driver.x / build.x (v1) ==="
ok=0
for g in tests/run-c08-main-entry-gate.sh tests/run-c08-driver-x-gate.sh tests/run-c08-build-x-gate.sh tests/run-c08-runtime-inventory-gate.sh; do
  if run_gate "$g"; then
    ok=$((ok + 1))
  fi
done
if [ "$ok" -lt 4 ]; then
  echo "c08 runtime-driver gate incomplete ($ok/4)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
echo "c08 runtime-driver gate OK (4/4)"
