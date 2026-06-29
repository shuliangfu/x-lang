#!/usr/bin/env sh
# select_bootstrap_shuxc.sh — 按宿主 OS/CPU 选择可执行的 bootstrap_shuxc（G-06 多架构种子）
#
# 用法（compiler 目录）：
#   ./scripts/select_bootstrap_shuxc.sh          # 确保 ./bootstrap_shuxc 可执行
#   ./scripts/select_bootstrap_shuxc.sh --print    # 仅打印选用的种子路径
#
# 查找顺序：
#   1) 当前 ./bootstrap_shuxc 若可执行
#   2) ./seeds/bootstrap_shuxc.<os>.<arch>（如 linux.x86_64 / darwin.arm64）
#   3) 可执行的 ./shux 或 ./shux_asm（并复制为 bootstrap_shuxc）

set -e
cd "$(dirname "$0")/.."

PRINT_ONLY=0
if [ "${1:-}" = "--print" ]; then
  PRINT_ONLY=1
fi

can_run() {
  [ -x "$1" ] || return 1
  if command -v file >/dev/null 2>&1; then
    ft="$(file -b "$1" 2>/dev/null || true)"
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Darwin-arm64) echo "$ft" | grep -qi "arm64" || return 1 ;;
      Darwin-x86_64) echo "$ft" | grep -qi "x86_64" || return 1 ;;
      Linux-x86_64|Linux-amd64) echo "$ft" | grep -qi "x86-64" || return 1 ;;
      Linux-aarch64|Linux-arm64) echo "$ft" | grep -qi "aarch64\|ARM" || return 1 ;;
      FreeBSD-*) echo "$ft" | grep -qi "ELF.*x86-64\|ELF.*aarch64" || return 1 ;;
    esac
  fi
  tmp="/tmp/shux_can_run_$$.sx"
  obj="/tmp/shux_can_run_out_$$.o"
  out="/tmp/shux_can_run_out_$$.c"
  printf '%s\n' 'function main(): i32 { return 0; }' >"$tmp"
  if "$1" -c "$tmp" -o "$obj" >/dev/null 2>&1 && [ -s "$obj" ]; then
    rm -f "$tmp" "$obj" "$out" 2>/dev/null || true
    return 0
  fi
  if "$1" -E "$tmp" >"$out" 2>/dev/null && [ -s "$out" ]; then
    rm -f "$tmp" "$obj" "$out" 2>/dev/null || true
    return 0
  fi
  rm -f "$tmp" "$obj" "$out" 2>/dev/null || true
  return 1
}

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
case "$arch" in
  x86_64|amd64) arch="x86_64" ;;
  aarch64|arm64) arch="arm64" ;;
esac
case "$os" in
  darwin) os="darwin" ;;
  linux) os="linux" ;;
  freebsd) os="freebsd" ;;
esac

seed_var="seeds/bootstrap_shuxc.${os}.${arch}"

pick=""
if [ -f "$seed_var" ]; then
  chmod +x "$seed_var" 2>/dev/null || true
  if can_run "$seed_var"; then
    cp -f "$seed_var" ./bootstrap_shuxc
    chmod +x ./bootstrap_shuxc
    pick="./bootstrap_shuxc"
  fi
fi
if [ -z "$pick" ] && can_run ./bootstrap_shuxc; then
  pick="./bootstrap_shuxc"
fi

if [ -z "$pick" ]; then
  if can_run ./shux-c; then
    cp -f ./shux-c ./bootstrap_shuxc
    chmod +x ./bootstrap_shuxc
    pick="./bootstrap_shuxc"
  elif can_run ./shux; then
    ./scripts/bootstrap_shuxc_create.sh ./shux
    pick="./bootstrap_shuxc"
  elif can_run ./shux_asm; then
    ./scripts/bootstrap_shuxc_create.sh ./shux_asm
    pick="./bootstrap_shuxc"
  fi
fi

if [ -z "$pick" ] || ! can_run ./bootstrap_shuxc; then
  echo "select_bootstrap_shuxc: no runnable seed (tried bootstrap_shuxc, $seed_var, shux, shux_asm)" >&2
  exit 1
fi

if [ "$PRINT_ONLY" -eq 1 ]; then
  echo "$pick"
  exit 0
fi

echo "select_bootstrap_shuxc: OK $pick (${os}.${arch})"
# G-06：shux-c 须与宿主同架构（Docker Linux 勿沿用 macOS Mach-O shux-c）。
if [ "$PRINT_ONLY" -eq 0 ] && [ -f ./bootstrap_shuxc ]; then
  cp -f ./bootstrap_shuxc ./shux-c
fi
