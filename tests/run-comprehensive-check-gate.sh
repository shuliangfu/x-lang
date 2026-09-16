#!/usr/bin/env bash
# STD-168: comprehensive check bundle — leftover catalog no Honesty →硬绿.
#
# Honesty: leftover catalog no Honesty + missing run=/obs=/skip= report
# retired. Nested leftover of already-honesty-closed
# placeholder-inventory / doc-07* / next-yellow / cookbook / perf-weekly.
# G.7: do not fork a resolver in this host (complete existing nested
# resolve_shu). Keep `comprehensive-check gate OK`. Nested child failure
# stays hard. Explicit XLANG hard-dies via nested already-honesty-closed
# children (placeholder has no XLANG face; later children hard-die
# explicit-bad). No XLANG face on this parent.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-comprehensive-check-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="${XLANG_COMPREHENSIVE_CHECK_PREFIX:-xlang: [XLANG_COMPREHENSIVE_CHECK]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "comprehensive-check gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== STD-168: comprehensive check bundle (nested already-honesty-closed) ==="

run_nested() {
  local s="$1"
  chmod +x "$s"
  "./$s" || die "nested $s failed"
  RUN_OK=$((RUN_OK + 1))
}

# PLATFORM: SHARED archaeology — nested children already honesty-closed;
# this host only sequences them. Do not fork a resolver here (G.7).
run_nested tests/run-placeholder-inventory-gate.sh
run_nested tests/run-doc-07-comprehensive-audit-gate.sh
run_nested tests/run-next-yellow-clear-gate.sh
run_nested tests/run-doc-07-phase2-sync-gate.sh
run_nested tests/run-doc-07-phase3-sync-gate.sh
run_nested tests/run-doc-cookbook-expand-gate.sh
run_nested tests/run-doc-07-stdlib-fulltable-gate.sh
chmod +x tests/run-perf-sqlite-gate.sh tests/lib/perf-sqlite.sh \
  tests/run-perf-phase3-gate.sh tests/lib/perf-phase3.sh \
  tests/lib/placeholder-inventory.sh
run_nested tests/run-perf-weekly-gate.sh

echo "comprehensive-check gate OK"
ok_report
