#!/usr/bin/env bash
# VA-CAP gate: Stage 10 (10.7.1) Cap va_list without <stdarg.h>.
# Host-cc compile+run tests/sys/va_cap_smoke.c against xlang_va_cap.h.
# SHARED: Linux + Darwin (GCC/Clang builtins).
#
# Usage: ./tests/run-va-cap-gate.sh
# PLATFORM: SHARED
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="${XLANG_VA_CAP_PREFIX:-xlang: [XLANG_VA_CAP]}"
RUN_OK=0
OBS=0
SKIP=0
SMOKE_SRC="tests/sys/va_cap_smoke.c"
SMOKE_EXE="/tmp/xlang_va_cap_smoke.$$"
HEADER="compiler/include/xlang_va_cap.h"

die() {
  echo "va-cap gate FAIL: $*" >&2
  rm -f "$SMOKE_EXE" 2>/dev/null || true
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  rm -f "$SMOKE_EXE" 2>/dev/null || true
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== VA-CAP: Cap va_list start/arg/end/copy (10.7.1) ==="

[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"
[ -f "$HEADER" ] || die "missing $HEADER"

# Refuse accidental stdarg.h dependency in Cap header (G.7 Cap face).
if grep -E '^[ 	]*#[ 	]*include[ 	]*[<"]stdarg\.h[>"]' "$HEADER" >/dev/null 2>&1; then
  die "Cap header must not include stdarg.h"
fi

CC_BIN="${CC:-cc}"
rm -f "$SMOKE_EXE"
if ! "$CC_BIN" -O0 -Wall -Wextra -Icompiler/include -o "$SMOKE_EXE" "$SMOKE_SRC" \
  2>/tmp/xlang_va_cap_cc.err; then
  cat /tmp/xlang_va_cap_cc.err >&2 || true
  die "host-cc compile failed"
fi
[ -x "$SMOKE_EXE" ] || die "missing exe $SMOKE_EXE"

# Smoke must not include stdarg.h directly (stdio may transitively pull it — ignore).
if grep -E '^[ 	]*#[ 	]*include[ 	]*[<"]stdarg\.h[>"]' "$SMOKE_SRC" >/dev/null 2>&1; then
  die "smoke must not include stdarg.h"
fi

if ! "$SMOKE_EXE"; then
  die "smoke exit nonzero"
fi
RUN_OK=$((RUN_OK + 1))
ok_report
exit 0
