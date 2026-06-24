#!/usr/bin/env bash
# D-01 v1：Stage 0（seed）→ Stage 1（shux_asm B-strict）门禁。
#
# 用法：./tests/run-d01-stage0-to-stage1-gate.sh
# 环境：
#   SHUX_D01_FAIL=1              — 失败时硬退出
#   SHUX_D01_BUILD_LOG=/path       — 可选 bstrict 构建日志
#   SHUX_D01_MANIFEST_ONLY=1       — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_D01_FAIL:-0}
DOC="analysis/phase-d-d01-v1.md"
MANIFEST="tests/baseline/d01-stage0-to-stage1.tsv"
MF="compiler/Makefile"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"
LOG="${SHUX_D01_BUILD_LOG:-/tmp/build_bstrict.log}"
SHUX_ASM="compiler/shux_asm"

die() {
  echo "d01 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

d01_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== D-01: Stage0 seed → Stage1 shux_asm (v1) ==="
for f in "$DOC" "$MANIFEST" "$MF" "$BUILD_ASM" compiler/bootstrap.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-01 v1' "$DOC" || die "doc missing D-01 v1 marker"

grep -q 'bootstrap-driver-seed' "$MF" || die "Makefile missing bootstrap-driver-seed"
grep -q 'bootstrap-driver-bstrict' "$MF" || die "Makefile missing bootstrap-driver-bstrict"
grep -q 'SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1' "$MF" || die "Makefile bstrict missing SKIP_GEN"
grep -q 'bootstrap-driver-seed' "$BUILD_ASM" || die "build_shux_asm missing seed reference"

MISS=0
while IFS=$'\t' read -r item_id _layer anchor check_type _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    [ -f "$anchor" ] || { echo "d01 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"

if [ "${SHUX_D01_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "d01 stage0-to-stage1 gate OK (manifest only)"
  exit 0
fi

if [ -f "$LOG" ]; then
  grep -qE 'Target-B-strict|B-strict OK|LINK_MODE=asm_only_strict' "$LOG" || \
    die "build log missing B-strict markers ($LOG)"
  echo "d01 OK: audited build log $LOG"
fi

if ! d01_native_exe "$SHUX_ASM"; then
  echo "d01 stage0-to-stage1 gate: SKIP (no native $SHUX_ASM; manifest OK)"
  exit 0
fi

# Stage 1 须可执行且具备 asm 后端（区别于纯 shux-c）
if ! "$SHUX_ASM" --help 2>/dev/null | grep -qE '\-backend|backend'; then
  die "$SHUX_ASM missing -backend (not Stage1 asm compiler?)"
fi

echo "d01 stage0-to-stage1 gate OK (Stage1=$SHUX_ASM native executable)"
