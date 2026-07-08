#!/usr/bin/env bash
# shux_asm_postlink_smoke.sh — build_shux_asm 产出 shux_asm 的 -c/-o 烟测
#
# 用法（compiler 目录）：
#   ./scripts/shux_asm_postlink_smoke.sh [shux_asm_path] [fallback_compiler]
#
# 回退顺序（默认允许，本地调试）：experimental → fallback_compiler
#   SHUX_BOOTSTRAP_NO_POSTLINK_FALLBACK=1 — 禁止任何回退（W3 gold 须设，防自举塌陷）
#
# 环境：
#   SHUX_BOOTSTRAP_AUDIT_DIR — 审计标记目录（默认 ../logs）

set -euo pipefail
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

ASM="${1:-./shux_asm}"
FALLBACK="${2:-${SHUX:-./shux}}"
SMOKE_SRC="/tmp/shux_asm_postlink_smoke.$$.x"
SMOKE_OUT="/tmp/shux_asm_postlink_smoke_out.$$"
AUDIT_DIR="${SHUX_BOOTSTRAP_AUDIT_DIR:-../logs}"

# 平台自适应后端选择（与 run_shux_asm_smoke.sh 一致）。
# 【Why】strict link 产出的 shux_asm 链入 asm_backend_partial.o（asm codegen），
# 但不链入 codegen_x.o（C codegen）。Linux x86_64 上 asm -o 已稳定工作；
# Darwin/ARM64 上 asm -o Mach-O/ARM64 stub 不完整，需 -backend c（依赖 codegen_x.o，
# 仅 gen_driver fallback 路径链入）。故 Linux x86_64 用 asm，其余平台用 c。
# 【Invariant】SMOKE_BACKEND_ARGS 在 smoke_bin 中展开为 -backend <asm|c> 或空。
SMOKE_RUN_BACKEND="${SHUX_ASM_SMOKE_BACKEND:-}"
if [ -z "$SMOKE_RUN_BACKEND" ]; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64)
      SMOKE_RUN_BACKEND="c"
      ;;
    *)
      SMOKE_RUN_BACKEND="asm"
      ;;
  esac
fi
SMOKE_BACKEND_ARGS=""
if [ "$SMOKE_RUN_BACKEND" = "c" ]; then
  SMOKE_BACKEND_ARGS="-backend c"
elif [ "$SMOKE_RUN_BACKEND" = "asm" ]; then
  SMOKE_BACKEND_ARGS="-backend asm"
fi

cleanup() {
  rm -f "$SMOKE_SRC" "$SMOKE_OUT" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "$AUDIT_DIR"

if [ ! -x "$ASM" ]; then
  echo "shux_asm_postlink_smoke: missing $ASM" >&2
  exit 1
fi

printf '%s\n' 'function main(): i32 { return 42; }' >"$SMOKE_SRC"

# smoke_bin — shux_asm 的 -c/-o 烟测；后端由 SMOKE_BACKEND_ARGS 平台自适应选择。
# 参数：bin — 待测路径；成功返回 0。
smoke_bin() {
  local bin="$1"
  local _log="/tmp/shux_asm_postlink_smoke_$$.log"
  local _rc=0
  [ -x "$bin" ] || return 1
  "$bin" -c "$SMOKE_SRC" 2>&1 | tee "$_log" | cat >/dev/null
  _rc="${PIPESTATUS[0]:-1}"
  if [ "$_rc" -ne 0 ]; then
    return 1
  fi
  rm -f "$SMOKE_OUT"
  # shellcheck disable=SC2086
  "$bin" $SMOKE_BACKEND_ARGS -o "$SMOKE_OUT" "$SMOKE_SRC" 2>&1 | tee "$_log" | cat >/dev/null
  _rc="${PIPESTATUS[0]:-1}"
  if [ "$_rc" -ne 0 ]; then
    return 1
  fi
  [ -x "$SMOKE_OUT" ] || return 1
  local ec=0
  "$SMOKE_OUT" 2>&1 | tee "$_log" | cat >/dev/null || ec=$?
  [ "$ec" -eq 42 ]
}

if smoke_bin "$ASM"; then
  : >"$AUDIT_DIR/bootstrap-postlink.fresh"
  rm -f "$AUDIT_DIR/bootstrap-postlink.experimental-fallback" \
    "$AUDIT_DIR/bootstrap-postlink.compiler-fallback"
  printf '[%s] postlink smoke OK fresh %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$ASM" \
    >>"$AUDIT_DIR/bootstrap-audit.log"
  echo "shux_asm_postlink_smoke: OK $ASM (-c + -backend $SMOKE_RUN_BACKEND -o exit=42)"
  exit 0
fi

echo "shux_asm_postlink_smoke: WARN $ASM smoke failed" >&2

if [ "${SHUX_BOOTSTRAP_NO_POSTLINK_FALLBACK:-0}" = "1" ]; then
  echo "shux_asm_postlink_smoke: FAIL (SHUX_BOOTSTRAP_NO_POSTLINK_FALLBACK=1)" >&2
  printf '[%s] postlink smoke FAIL no-fallback %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$ASM" \
    >>"$AUDIT_DIR/bootstrap-audit.log"
  exit 1
fi

if [ -x ./shux_asm.experimental ] && smoke_bin ./shux_asm.experimental; then
  echo "shux_asm_postlink_smoke: fallback ./shux_asm.experimental -> $ASM" >&2
  cp -f ./shux_asm.experimental "$ASM"
  : >"$AUDIT_DIR/bootstrap-postlink.experimental-fallback"
  rm -f "$AUDIT_DIR/bootstrap-postlink.fresh"
  printf '[%s] postlink experimental-fallback %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$ASM" \
    >>"$AUDIT_DIR/bootstrap-audit.log"
  echo "shux_asm_postlink_smoke: OK after experimental fallback"
  exit 0
fi

if [ -x "$FALLBACK" ] && smoke_bin "$FALLBACK"; then
  echo "shux_asm_postlink_smoke: fallback $FALLBACK -> $ASM" >&2
  cp -f "$FALLBACK" "$ASM"
  : >"$AUDIT_DIR/bootstrap-postlink.compiler-fallback"
  rm -f "$AUDIT_DIR/bootstrap-postlink.fresh"
  printf '[%s] postlink compiler-fallback %s <- %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$ASM" "$FALLBACK" \
    >>"$AUDIT_DIR/bootstrap-audit.log"
  echo "shux_asm_postlink_smoke: OK after compiler fallback"
  exit 0
fi

echo "shux_asm_postlink_smoke: FAIL no working fallback for $ASM" >&2
exit 1
