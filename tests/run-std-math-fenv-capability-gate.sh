#!/usr/bin/env bash
# STD-149：std.math fenv 能力检测门禁
#
# 用法：./tests/run-std-math-fenv-capability-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/std-math-fenv-capability-v1.md"
MANIFEST="tests/baseline/std-math-fenv-capability-manifest.tsv"
VECTORS="tests/baseline/std-math-fenv-capability.tsv"
MOD_X="std/math/mod.x"
MATH_RUNTIME="${SHUX_STD_MATH_IMPL:-compiler/seeds/runtime_math_libm.from_x.c}"
LIB="tests/lib/std-math-fenv-capability.sh"
SMOKE_X="tests/std-math/fenv_capability.x"
SMOKE_C="tests/std-math/fenv_capability_ok.c"

# shellcheck source=tests/lib/std-math-fenv-capability.sh
. "$LIB"

echo "=== STD-149: math fenv capability manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$MATH_RUNTIME" "$SMOKE_X" "$SMOKE_C" std/math/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-math-fenv-cap gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-149 fenv_available SHUX_MATH_FENV_CAP FENV_NOT_IMPL; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-math-fenv-cap gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "fenv_available" std/math/README.md 2>/dev/null; then
  echo "std-math-fenv-cap gate FAIL: README missing fenv_available" >&2
  exit 1
fi

sym_miss="$(std_math_fenv_cap_symbols_ok "$MOD_X" "$MATH_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_math_fenv_cap_emit_report "fail" 0 0 0 "$(ci_host_summary)"
  exit 1
fi
echo "std-math-fenv-cap registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/math/math.o

EXPECT="$(std_math_fenv_cap_expect_available "$VECTORS" 2>/dev/null || echo -1)"

C_OK=0
if std_math_fenv_cap_run_c_smoke "$MATH_RUNTIME" "$EXPECT"; then
  C_OK=1
else
  std_math_fenv_cap_emit_report "fail" 0 0 0 "$(ci_host_summary)"
  exit 1
fi

X_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-math-fenv-cap gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_math_fenv_cap_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
    exit 1
  fi
  if std_math_fenv_cap_run_x_smoke "$SHUX_BIN" "$SMOKE_X"; then
    X_OK=1
  else
    std_math_fenv_cap_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
    exit 1
  fi
else
  SKIP=1
fi

std_math_fenv_cap_emit_report "ok" "$C_OK" "$X_OK" "$SKIP" "$(ci_host_summary)"
echo "std-math-fenv-cap gate OK"
