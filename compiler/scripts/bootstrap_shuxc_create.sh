#!/usr/bin/env sh
# bootstrap_shuxc_create.sh — 从当前 shux_asm / shux 生成冷启动种子 bootstrap_shuxc（G-06）
#
# 用法（compiler 目录）：
#   ./scripts/bootstrap_shuxc_create.sh
#   ./scripts/bootstrap_shuxc_create.sh /path/to/custom/shux
#
# 产出：compiler/bootstrap_shuxc（与宿主 Mach-O/ELF 同架构，供无 C 源码克隆冷启动）。

set -e
cd "$(dirname "$0")/.."

OUT="./bootstrap_shuxc"
SRC="${1:-}"

maybe_codesign() {
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ] && command -v codesign >/dev/null 2>&1; then
    codesign -s - --force "$1" >/dev/null 2>&1 || true
  fi
}

pick_src() {
  if [ -n "$SRC" ] && [ -x "$SRC" ]; then
    echo "$SRC"
    return 0
  fi
  if [ -x ./scripts/select_bootstrap_shuxc.sh ]; then
    chmod +x ./scripts/select_bootstrap_shuxc.sh 2>/dev/null || true
    if ./scripts/select_bootstrap_shuxc.sh --print >/dev/null 2>&1; then
      echo "./bootstrap_shuxc"
      return 0
    fi
  fi
  if [ -x ./shux ]; then
    echo "./shux"
    return 0
  fi
  if [ -x ./shux_asm ]; then
    echo "./shux_asm"
    return 0
  fi
  return 1
}

if ! pick_src >/dev/null 2>&1; then
  echo "bootstrap_shuxc_create: need shux_asm or shux (or pass path)" >&2
  exit 1
fi

SRC="$(pick_src)"
cp -f "$SRC" "$OUT"
chmod +x "$OUT"
maybe_codesign "$OUT"
echo "bootstrap_shuxc_create: OK $OUT <- $SRC ($(wc -c <"$OUT" | tr -d ' ') bytes)"
