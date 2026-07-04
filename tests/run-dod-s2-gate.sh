#!/usr/bin/env bash
# DOD-S2 门禁：std.vec Vec3f_soa（默认 SoA 列）+ Vec3f_aos（opt-in AoS）。
# 阶段：typeck + heap alloc_f32 链 + push/len/deinit + vec3f_soa_sum_x 列扫描。
# 用法：
#   ./tests/run-dod-s2-gate.sh
#   SHUX=./compiler/shux_asm ./tests/run-dod-s2-gate.sh
#   SHUX_ABI_F32_XMM=1 SHUX=./compiler/shux_asm ./tests/run-dod-s2-gate.sh  # vec3f push gp/xmm + 禁 cvtsd2ss
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"

SHUX_BIN="${SHUX:-}"
case "$SHUX_BIN" in
  /*) SHUX_ABS="$SHUX_BIN" ;;
  "") SHUX_ABS="" ;;
  *) SHUX_ABS="$(pwd)/$SHUX_BIN" ;;
esac

if [ -z "$SHUX_ABS" ] || ! dod_native_exe "$SHUX_ABS"; then
  SHUX_ABS=""
  for cand in ./compiler/shux ./compiler/shux_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHUX_ABS="$abs"
      break
    fi
  done
fi

CHECK_SHUX="$SHUX_ABS"
if [ -z "$CHECK_SHUX" ] && [ -x ./compiler/shux-c ]; then
  CHECK_SHUX=./compiler/shux-c
fi

# dod-s2 是否走 xmm ABI（默认开；仅 SHUX_ABI_F32_XMM=0 为 legacy）。
dod_s2_xmm_abi_active() {
  [ "${SHUX_ABI_F32_XMM:-1}" != "0" ]
}

echo "=== DOD-S2: std.vec Vec3f_soa / Vec3f_aos smoke ==="
if dod_s2_xmm_abi_active; then
  echo "dod-s2: f32 xmm ABI active (default; SHUX_ABI_F32_XMM=0 for legacy cvtsd2ss)"
else
  echo "dod-s2: SHUX_ABI_F32_XMM=0 (legacy f64 widen + cvtsd2ss)"
fi

# shux_asm 编译：默认 xmm；legacy 时显式传 SHUX_ABI_F32_XMM=0。
dod_s2_shu_compile() {
  if dod_s2_xmm_abi_active; then
    SHUX="$SHUX_ABS" "$SHUX_ABS" "$@"
  else
    env SHUX_ABI_F32_XMM=0 SHUX="$SHUX_ABS" "$SHUX_ABS" "$@"
  fi
}

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
SMOKE_SRC="tests/vec/vec3f_soa_smoke.x"
SUM_SRC="tests/vec/vec3f_soa_sum_smoke.x"
MAIN_SRC="tests/vec/main.x"
SMOKE_OUT="$OUT_DIR/shux_vec3f_soa_smoke"
SUM_OUT="$OUT_DIR/shux_vec3f_soa_sum_smoke"
MAIN_OUT="$OUT_DIR/shux_vec_main"
rm -f "$SMOKE_OUT" "$SUM_OUT" "$MAIN_OUT"

if [ -z "$CHECK_SHUX" ] && [ -z "$SHUX_ABS" ]; then
  echo "dod-s2 gate SKIP (no shux/shux-c/shux_asm)"
  exit 0
fi

# typeck：Vec3f_soa / Vec3f_aos API
if [ -n "$CHECK_SHUX" ]; then
  if "$CHECK_SHUX" check -L . "$SMOKE_SRC" >/dev/null 2>&1; then
    echo "dod-s2: vec3f_soa_smoke typeck OK"
  else
    echo "dod-s2 FAIL: typeck $SMOKE_SRC" >&2
    "$CHECK_SHUX" check -L . "$SMOKE_SRC" 2>&1 || true
    exit 1
  fi
  if "$CHECK_SHUX" check -L . "$SUM_SRC" >/dev/null 2>&1; then
    echo "dod-s2: vec3f_soa_sum_smoke typeck OK"
  else
    echo "dod-s2 FAIL: typeck $SUM_SRC" >&2
    "$CHECK_SHUX" check -L . "$SUM_SRC" 2>&1 || true
    exit 1
  fi
else
  echo "dod-s2: typeck SKIP (no check-capable compiler)"
fi

if [ -z "$SHUX_ABS" ] || ! dod_native_exe "$SHUX_ABS"; then
  echo "dod-s2: typeck-only OK (no native shux_asm for asm link/run)"
  echo "dod-s2 gate OK"
  exit 0
fi

# F-03 v2：heap 已纯 .x，shux asm 链按需 -lc，不再 cc -c heap.c

# asm 链：Vec3f + std.heap f32 分配符号可链接
if ! dod_s2_shu_compile -backend asm -L . "$SMOKE_SRC" -o "$SMOKE_OUT" 2>/tmp/shux_dod_s2_build.log; then
  echo "dod-s2 FAIL: compile $SMOKE_SRC" >&2
  tail -8 /tmp/shux_dod_s2_build.log 2>/dev/null || true
  exit 1
fi
if [ ! -x "$SMOKE_OUT" ]; then
  echo "dod-s2 FAIL: missing exe $SMOKE_OUT" >&2
  exit 1
fi
echo "dod-s2: vec3f_soa_smoke link OK"

RC=0
"$SMOKE_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 3 ]; then
  echo "dod-s2 FAIL: vec3f_soa_smoke expected exit 3, got $RC" >&2
  exit 1
fi
echo "dod-s2: vec3f_soa_smoke exit=3 OK"
if dod_s2_xmm_abi_active && command -v objdump >/dev/null 2>&1; then
  SMOKE_DIS="$(objdump -d "$SMOKE_OUT" 2>/dev/null || true)"
  if echo "$SMOKE_DIS" | grep -qE 'movd.*xmm'; then
    echo "dod-s2: vec3f_soa_smoke xmm disasm movd xmm present"
  else
    echo "dod-s2 FAIL: vec3f_soa_smoke (xmm) disasm missing movd xmm" >&2
    exit 1
  fi
  if echo "$SMOKE_DIS" | grep -q 'cvtsd2ss'; then
    echo "dod-s2 FAIL: vec3f_soa_smoke (xmm) disasm still has cvtsd2ss" >&2
    exit 1
  fi
  echo "dod-s2: vec3f_soa_push xmm disasm OK"
fi

# heap SoA 列扫描：1+2+3=6（vec3f_soa_sum_x + addss）
if ! dod_s2_shu_compile -backend asm -L . "$SUM_SRC" -o "$SUM_OUT" 2>/tmp/shux_dod_s2_sum_build.log; then
  echo "dod-s2 FAIL: compile $SUM_SRC" >&2
  tail -8 /tmp/shux_dod_s2_sum_build.log 2>/dev/null || true
  exit 1
fi
if [ ! -x "$SUM_OUT" ]; then
  echo "dod-s2 FAIL: missing exe $SUM_OUT" >&2
  exit 1
fi
RC=0
"$SUM_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 6 ]; then
  echo "dod-s2 FAIL: vec3f_soa_sum_smoke expected exit 6, got $RC" >&2
  exit 1
fi
echo "dod-s2: vec3f_soa_sum_smoke exit=6 OK"
if command -v objdump >/dev/null 2>&1; then
  if objdump -d "$SUM_OUT" 2>/dev/null | grep -q 'addss'; then
    echo "dod-s2: vec3f_soa_sum_x disasm addss OK"
  else
    echo "dod-s2 WARN: vec3f sum disasm missing addss (non-fatal)" >&2
  fi
fi

# std.vec 基础 API run（无 Vec 按值传参）
if ! dod_s2_shu_compile -L . "$MAIN_SRC" -o "$MAIN_OUT" 2>/tmp/shux_dod_s2_main_build.log; then
  echo "dod-s2 FAIL: compile $MAIN_SRC" >&2
  tail -8 /tmp/shux_dod_s2_main_build.log 2>/dev/null || true
  exit 1
fi
RC=0
"$MAIN_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "dod-s2 FAIL: vec main expected exit 0, got $RC" >&2
  exit 1
fi
echo "dod-s2: vec main exit=0 OK"
echo "dod-s2 gate OK"
