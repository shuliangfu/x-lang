#!/usr/bin/env bash
# C-08: main thin entry + driver/*.x + build.x + runtime inventory (aggregate).
#
# Honesty: soft XLANG_C08_FAIL retired — incomplete child suite was portable
# false-green (exit 0 while ok<4). Children already hard-fail; aggregator must
# too. Report ok=/skip=.
#
# Usage: ./tests/run-c08-runtime-driver-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-c-c08-v1.md"
PREFIX="xlang: [XLANG_C08]"

die() {
  echo "c08 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail ok=${OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

OK=0
SKIP=1

echo "=== C-08: runtime → driver.x / build.x (honesty aggregate) ==="
if [ -f analysis/phase-c-c08-v1.md ]; then
  die "top-level phase-c-c08-v1.md resurrected (live = archive/phase/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "phase-c-c08-v1.md missing ## Gate honesty section"

for g in tests/run-c08-main-entry-gate.sh tests/run-c08-driver-x-gate.sh \
  tests/run-c08-build-x-gate.sh tests/run-c08-runtime-inventory-gate.sh; do
  chmod +x "$g"
  if ! "$g"; then
    die "child failed: $g"
  fi
  OK=$((OK + 1))
done

[ "$OK" -eq 4 ] || die "incomplete ($OK/4)"
SKIP=0
echo "c08 runtime-driver gate OK (4/4)"
echo "${PREFIX} status=ok ok=${OK} skip=${SKIP} host=$(ci_host_summary)"
