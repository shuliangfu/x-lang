#!/usr/bin/env bash
# NL-07 v1：编译器 bootstrap 去 libc 准备门禁（manifest + marker + lc 基线 track）。
#
# 用法：./tests/run-nolibc-n07-bootstrap-prep-gate.sh
# 环境：
#   SHUX_NOLIBC_N07_FAIL=1              — 失败时硬退出
#   SHUX_NOLIBC_N07_MANIFEST_ONLY=1     — 仅 manifest（跳过 B-32 委托）
#   SHUX_NOLIBC_N07_LC_HARD=1           — -lc 基线回归时硬失败（默认 track-only）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N07_FAIL:-0}
LC_HARD=${SHUX_NOLIBC_N07_LC_HARD:-0}
DOC="analysis/phase-f-n07-v1.md"
MANIFEST="tests/baseline/nolibc-n07-bootstrap-prep.tsv"
LC_BASELINE="tests/baseline/nolibc-n07-bootstrap-lc-track.tsv"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"

die() {
  echo "nolibc-n07 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-07: compiler bootstrap no-libc prep (track v1) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v1' "$DOC" || die "doc missing NL-07 v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$LC_BASELINE" ] || die "missing $LC_BASELINE"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"

# shellcheck source=tests/lib/nolibc-n07-bootstrap-audit.sh
. tests/lib/nolibc-n07-bootstrap-audit.sh

if ! nolibc_n07_audit_manifest "$MANIFEST"; then
  die "NL-07 bootstrap prep manifest audit failed"
fi

if ! nolibc_n07_audit_lc_baseline "$LC_BASELINE" "$LC_HARD"; then
  die "NL-07 lc baseline audit failed"
fi

lc_n=$(nolibc_n07_count_lc_link_cmds "$BUILD_ASM")
std_c_n=$(nolibc_n07_count_ensure_std_c "$BUILD_ASM")
echo "nolibc-n07: lc_link_cmds=${lc_n} ensure_std_c=${std_c_n} (track-only until NL-07 v2)"

if [ "${SHUX_NOLIBC_N07_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc-n07 gate OK (manifest + lc track only)"
  exit 0
fi

if [ -f tests/run-b32-no-cc-std-gate.sh ]; then
  echo "=== NL-07: delegate run-b32-no-cc-std-gate (B-32 track) ==="
  chmod +x tests/run-b32-no-cc-std-gate.sh
  ./tests/run-b32-no-cc-std-gate.sh || die "B-32 cc-std track failed"
fi

echo "nolibc-n07 gate OK (bootstrap -lc/.c track; enable nostdlib → NL-07 v2)"
