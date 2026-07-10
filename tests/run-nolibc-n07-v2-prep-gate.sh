#!/usr/bin/env bash
# NL-07 v2 prep：编译器 bootstrap nostdlib 首试门禁（manifest + 桩 .o 编译）。
#
# 用法：./tests/run-nolibc-n07-v2-prep-gate.sh
# 环境：
#   SHUX_NOLIBC_N07_V2_FAIL=1       — 失败时硬退出
#   SHUX_NOLIBC_N07_V2_TRY_LINK=1   — Linux x86_64 上编译桩 + freestanding_io（不跑全量 build_shux_asm）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N07_V2_FAIL:-0}
DOC="analysis/phase-f-n07-v2.md"
MANIFEST="tests/baseline/nolibc-n07-v2-prep.tsv"
STUBS="compiler/src/asm/bootstrap_nostdlib_stubs.inc"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"

die() {
  echo "nolibc-n07-v2 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-07 v2 prep: bootstrap nostdlib first try ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v2' "$DOC" || die "doc missing NL-07 v2 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$STUBS" ] || die "missing $STUBS"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
grep -q 'SHUX_BOOTSTRAP_NOSTDLIB' "$BUILD_ASM" || die "build_shux_asm missing SHUX_BOOTSTRAP_NOSTDLIB"
grep -q 'bootstrap_nostdlib_stubs' "$BUILD_ASM" || die "build_shux_asm missing bootstrap_nostdlib_stubs"
grep -q 'bootstrap_nostdlib_stubs' compiler/Makefile || die "Makefile missing bootstrap_nostdlib_stubs rule"

while IFS=$'\t' read -r item_id category anchor check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    exists)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    grep)
      if [ ! -f "$anchor" ] || ! grep -qF "$notes" "$anchor" 2>/dev/null; then
        die "grep fail: $anchor need '$notes' ($item_id)"
      fi
      ;;
    gate_ref)
      [ -f "$anchor" ] || die "missing gate $anchor ($item_id)"
      ;;
  esac
done < "$MANIFEST"

echo "=== NL-07 v2: compile bootstrap_nostdlib_stubs.o ==="
make -C compiler src/asm/bootstrap_nostdlib_stubs.o >/dev/null 2>&1 || die "make bootstrap_nostdlib_stubs.o failed"

if [ "${SHUX_NOLIBC_N07_V2_TRY_LINK:-0}" = "1" ]; then
  if [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ]; then
    echo "=== NL-07 v2: compile freestanding_io_x86_64.o (link smoke prep) ==="
    make -C compiler src/asm/freestanding_io_x86_64.o >/dev/null 2>&1 || die "make freestanding_io_x86_64.o failed"
    echo "nolibc-n07-v2: freestanding_io + stubs OK (full crt0 link → SHUX_BOOTSTRAP_NOSTDLIB=1 build_shux_asm)"
  else
    echo "nolibc-n07-v2 SKIP link try (need Linux x86_64)" >&2
  fi
fi

echo "nolibc-n07-v2 gate OK (bootstrap nostdlib prep v2)"
