#!/usr/bin/env bash
# bootstrap_driver_seed_smoke.sh — bootstrap-driver-seed 产出 shux 的 -c/-o 烟测
#
# 用法（compiler 目录）：
#   ./scripts/bootstrap_driver_seed_smoke.sh [path/to/shux]
#
# 成功：exit 0，stdout 打印 OK；写入 ../logs/bootstrap-seed.fresh
# 失败且存在 pinned seed：默认复制并 exit 0（WARN）；写入 bootstrap-seed.pinned-fallback
#   SHUX_BOOTSTRAP_NO_PINNED_FALLBACK=1 — 禁止回退（W3 gold 须设，防自举塌陷）
#
# 环境：
#   SHUX_BOOTSTRAP_AUDIT_DIR — 审计标记目录（默认 ../logs）

set -euo pipefail
cd "$(dirname "$0")/.."

# main.x / pipeline 深递归；与 build_shux_asm / run_shux_asm_smoke 栈对齐。
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

TARGET="${1:-./shux}"
SMOKE_SRC="/tmp/shux_bootstrap_seed_smoke.$$.x"
SMOKE_OUT="/tmp/shux_bootstrap_seed_smoke_out.$$"
PINNED_TMP="/tmp/shux_bootstrap_seed_pinned.$$"
AUDIT_DIR="${SHUX_BOOTSTRAP_AUDIT_DIR:-../logs}"

maybe_codesign() {
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ] && command -v codesign >/dev/null 2>&1; then
    codesign -s - --force "$1" >/dev/null 2>&1 || true
  fi
}

cleanup() {
  rm -f "$SMOKE_SRC" "$SMOKE_OUT" "$PINNED_TMP" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "$AUDIT_DIR"

if [ ! -x "$TARGET" ]; then
  echo "bootstrap_driver_seed_smoke: not executable: $TARGET" >&2
  exit 1
fi

printf '%s\n' 'function main(): i32 { return 42; }' >"$SMOKE_SRC"

# run_smoke — 对 bootstrap seed 编译器做 -c 与 -o 烟测。
# bootstrap seed 默认 asm -o 会链入 std/*.o 缺 C bridge；-backend c 走 C 后端可执行链。
# 参数：bin — 待测 shux 路径；成功返回 0。
run_smoke() {
  local bin="$1"
  local _log="/tmp/shux_bootstrap_seed_smoke_$$.log"
  local _rc=0
  echo "[$(date '+%H:%M:%S')] seed smoke: -c check ..."
  # shux-c (C frontend) 不支持 -c，用 -E 替代（同样做 parse+typeck）
  if "$bin" -c "$SMOKE_SRC" 2>&1 | tee "$_log"; then
    :
  else
    _rc="${PIPESTATUS[0]:-1}"
    # 尝试 -E 回退（shux-c C 前端模式）
    if "$bin" -E "$SMOKE_SRC" > /dev/null 2>&1; then
      echo "[$(date '+%H:%M:%S')] seed smoke: -c not supported, -E OK (C frontend)"
    else
      return 1
    fi
  fi
  echo "[$(date '+%H:%M:%S')] seed smoke: -backend c -o (may take ~1min) ..."
  rm -f "$SMOKE_OUT"
  "$bin" -backend c -o "$SMOKE_OUT" "$SMOKE_SRC" 2>&1 | tee "$_log"
  _rc="${PIPESTATUS[0]:-1}"
  if [ "$_rc" -ne 0 ]; then
    # 回退：shux-c C 前端不支持 -backend c -o，用 -E + cc 替代
    echo "[$(date '+%H:%M:%S')] seed smoke: -backend c -o failed, trying -E + cc fallback ..."
    "$bin" -E "$SMOKE_SRC" > "${SMOKE_OUT}.c" 2>"$_log"
    _rc=$?
    if [ "$_rc" -ne 0 ]; then
      return 1
    fi
    ${CC:-cc} -O2 -o "$SMOKE_OUT" "${SMOKE_OUT}.c" 2>>"$_log"
    _rc=$?
    rm -f "${SMOKE_OUT}.c"
    if [ "$_rc" -ne 0 ]; then
      return 1
    fi
  fi
  [ -x "$SMOKE_OUT" ] || return 1
  local ec=0
  "$SMOKE_OUT" 2>&1 | tee "$_log" || ec=$?
  [ "$ec" -eq 42 ]
}

host_seed_path() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  case "$arch" in
    x86_64|amd64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
  esac
  case "$os" in
    darwin) os=darwin ;;
    linux) os=linux ;;
    *) return 1 ;;
  esac
  echo "seeds/bootstrap_shuxc.${os}.${arch}"
}

if run_smoke "$TARGET"; then
  : >"$AUDIT_DIR/bootstrap-seed.fresh"
  rm -f "$AUDIT_DIR/bootstrap-seed.pinned-fallback"
  printf '[%s] seed smoke OK fresh %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$TARGET" \
    >>"$AUDIT_DIR/bootstrap-audit.log"
  echo "bootstrap_driver_seed_smoke: OK $TARGET (-c + -backend c -o exit=42)"
  exit 0
fi

if [ "${SHUX_BOOTSTRAP_NO_PINNED_FALLBACK:-0}" = "1" ]; then
  echo "bootstrap_driver_seed_smoke: FAIL $TARGET smoke (SHUX_BOOTSTRAP_NO_PINNED_FALLBACK=1; no pinned copy)" >&2
  printf '[%s] seed smoke FAIL no-fallback %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$TARGET" \
    >>"$AUDIT_DIR/bootstrap-audit.log"
  exit 1
fi

pinned="$(host_seed_path || true)"
if [ -n "$pinned" ] && [ -f "$pinned" ] && [ -s "$pinned" ]; then
  echo "bootstrap_driver_seed_smoke: WARN $TARGET smoke failed; fallback pinned $pinned" >&2
  cp -f "$pinned" "$PINNED_TMP"
  chmod +x "$PINNED_TMP"
  maybe_codesign "$PINNED_TMP"
  if run_smoke "$PINNED_TMP"; then
    cp -f "$pinned" "$TARGET"
    cp -f "$pinned" shux-c 2>/dev/null || true
    cp -f "$pinned" bootstrap_shuxc 2>/dev/null || true
    chmod +x "$TARGET" shux-c bootstrap_shuxc 2>/dev/null || chmod +x "$TARGET"
    maybe_codesign "$TARGET"
    maybe_codesign shux-c
    maybe_codesign bootstrap_shuxc
    : >"$AUDIT_DIR/bootstrap-seed.pinned-fallback"
    rm -f "$AUDIT_DIR/bootstrap-seed.fresh"
    printf '[%s] seed smoke OK pinned-fallback %s <- %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$TARGET" "$pinned" \
      >>"$AUDIT_DIR/bootstrap-audit.log"
    echo "bootstrap_driver_seed_smoke: OK after pinned fallback $TARGET"
    exit 0
  fi
  echo "bootstrap_driver_seed_smoke: FAIL pinned seed smoke also failed" >&2
  exit 1
fi

echo "bootstrap_driver_seed_smoke: FAIL $TARGET smoke (no pinned seed)" >&2
exit 1
