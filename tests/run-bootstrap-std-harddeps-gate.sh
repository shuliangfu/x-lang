#!/usr/bin/env bash
# S7 / §四：编译器硬依赖 std 最小集 typeck 门禁
#
# 必须：sys + path（shux-c，~秒级）。
# 可选：fs + heap mod（stage1，大模块易 OOM；失败记 WARN 不阻塞 FAST）。
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh
# shellcheck source=tests/lib/p0-gate-shux.sh
source tests/lib/p0-gate-shux.sh

DOC="analysis/自举前必须清单.md"
REQUIRED=( "std/sys/mod.x" "std/path/mod.x" )
OPTIONAL=( "std/fs/mod.x" "std/heap/mod.x" )
TYPECK_TO="${SHUX_S7_TYPECK_TIMEOUT:-90}"

[ -f "$DOC" ] || { gate_progress "FAIL: missing $DOC"; exit 1; }
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

gate_progress "§四 S7: std 硬依赖 typeck（必须 ${#REQUIRED[@]} + 可选 ${#OPTIONAL[@]}）..."
FAIL=0
WARN=0
LAST_BIN=""

# 必须模块：shux-c typeck。
for m in "${REQUIRED[@]}"; do
  [ -f "$m" ] || { gate_progress "FAIL: missing $m"; exit 1; }
  gate_progress "S7 必须: typeck $m ..."
  bin="$(p0_gate_run_typeck "$m")" || {
    gate_progress "FAIL typeck $m"
    FAIL=$((FAIL + 1))
    continue
  }
  LAST_BIN="$bin"
  gate_progress "OK typeck $m (SHUX=$bin)"
done

# 可选模块：优先 shux-c typeck（C 解析器已修 ?/: 与 MAX_TOP_LEVEL_LETS）；失败再 stage1。
if [ "${SHUX_S7_OPTIONAL_SKIP:-0}" != "1" ]; then
for m in "${OPTIONAL[@]}"; do
  [ -f "$m" ] || { gate_progress "WARN: missing $m"; WARN=$((WARN + 1)); continue; }
  gate_progress "S7 可选: typeck $m (stage1/shux 回退, ${TYPECK_TO}s) ..."
  set +e
  bin="$(p0_gate_run_typeck "$m")"
  ec=$?
  set -e
  if [ "$ec" -eq 0 ] && [ -n "$bin" ]; then
    LAST_BIN="$bin"
    gate_progress "OK typeck $m (SHUX=$bin)"
  else
    gate_progress "WARN typeck $m ec=$ec（fs/heap mod 待闭合）"
    WARN=$((WARN + 1))
  fi
done
else
  gate_progress "S7 SKIP optional fs/heap mod（FAST；须 stage1 环境复验）"
  WARN=$((WARN + 2))
fi

if [ "$FAIL" -gt 0 ]; then
  gate_progress "std-harddeps gate FAIL: $FAIL required module(s)"
  exit 1
fi
if [ "$WARN" -gt 0 ]; then
  gate_progress "std-harddeps gate OK with $WARN WARN (fs/heap mod 待 stage1 稳定)"
  exit 0
fi
gate_progress "std-harddeps gate OK (4 modules, SHUX=$LAST_BIN)"
