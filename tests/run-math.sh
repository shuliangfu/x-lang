#!/usr/bin/env bash
# 测试 std.math：typeck + math.o / libm 烟测
set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q xlang-c 2>/dev/null || XLANG_LEGACY_C_FRONTEND=1 make -C compiler xlang-c 2>/dev/null || make -C compiler -q 2>/dev/null || make -C compiler
fi
XLANG="${XLANG:-}"
if [ -z "$XLANG" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if [ -x "$cand" ]; then XLANG="$cand"; break; fi
  done
fi
if [ -z "$XLANG" ] || [ ! -x "$XLANG" ]; then
  echo "math test SKIP (no xlang/xlang-c)"
  exit 0
fi
# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if ! "$XLANG" check -L . tests/math/main.x 2>&1; then
  echo "math test: typeck failed"
  exit 1
fi
ensure_std_c_o ../std/math/math.o 2>/dev/null || true
ensure_runtime_math_libm_o 2>/dev/null || true
# shellcheck source=tests/lib/std-math-special.sh
. "$(dirname "$0")/lib/std-math-special.sh"
MATH_O="$(cd std/math && pwd)/math.o"
if ! std_math_special_run_c_smoke "$MATH_O"; then
  echo "math test: C smoke failed"
  exit 1
fi
echo "math test OK"
