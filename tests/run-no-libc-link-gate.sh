#!/usr/bin/env bash
# NL-05：freestanding 用户链接策略门禁（runtime 块无 -lc；编译器 bootstrap track-only）。
#
# 用法：./tests/run-no-libc-link-gate.sh
# 环境：
#   SHUX_NOLIBC_LINK_FAIL=1           — 失败时硬退出
#   SHUX_NOLIBC_LINK_MANIFEST_ONLY=1  — 仅 manifest + runtime 审计
#   SHUX_NOLIBC_LINK_SKIP_SMOKE=1     — 跳过 heap/fs 烟测（聚合 gate 已跑时）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_LINK_FAIL:-0}
DOC="analysis/phase-f-no-libc-v1.md"
POLICY="tests/baseline/no-libc-link-policy.tsv"
RT="compiler/src/runtime_link_abi.inc"
DRIVER="compiler/src/driver/compile.x"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"

die() {
  echo "nolibc-link gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-05: freestanding link policy (no -lc for user programs) ==="
for f in "$DOC" "$POLICY" "$RT" "$DRIVER" "$BUILD_ASM"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'NL-05' "$DOC" || die "phase doc missing NL-05"

# shellcheck source=tests/lib/no-libc-link-audit.sh
. tests/lib/no-libc-link-audit.sh
if ! nolibc_audit_runtime_freestanding_block "$RT"; then
  die "runtime freestanding block audit failed"
fi
echo "nolibc-link OK: runtime NL-05 block has -nostdlib, no -lc"

grep -q 'freestanding' "$DRIVER" || die "driver compile.x missing -freestanding"

TRACK=$(nolibc_track_compiler_lc_mentions)
echo "nolibc-link track: compiler bootstrap files with -lc mentions = $TRACK (expected until F-07; not blocking v1)"

if [ "${SHUX_NOLIBC_LINK_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc-link gate OK (manifest + runtime audit)"
  exit 0
fi

# 委托 NL-03/04 烟测：实际链接产物无 libc.so（聚合 gate 可设 SKIP_SMOKE=1）
if [ "${SHUX_NOLIBC_LINK_SKIP_SMOKE:-0}" != "1" ]; then
  if [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ]; then
    chmod +x tests/run-no-libc-heap-gate.sh tests/run-no-libc-fs-gate.sh
    SHUX_NOLIBC_HEAP_FAIL="$FAIL" ./tests/run-no-libc-heap-gate.sh || die "heap smoke link failed"
    SHUX_NOLIBC_FS_FAIL="$FAIL" ./tests/run-no-libc-fs-gate.sh || die "fs smoke link failed"
  else
    echo "nolibc-link gate: SKIP runtime smokes (need Linux x86_64)"
  fi
fi

echo "nolibc-link gate OK (user freestanding nostdlib; compiler -lc track-only)"
