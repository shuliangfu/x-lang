#!/usr/bin/env bash
# bootstrap_driver_seed_smoke.sh — bootstrap-driver-seed 产出 shux 的 -c/-o 烟测；失败则回退 pinned seed
#
# 用法（compiler 目录）：
#   ./scripts/bootstrap_driver_seed_smoke.sh [path/to/shux]
#
# 成功：exit 0，stdout 打印 OK
# 失败且存在 seeds/bootstrap_shuxc.<os>.<arch>：复制为 shux/shux-c/bootstrap_shuxc 并 exit 0（WARN）
# 失败且无 pinned seed：exit 1

set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-./shux}"
SMOKE_SRC="/tmp/shux_bootstrap_seed_smoke.$$.sx"
SMOKE_OUT="/tmp/shux_bootstrap_seed_smoke_out.$$"

cleanup() {
  rm -f "$SMOKE_SRC" "$SMOKE_OUT" 2>/dev/null || true
}
trap cleanup EXIT

if [ ! -x "$TARGET" ]; then
  echo "bootstrap_driver_seed_smoke: not executable: $TARGET" >&2
  exit 1
fi

printf '%s\n' 'function main(): i32 { return 42; }' >"$SMOKE_SRC"

# run_smoke — 对 bootstrap seed 编译器做 -c 与 -o 烟测。
# bootstrap seed 默认 asm -o 会链入 std/*.o 缺 C bridge（ld 失败）或 SIGSEGV；-backend c 走 C 后端可执行链。
# 参数：bin — 待测 shux 路径；成功返回 0。
run_smoke() {
  local bin="$1"
  local _log="/tmp/shux_bootstrap_seed_smoke_$$.log"
  local _rc=0
  # 非 TTY stdout 重定向会挂起/SIGTERM；须 tee|cat Drain；用 PIPESTATUS[0] 取 shux 真实退出码。
  "$bin" -c "$SMOKE_SRC" 2>&1 | tee "$_log" | cat >/dev/null
  _rc="${PIPESTATUS[0]:-1}"
  if [ "$_rc" -ne 0 ]; then
    return 1
  fi
  rm -f "$SMOKE_OUT"
  "$bin" -backend c -o "$SMOKE_OUT" "$SMOKE_SRC" 2>&1 | tee "$_log" | cat >/dev/null
  _rc="${PIPESTATUS[0]:-1}"
  if [ "$_rc" -ne 0 ]; then
    return 1
  fi
  [ -x "$SMOKE_OUT" ] || return 1
  local ec=0
  "$SMOKE_OUT" 2>&1 | tee "$_log" | cat >/dev/null || ec=$?
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
  echo "bootstrap_driver_seed_smoke: OK $TARGET (-c + -backend c -o exit=42)"
  exit 0
fi

pinned="$(host_seed_path || true)"
if [ -n "$pinned" ] && [ -f "$pinned" ] && [ -s "$pinned" ]; then
  echo "bootstrap_driver_seed_smoke: WARN $TARGET smoke failed; fallback pinned $pinned" >&2
  cp -f "$pinned" "$TARGET"
  cp -f "$pinned" shux-c 2>/dev/null || true
  cp -f "$pinned" bootstrap_shuxc 2>/dev/null || true
  chmod +x "$TARGET" shux-c bootstrap_shuxc 2>/dev/null || chmod +x "$TARGET"
  if run_smoke "$TARGET"; then
    echo "bootstrap_driver_seed_smoke: OK after pinned fallback $TARGET"
    exit 0
  fi
  echo "bootstrap_driver_seed_smoke: FAIL pinned seed smoke also failed" >&2
  exit 1
fi

echo "bootstrap_driver_seed_smoke: FAIL $TARGET smoke (no pinned seed)" >&2
exit 1
