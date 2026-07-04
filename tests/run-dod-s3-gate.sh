#!/usr/bin/env bash
# DOD-S3 门禁：WPO 跨模块 SoA layout 统一 + 跨函数 arr[i].field（无 AoS↔SoA 转换）。
# 用法：
#   ./tests/run-dod-s3-gate.sh
#   SHUX=./compiler/shux_asm ./tests/run-dod-s3-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/dod-host-backend.sh
source "$(dirname "$0")/lib/dod-host-backend.sh"

SHUX_BIN="${SHUX:-}"
case "$SHUX_BIN" in
  /*) SHUX_ABS="$SHUX_BIN" ;;
  "") SHUX_ABS="" ;;
  *) SHUX_ABS="$(pwd)/$SHUX_BIN" ;;
esac

if [ -z "$SHUX_ABS" ] || ! dod_native_exe "$SHUX_ABS"; then
  SHUX_ABS=""
  for cand in ./compiler/shux_asm ./compiler/shux; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHUX_ABS="$abs"
      break
    fi
  done
fi

# Mac 上 shux_asm 常为 Linux ELF：仍尝试 shux-c check（host 编译器）
CHECK_SHUX="$SHUX_ABS"
if [ -z "$CHECK_SHUX" ] && [ -x ./compiler/shux-c ]; then
  CHECK_SHUX=./compiler/shux-c
fi

CROSS_SRC="tests/dod/soa_cross.x"
UPGRADE_SRC="tests/dod/soa_upgrade.x"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
CROSS_OUT="$OUT_DIR/shux_dod_s3_cross"
UPGRADE_OUT="$OUT_DIR/shux_dod_s3_upgrade"
rm -f "$CROSS_OUT" "$UPGRADE_OUT"

echo "=== DOD-S3: WPO cross-module SoA layout unify ==="

if [ -z "$CHECK_SHUX" ] && [ -z "$SHUX_ABS" ]; then
  echo "dod-s3 gate SKIP (no shux/shux-c/shux_asm)"
  exit 0
fi

# typeck 门禁
if [ -n "$CHECK_SHUX" ]; then
  if "$CHECK_SHUX" check -L . "$CROSS_SRC" >/dev/null 2>&1; then
    echo "dod-s3: soa_cross typeck OK"
  else
    echo "dod-s3 FAIL: typeck $CROSS_SRC" >&2
    "$CHECK_SHUX" check -L . "$CROSS_SRC" 2>&1 || true
    exit 1
  fi

  if "$CHECK_SHUX" check -L . "$UPGRADE_SRC" >/dev/null 2>&1; then
    echo "dod-s3: soa_upgrade typeck OK"
  else
    echo "dod-s3 FAIL: typeck $UPGRADE_SRC" >&2
    "$CHECK_SHUX" check -L . "$UPGRADE_SRC" 2>&1 || true
    exit 1
  fi
else
  echo "dod-s3: typeck SKIP (no check-capable compiler)"
fi

if [ -z "$SHUX_ABS" ] || ! dod_native_exe "$SHUX_ABS"; then
  echo "dod-s3: typeck-only OK (no native shux_asm for run test)"
  echo "dod-s3 gate OK"
  exit 0
fi

# Darwin：import 跨模块 + gen_driver hybrid 下 -backend c 不可用、asm exe SIGILL；typeck 已覆盖，运行由 Linux 承担。
case "$(uname -s 2>/dev/null)" in
  Darwin)
    echo "dod-s3: cross-module compile/run N/A on Darwin (import + gen_driver hybrid; Linux covers)"
    echo "dod-s3 gate OK"
    exit 0
    ;;
esac

DOD_EXE_SHUX="$(dod_host_exe_shu "$SHUX_ABS")"

# asm 链：跨 module import + 运行
if ! SHUX="$SHUX_ABS" "$DOD_EXE_SHUX" $DOD_GATE_BACKEND_ARGS -L . "$CROSS_SRC" -o "$CROSS_OUT" 2>/tmp/shux_dod_s3_cross_build.log; then
  echo "dod-s3 FAIL: compile $CROSS_SRC" >&2
  tail -8 /tmp/shux_dod_s3_cross_build.log 2>/dev/null || true
  exit 1
fi
if [ ! -x "$CROSS_OUT" ]; then
  echo "dod-s3 FAIL: missing exe $CROSS_OUT" >&2
  exit 1
fi
RC=0
"$CROSS_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 10 ]; then
  echo "dod-s3 FAIL: soa_cross expected exit 10, got $RC" >&2
  exit 1
fi
echo "dod-s3: soa_cross exit=10 OK"

if ! SHUX="$SHUX_ABS" "$DOD_EXE_SHUX" $DOD_GATE_BACKEND_ARGS -L . "$UPGRADE_SRC" -o "$UPGRADE_OUT" 2>/tmp/shux_dod_s3_upgrade_build.log; then
  echo "dod-s3 FAIL: compile $UPGRADE_SRC" >&2
  tail -8 /tmp/shux_dod_s3_upgrade_build.log 2>/dev/null || true
  exit 1
fi
if [ ! -x "$UPGRADE_OUT" ]; then
  echo "dod-s3 FAIL: missing exe $UPGRADE_OUT" >&2
  exit 1
fi
RC=0
"$UPGRADE_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 10 ]; then
  echo "dod-s3 FAIL: soa_upgrade expected exit 10, got $RC" >&2
  exit 1
fi
echo "dod-s3: soa_upgrade exit=10 OK"

echo "dod-s3 gate OK"
