#!/usr/bin/env bash
# E-03 v2 preprocess：preprocess.c / preprocess_for_driver.o 软退役门禁（默认不链）。
#
# 用法：./tests/run-e03-preprocess-soft-gate.sh
# 环境：
# 2026-08-26: soft XLANG_E03_PREPROCESS_FAIL retired (die always hard).
#   XLANG_E03_PREPROCESS_MANIFEST_ONLY=1 — 仅 manifest
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# monofile seeds/runtime.from_x.c retired wave321；
# preprocess.c hard-retired (G-02a)；Makefile deleted MG wave941 →
# compiler/mk/driver_seed_link_picks.mk PREPROCESS_LINK_O（refuse resurrect）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_E03_PREPROCESS_DOC:-analysis/archive/phase/phase-e-e03-v2-preprocess.md}"
MK_PICKS="${XLANG_E03_MK_PICKS:-compiler/mk/driver_seed_link_picks.mk}"
PIPELINE_ABI_C="compiler/seeds/runtime_pipeline_abi.from_x.c"
PREPROCESS_X="compiler/src/preprocess/preprocess.x"

die() {
  echo "e03-preprocess gate FAIL: $*" >&2
  exit 1
}

echo "=== E-03 v2 preprocess: soft-retire (live mk PREPROCESS_LINK_O) ==="
for f in "$DOC" "$MK_PICKS" "$PIPELINE_ABI_C" "$PREPROCESS_X"; do
  [ -f "$f" ] || die "missing $f"
done

if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_link_picks.mk + ./xbuild)"
fi
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected"
fi
if [ -f compiler/src/preprocess.c ]; then
  die "compiler/src/preprocess.c resurrected (hard-retired; live = preprocess.x)"
fi

grep -q 'E-03 v2 preprocess' "$DOC" || die "doc missing E-03 v2 preprocess marker"
grep -q 'PREPROCESS_LINK_O' "$MK_PICKS" || die "$MK_PICKS missing PREPROCESS_LINK_O"
grep -q 'XLANG_LEGACY_PREPROCESS_C\|LEGACY_PREPROCESS' "$MK_PICKS" "$PIPELINE_ABI_C" 2>/dev/null \
  || grep -q 'XLANG_LEGACY_PREPROCESS_C' "$PIPELINE_ABI_C" \
  || die "pipeline_abi / mk missing XLANG_LEGACY_PREPROCESS_C face"
grep -q 'XLANG_LEGACY_PREPROCESS_C' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.inc missing XLANG_LEGACY_PREPROCESS_C branch"
grep -q 'xlang_preprocess' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.inc missing xlang_preprocess default path"

# Default PREPROCESS_LINK_O must be empty.
grep -qE '^PREPROCESS_LINK_O[[:space:]]*=' "$MK_PICKS" || die "$MK_PICKS missing PREPROCESS_LINK_O assignment"
if grep -qE '^PREPROCESS_LINK_O[[:space:]]*=[[:space:]]*[^[:space:]]' "$MK_PICKS"; then
  die "$MK_PICKS PREPROCESS_LINK_O default must be empty"
fi

# DRIVER_SEED must not hardcode preprocess_for_driver.o in composites.
MK_COMPOSITES="${XLANG_E03_MK_COMPOSITES:-compiler/mk/driver_seed_composites.mk}"
[ -f "$MK_COMPOSITES" ] || die "missing $MK_COMPOSITES"
if grep -q 'preprocess_for_driver\.o' "$MK_COMPOSITES" 2>/dev/null; then
  die "$MK_COMPOSITES still hardcodes preprocess_for_driver.o (use PREPROCESS_LINK_O)"
fi

echo "e03 track: preprocess.c hard-retired; live preprocess.x + pipeline xlang_preprocess"
echo "e03 track: monofile XLANG_RUNTIME_PREPROCESS macro retired with runtime.from_x.c"

if [ "${XLANG_E03_PREPROCESS_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e03 preprocess soft-retire gate OK (manifest only)"
  exit 0
fi

echo "e03 preprocess soft-retire gate OK (default PREPROCESS_LINK_O=empty; archive DOC)"
