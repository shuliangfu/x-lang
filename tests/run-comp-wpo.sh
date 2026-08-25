#!/usr/bin/env bash
# COMP-004：WPO v1 轻量烟测（DCE + S1）
#
# 用法：./tests/run-comp-wpo.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

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
  echo "comp-wpo FAIL (no native xlang/xlang_asm/xlang-c, host=$(uname -s)/$(uname -m 2>/dev/null))" >&2
  exit 1
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

echo "=== COMP-004: WPO smoke (XLANG=$XLANG_C) ==="
chmod +x tests/run-wpo-dce-emit.sh tests/run-wpo-s1.sh
# Honesty 2026-08-25: WPO_DUMP_CALLGRAPH product path hard-green via
# pipeline_typeck_wpo_dump_callgraph (thin inject; no mega). S1 must hard-fail
# if graph missing. DCE emit remains observational (separate -E path).
# PLATFORM: SHARED.
set +e
XLANG="$XLANG_C" ./tests/run-wpo-dce-emit.sh
dce_ec=$?
XLANG="$XLANG_C" ./tests/run-wpo-s1.sh
s1_ec=$?
set -e
if [ "$s1_ec" -ne 0 ]; then
  echo "comp-wpo FAIL s1 (WPO_DUMP_CALLGRAPH product dump; s1=$s1_ec)" >&2
  exit 1
fi
echo "comp-wpo OK s1"
if [ "$dce_ec" -eq 0 ]; then
  echo "comp-wpo OK dce"
else
  echo "comp-wpo NOTE dce observational (dce=$dce_ec)"
fi

echo "comp-wpo OK"
