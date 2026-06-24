#!/usr/bin/env bash
# E-03 v2 preprocess：preprocess.c / preprocess_for_driver.o 软退役门禁（默认不链，文件保留）。
#
# 用法：./tests/run-e03-preprocess-soft-gate.sh
# 环境：
#   SHUX_E03_PREPROCESS_FAIL=1       — 失败时硬退出
#   SHUX_E03_PREPROCESS_MANIFEST_ONLY=1 — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E03_PREPROCESS_FAIL:-0}
DOC="analysis/phase-e-e03-v2-preprocess.md"
MF="compiler/Makefile"
RUNTIME="compiler/src/runtime.c"
PIPELINE_ABI_C="compiler/src/runtime_pipeline_abi.c"
PREPROCESS_C="compiler/src/preprocess.c"

die() {
  echo "e03-preprocess gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-03 v2 preprocess: preprocess.c soft-retire (default no preprocess_for_driver.o) ==="
for f in "$DOC" "$MF" "$RUNTIME" "$PIPELINE_ABI_C" "$PREPROCESS_C"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-03 v2 preprocess' "$DOC" || die "doc missing E-03 v2 preprocess marker"
grep -q 'PREPROCESS_LINK_O' "$MF" || die "Makefile missing PREPROCESS_LINK_O"
grep -q 'SHUX_LEGACY_PREPROCESS_C' "$MF" || die "Makefile missing SHUX_LEGACY_PREPROCESS_C"
grep -q 'RUNTIME_PIPELINE_ABI_CFLAGS' "$MF" || die "Makefile missing RUNTIME_PIPELINE_ABI_CFLAGS (E-04 v32)"
grep -q 'Phase E soft-retired' "$PREPROCESS_C" || die "preprocess.c missing Phase E marker"
grep -q 'SHUX_LEGACY_PREPROCESS_C' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing SHUX_LEGACY_PREPROCESS_C branch"
grep -q 'shux_preprocess' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_preprocess default path"
grep -q 'SHUX_RUNTIME_PREPROCESS' "$RUNTIME" || die "runtime.c missing SHUX_RUNTIME_PREPROCESS macro"

# DRIVER_SEED_OBJS 默认不得硬编码 preprocess_for_driver.o
if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MF" | grep -q 'preprocess_for_driver\.o'; then
  die "DRIVER_SEED_OBJS still hardcodes preprocess_for_driver.o (use PREPROCESS_LINK_O)"
fi

# 默认 PREPROCESS_LINK_O 须为空
if ! awk '/^ifeq \(\$\(SHUX_LEGACY_PREPROCESS_C\),1\)/,/^endif/' "$MF" | grep -q '^PREPROCESS_LINK_O =$'; then
  die "Makefile E-03 block missing empty PREPROCESS_LINK_O default"
fi

# bootstrap 链接行不得硬编码 preprocess_for_driver.o
if grep -E 'bootstrap-driver-seed:|^shux-sx:' "$MF" | grep -q 'preprocess_for_driver\.o'; then
  die "Makefile bootstrap link still hardcodes preprocess_for_driver.o"
fi

echo "e03 track: OBJS / shux-c still lists src/preprocess.o (cold start; defer E-03 v3)"
echo "e03 track: build_shux_asm SEED still cc -c lexer/ast/preprocess (strict relink archaeology; defer E-03 v3)"

if [ "${SHUX_E03_PREPROCESS_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e03 preprocess soft-retire gate OK (manifest only)"
  exit 0
fi

echo "e03 preprocess soft-retire gate OK (default PREPROCESS_LINK_O=empty; LEGACY=SHUX_LEGACY_PREPROCESS_C=1)"
