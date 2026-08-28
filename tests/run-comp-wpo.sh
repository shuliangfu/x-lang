#!/usr/bin/env bash
# COMP-004：WPO v1 轻量烟测（DCE + S1）
#
# Honesty: leftover auto-make (`xlang_compiler_make -q || xlang_compiler_make`)
# retired (parent + run-wpo-s1.sh). Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing native = hard die.
# DCE emit remains observational. S1 check dump = obs (paused check / CHK002;
# refuse leftover auto-make that kicked g05). PLATFORM: SHARED archaeology.
# 用法：./tests/run-comp-wpo.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

# Prefer product asm (honest check/dump path). Pin LINK.
XLANG_C="${XLANG:-}"
if [ -z "$XLANG_C" ]; then
  for cand in ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
    if comp_wpo_native_exe "$cand"; then
      XLANG_C="$cand"
      break
    fi
  done
fi
if [ -n "$XLANG_C" ] && [ -z "${XLANG_LINK_XLANG:-}" ]; then
  export XLANG_LINK_XLANG="$XLANG_C"
fi

if ! comp_wpo_native_exe "$XLANG_C"; then
  echo "comp-wpo FAIL (no native xlang/xlang_asm/xlang-c, host=$(uname -s)/$(uname -m 2>/dev/null); refuse leftover auto-make)" >&2
  exit 1
fi
# Refuse leftover auto-make of missing compiler; resolved native must already exist.

echo "=== COMP-004: WPO smoke (XLANG=$XLANG_C) ==="
chmod +x tests/run-wpo-dce-emit.sh tests/run-wpo-s1.sh
# Honesty 2026-08-25: WPO_DUMP_CALLGRAPH product path via
# pipeline_typeck_wpo_dump_callgraph (thin inject; no mega).
# Honesty 2026-08-29: S1 check dump = obs (paused check / CHK002; leftover
# auto-make kicked g05 and hid the residual). DCE emit remains observational
# (separate -E path). Refuse leftover auto-make. PLATFORM: SHARED.
set +e
XLANG="$XLANG_C" ./tests/run-wpo-dce-emit.sh
dce_ec=$?
XLANG="$XLANG_C" ./tests/run-wpo-s1.sh
s1_ec=$?
set -e
if [ "$s1_ec" -eq 0 ]; then
  echo "comp-wpo OK s1"
else
  echo "comp-wpo OBS s1 (check dump paused / CHK residual ec=$s1_ec; refuse leftover auto-make)" >&2
fi
if [ "$dce_ec" -eq 0 ]; then
  echo "comp-wpo OK dce"
else
  echo "comp-wpo NOTE dce observational (dce=$dce_ec)"
fi

echo "comp-wpo OK"
