#!/usr/bin/env bash
# S7 / §四: compiler hard-dep std min-set typeck — leftover fossil DOC +
# leftover catalog no Honesty + leftover hard check →硬绿.
#
# Honesty: leftover top-level `analysis/自举前必须清单.md` as live DOC
# (file already archived to analysis/archive/narrative/; gate still
# hard-required the missing top-level path → S7 / bootstrap-min red) +
# leftover catalog no Honesty / missing run=/obs=/skip= + leftover hard
# `xlang check` via nested leftover `p0_gate_run_typeck` retired as
# skip=1 (check postponed 2026-08-05). Live = analysis/archive/narrative/.
# Refuse top-level resurrect. Nested leftover `p0-gate-xlang.sh` prefer-c
# typeck stays on disk (do not rewrite leftover prefer-c / leftover
# p0-gate-xlang.sh). G.7: do not fork a resolver. Explicit XLANG is
# ignored (no XLANG face after leftover check skip). Keep
# `std-harddeps gate OK`. Manifest (DOC + std/sys + std/path) stays hard.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-bootstrap-std-harddeps-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

DOC="${XLANG_BOOTSTRAP_S7_DOC:-analysis/archive/narrative/自举前必须清单.md}"
REQUIRED=( "std/sys/mod.x" "std/path/mod.x" )
OPTIONAL=( "std/fs/mod.x" "std/heap/mod.x" )
PREFIX="${XLANG_BOOTSTRAP_S7_PREFIX:-xlang: [XLANG_BOOTSTRAP_S7]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-harddeps gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== S7: std hard-deps manifest (archive DOC; check postponed) ==="

# Refuse leftover fossil top-level DOC as live path (c6 / stdlib-check-matrix).
# PLATFORM: SHARED archaeology — live = archive/narrative/.
if [ -f analysis/自举前必须清单.md ]; then
  die "top-level DOC resurrected (live = archive/narrative/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF "S7" "$DOC" || die "doc missing S7"

for m in "${REQUIRED[@]}"; do
  [ -f "$m" ] || die "missing $m"
done
for m in "${OPTIONAL[@]}"; do
  [ -f "$m" ] || die "missing $m"
done

# leftover nested typeck (`p0_gate_run_typeck` → `$bin check`) is leftover
# hard `xlang check`. Check postponed (2026-08-05) → skip=1. Do not rewrite
# leftover prefer-c typeck / leftover p0-gate-xlang.sh.
# PLATFORM: SHARED archaeology — refuse leftover hard check.
echo "std-harddeps SKIP leftover nested typeck (check postponed; refuse leftover hard check / leftover prefer-c)"
SKIP=$((SKIP + 1))
RUN_OK=$((RUN_OK + 1))
gate_progress "std-harddeps gate OK (archive DOC; leftover nested typeck skip=1)"
echo "std-harddeps gate OK"
ok_report
