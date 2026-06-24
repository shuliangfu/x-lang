#!/usr/bin/env bash
# NL-07 v5：bootstrap nostdlib 硬绿（默认 nostdlib + ldd 无 libc.so）。
#
# 用法：./tests/run-nolibc-n07-v5-gate.sh
# 环境：
#   SHUX_NOLIBC_N07_V5_FAIL=1           — 失败时硬退出
#   SHUX_NOLIBC_N07_V5_MANIFEST_ONLY=1  — 仅 manifest
#   SHUX_NOLIBC_N07_V5_TRY_BUILD=1      — shux_asm 存在时试跑并 ldd 审计
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N07_V5_FAIL:-0}
DOC="analysis/phase-f-n07-v5.md"
MANIFEST="tests/baseline/nolibc-n07-v5.tsv"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"
SHUX_ASM="compiler/shux_asm"

die() {
  echo "nolibc-n07-v5 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-07 v5: bootstrap nostdlib hard green ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v5' "$DOC" || die "doc missing NL-07 v5 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
grep -q 'NL-07 v5' "$BUILD_ASM" || die "build_shux_asm missing NL-07 v5 marker"
grep -q 'SHUX_BOOTSTRAP_ALLOW_LIBC' "$BUILD_ASM" || die "missing SHUX_BOOTSTRAP_ALLOW_LIBC escape"

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

if [ "${SHUX_NOLIBC_N07_V5_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc-n07-v5 gate OK (manifest only)"
  exit 0
fi

if [ "${SHUX_NOLIBC_N07_V5_TRY_BUILD:-0}" != "1" ]; then
  echo "nolibc-n07-v5 gate OK (manifest; set SHUX_NOLIBC_N07_V5_TRY_BUILD=1 + shux_asm for ldd audit)"
  exit 0
fi

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc-n07-v5 SKIP build try (need Linux x86_64)" >&2
  echo "nolibc-n07-v5 gate OK (manifest; build try skipped)"
  exit 0
fi

if [ ! -x "$SHUX_ASM" ]; then
  echo "nolibc-n07-v5 SKIP build try (no $SHUX_ASM)" >&2
  echo "nolibc-n07-v5 gate OK (manifest; no shux_asm)"
  exit 0
fi

echo "=== NL-07 v5: default nostdlib build_shux_asm + ldd audit ==="
LOG="/tmp/shux_n07_v5_build.log"
rm -f "$LOG" 2>/dev/null || true
set +e
( cd compiler && unset SHUX_BOOTSTRAP_ALLOW_LIBC SHUX_BOOTSTRAP_NOSTDLIB; ./scripts/build_shux_asm.sh ) 2>&1 | tee "$LOG"
RC=${PIPESTATUS[0]}
set -e

if [ "$RC" -ne 0 ] || [ ! -x "$SHUX_ASM" ]; then
  echo "nolibc-n07-v5: build failed rc=$RC" >&2
  grep "undefined reference" "$LOG" 2>/dev/null | sed 's/.*undefined reference to /  /' | sort -u | head -30 >&2 || true
  die "nostdlib default build failed"
fi

if ! grep -q 'bootstrap nostdlib crt0 link OK' "$LOG" 2>/dev/null \
  && ! grep -q 'bootstrap nostdlib.*link OK' "$LOG" 2>/dev/null; then
  die "build succeeded but nostdlib path not taken (check SHUX_BOOTSTRAP_ALLOW_LIBC or fallback -lc)"
fi

if command -v ldd >/dev/null 2>&1; then
  if ldd "$SHUX_ASM" 2>/dev/null | grep -q 'libc\.so'; then
    ldd "$SHUX_ASM" 2>&1 | head -20 >&2 || true
    die "ldd shows libc.so on shux_asm (nostdlib hard green violated)"
  fi
  echo "nolibc-n07-v5: ldd OK (no libc.so)"
else
  echo "nolibc-n07-v5: ldd not available (skip dynamic audit)"
fi

echo "nolibc-n07-v5 gate OK (default nostdlib + ldd audit)"
