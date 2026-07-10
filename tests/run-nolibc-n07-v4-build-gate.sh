#!/usr/bin/env bash
# NL-07 v4：bootstrap nostdlib 全链试跑门禁（track / 可选硬绿）。
#
# 用法：./tests/run-nolibc-n07-v4-build-gate.sh
# 环境：
#   SHUX_NOLIBC_N07_V4_FAIL=1           — 失败时硬退出
#   SHUX_NOLIBC_N07_V4_MANIFEST_ONLY=1  — 仅 manifest
#   SHUX_NOLIBC_N07_V4_TRY_BUILD=1      — shux_asm 存在时试跑 SHUX_BOOTSTRAP_NOSTDLIB=1 build_shux_asm
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N07_V4_FAIL:-0}
DOC="analysis/phase-f-n07-v4.md"
MANIFEST="tests/baseline/nolibc-n07-v4-build.tsv"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"
SHUX_ASM="compiler/shux_asm"

die() {
  echo "nolibc-n07-v4 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-07 v4: bootstrap nostdlib full-chain try (track) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v4' "$DOC" || die "doc missing NL-07 v4 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
grep -q 'bootstrap_link_tail_driver' "$BUILD_ASM" || die "build_shux_asm missing bootstrap_link_tail_driver"
[ -f compiler/src/runtime_driver_strict_glue_stubs.inc ] || die "missing runtime_driver_strict_glue_stubs.inc"

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

if [ "${SHUX_NOLIBC_N07_V4_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc-n07-v4 gate OK (manifest only)"
  exit 0
fi

if [ "${SHUX_NOLIBC_N07_V4_TRY_BUILD:-0}" != "1" ]; then
  echo "nolibc-n07-v4 gate OK (manifest; set SHUX_NOLIBC_N07_V4_TRY_BUILD=1 + shux_asm for full try)"
  exit 0
fi

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc-n07-v4 SKIP build try (need Linux x86_64)" >&2
  echo "nolibc-n07-v4 gate OK (manifest; build try skipped)"
  exit 0
fi

if [ ! -x "$SHUX_ASM" ]; then
  echo "nolibc-n07-v4 SKIP build try (no $SHUX_ASM; run bootstrap-driver-bstrict first)" >&2
  echo "nolibc-n07-v4 gate OK (manifest; no shux_asm)"
  exit 0
fi

echo "=== NL-07 v4: SHUX_BOOTSTRAP_NOSTDLIB=1 build_shux_asm ==="
LOG="/tmp/shux_n07_v4_build.log"
rm -f "$LOG" 2>/dev/null || true
set +e
( cd compiler && SHUX_BOOTSTRAP_NOSTDLIB=1 ./scripts/build_shux_asm.sh ) 2>&1 | tee "$LOG"
RC=${PIPESTATUS[0]}
set -e

if grep -q 'bootstrap nostdlib crt0 link OK' "$LOG" 2>/dev/null || \
   grep -q 'bootstrap nostdlib.*link OK' "$LOG" 2>/dev/null; then
  echo "nolibc-n07-v4: nostdlib link OK (crt0 path)"
elif [ "$RC" -eq 0 ] && [ -x "$SHUX_ASM" ]; then
  echo "nolibc-n07-v4: build_shux_asm exit 0 (check log for nostdlib vs fallback)"
else
  echo "nolibc-n07-v4: build failed rc=$RC" >&2
  grep "undefined reference" "$LOG" 2>/dev/null | sed 's/.*undefined reference to /  /' | sort -u | head -30 >&2 || true
  die "nostdlib full-chain try failed (track)"
fi

echo "nolibc-n07-v4 gate OK (full-chain try completed)"
