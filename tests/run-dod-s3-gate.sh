#!/usr/bin/env bash
# DOD-S3 门禁：WPO 跨模块 SoA layout 统一 + 跨函数 arr[i].field（无 AoS↔SoA 转换）。
# 用法：
#   ./tests/run-dod-s3-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-dod-s3-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
esac

if [ -z "$SHU_ABS" ] || ! dod_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu_asm ./compiler/shu; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

# Mac 上 shu_asm 常为 Linux ELF：仍尝试 shu-c check（host 编译器）
CHECK_SHU="$SHU_ABS"
if [ -z "$CHECK_SHU" ] && [ -x ./compiler/shu-c ]; then
  CHECK_SHU=./compiler/shu-c
fi

CROSS_SRC="tests/dod/soa_cross.su"
UPGRADE_SRC="tests/dod/soa_upgrade.su"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
CROSS_OUT="$OUT_DIR/shu_dod_s3_cross"
UPGRADE_OUT="$OUT_DIR/shu_dod_s3_upgrade"
rm -f "$CROSS_OUT" "$UPGRADE_OUT"

echo "=== DOD-S3: WPO cross-module SoA layout unify ==="

if [ -z "$CHECK_SHU" ] && [ -z "$SHU_ABS" ]; then
  echo "dod-s3 gate SKIP (no shu/shu-c/shu_asm)"
  exit 0
fi

# typeck 门禁
if [ -n "$CHECK_SHU" ]; then
  if "$CHECK_SHU" check -L . "$CROSS_SRC" >/dev/null 2>&1; then
    echo "dod-s3: soa_cross typeck OK"
  else
    echo "dod-s3 FAIL: typeck $CROSS_SRC" >&2
    "$CHECK_SHU" check -L . "$CROSS_SRC" 2>&1 || true
    exit 1
  fi

  if "$CHECK_SHU" check -L . "$UPGRADE_SRC" >/dev/null 2>&1; then
    echo "dod-s3: soa_upgrade typeck OK"
  else
    echo "dod-s3 FAIL: typeck $UPGRADE_SRC" >&2
    "$CHECK_SHU" check -L . "$UPGRADE_SRC" 2>&1 || true
    exit 1
  fi
else
  echo "dod-s3: typeck SKIP (no check-capable compiler)"
fi

if [ -z "$SHU_ABS" ] || ! dod_native_exe "$SHU_ABS"; then
  echo "dod-s3: typeck-only OK (no native shu_asm for run test)"
  echo "dod-s3 gate OK"
  exit 0
fi

# asm 链：跨 module import + 运行
if ! SHU="$SHU_ABS" "$SHU_ABS" -backend asm -L . "$CROSS_SRC" -o "$CROSS_OUT" 2>/tmp/shu_dod_s3_cross_build.log; then
  echo "dod-s3 FAIL: compile $CROSS_SRC" >&2
  tail -8 /tmp/shu_dod_s3_cross_build.log 2>/dev/null || true
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

if ! SHU="$SHU_ABS" "$SHU_ABS" -backend asm -L . "$UPGRADE_SRC" -o "$UPGRADE_OUT" 2>/tmp/shu_dod_s3_upgrade_build.log; then
  echo "dod-s3 FAIL: compile $UPGRADE_SRC" >&2
  tail -8 /tmp/shu_dod_s3_upgrade_build.log 2>/dev/null || true
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
