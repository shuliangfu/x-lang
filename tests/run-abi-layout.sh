#!/usr/bin/env bash
# ABI/layout C assertion (tests/abi/layout_abi.c).
#
# Honesty: leftover catalog no Honesty + missing run=/obs=/skip= report
# retired. No XLANG face (host cc of layout_abi.c). G.7: do not fork a
# resolver. Nested leftover of already-honesty-closed LANG-005
# (`run-lang-abi-stability.sh`); also a bstrict catalog leaf. Keep
# `abi/layout: OK`. cc/run failure stays hard. Explicit XLANG is ignored
# (no XLANG face; parent LANG-005 still hard-dies explicit-bad).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-abi-layout.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="${XLANG_ABI_LAYOUT_PREFIX:-xlang: [ABI_LAYOUT]}"
RUN_OK=0
OBS=0
SKIP=0
OUT="${TMPDIR:-/tmp}/xlang_layout_abi.$$"

die() {
  echo "abi-layout FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  rm -f "$OUT"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== abi-layout (host cc; no XLANG face) ==="
[ -f tests/abi/layout_abi.c ] || die "missing tests/abi/layout_abi.c"
# PLATFORM: SHARED — host-cc layout smoke; not a product -o path.
${CC:-cc} -Wall -Wextra -o "$OUT" tests/abi/layout_abi.c || die "cc layout_abi.c"
"$OUT" || die "layout_abi run"
rm -f "$OUT"
RUN_OK=1
echo "abi/layout: OK"
ok_report
