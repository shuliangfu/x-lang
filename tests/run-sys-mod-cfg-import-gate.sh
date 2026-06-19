#!/usr/bin/env bash
# B-19：std.sys/mod.sx #[cfg] import 剪枝烟测（Darwin/Linux shux-c）。
# 用法：./tests/run-sys-mod-cfg-import-gate.sh
# 环境：SHUX_SYS_MOD_CFG_IMPORT_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_SYS_MOD_CFG_IMPORT_FAIL:-0}
SU="tests/sys/sys_mod_cfg_import_smoke.sx"
OUT="/tmp/shux_sys_mod_cfg_import.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "sys-mod-cfg-import-gate: SKIP (no shux/shux-c)"
  exit 0
fi

OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) ;;
  *)
    echo "sys-mod-cfg-import-gate: SKIP (unsupported host $OS)"
    exit 0
    ;;
esac

rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -o "$OUT" "$SU" 2>/tmp/shux_sys_mod_cfg_import.log; then
  echo "sys-mod-cfg-import-gate FAIL: compile $SU on $OS" >&2
  tail -n 10 /tmp/shux_sys_mod_cfg_import.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "sys-mod-cfg-import-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "sys-mod-cfg-import-gate FAIL: expected exit 0, got $rc on $OS" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "sys-mod-cfg-import-gate OK (std.sys #[cfg] import prune on $OS)"
exit 0
