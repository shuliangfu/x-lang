#!/usr/bin/env sh
# bootstrap_xlangc_create.sh — 从当前 xlang_asm / xlang 生成冷启动种子 bootstrap_xlangc（G-06）
#
# 用法（compiler 目录）：
#   ./scripts/bootstrap_xlangc_create.sh
#   ./scripts/bootstrap_xlangc_create.sh /path/to/custom/xlang
#
# 产出：compiler/bootstrap_xlangc（与宿主 Mach-O/ELF 同架构，供无 C 源码克隆冷启动）。

set -e
cd "$(dirname "$0")/.."

OUT="./bootstrap_xlangc"
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
  if [ -x ./scripts/select_bootstrap_xlangc.sh ]; then
    chmod +x ./scripts/select_bootstrap_xlangc.sh 2>/dev/null || true
    if ./scripts/select_bootstrap_xlangc.sh --print >/dev/null 2>&1; then
      echo "./bootstrap_xlangc"
      return 0
    fi
  fi
  if [ -x ./xlang ]; then
    echo "./xlang"
    return 0
  fi
  if [ -x ./xlang_asm ]; then
    echo "./xlang_asm"
    return 0
  fi
  return 1
}

if ! pick_src >/dev/null 2>&1; then
  echo "bootstrap_xlangc_create: need xlang_asm or xlang (or pass path)" >&2
  exit 1
fi

SRC="$(pick_src)"
cp -f "$SRC" "$OUT"
chmod +x "$OUT"
maybe_codesign "$OUT"
echo "bootstrap_xlangc_create: OK $OUT <- $SRC ($(wc -c <"$OUT" | tr -d ' ') bytes)"
