#!/usr/bin/env bash
# F-phase §9.2 batch aggregate (F-06～F-12 + F-01/F-09).
#
# Usage: ./tests/run-f-phase-f-92-batch-gate.sh
# 2026-08-26: Honesty — hard-fail xbuild + child gates (no soft die→exit0;
# no soft child FAIL pass-through). Soft XLANG_F_PHASE_F_92_FAIL retired.
# 2026-08-26 (same day wave2): f08/f10/f11/f12/inventory/nhc soft→hard;
# aggregate no longer forces retired *_FAIL=1. Report ok=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

GATES=(
  run-std-c-inventory-gate.sh
  run-f06-runtime-std-o-cleanup-gate.sh
  run-f07-no-cc-std-migrated-gate.sh
  run-f08-core-inventory-gate.sh
  run-no-handwritten-c-gate.sh
  run-f10-test-x-portable-gate.sh
  run-f11-selfhost-release-prep-gate.sh
  run-f12-selfhost-doc-unified-gate.sh
  run-f-std-zero-c-track-gate.sh
)
PREFIX="xlang: [XLANG_F_PHASE_F_92]"

die() {
  echo "f-phase-f-92-batch FAIL: $*" >&2
  echo "${PREFIX} status=fail ok=${OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

OK=0
SKIP=1

echo "=== F §9.2 batch: ${#GATES[@]} gates (honesty; all children hard) ==="
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"

for g in "${GATES[@]}"; do
  if [ ! -f "tests/$g" ]; then
    die "missing tests/$g"
  fi
  chmod +x "tests/$g"
  echo "--- $g ---"
  # All children honesty-hard; do NOT re-export retired soft *_FAIL envs.
  # F-09: manifest-only — aggregate must not re-dogfood f04/f05/path
  # product closures (those own their gates; PROD_FAIL still opt-in).
  # PLATFORM: SHARED archaeology.
  case "$g" in
    run-no-handwritten-c-gate.sh)
      if ! XLANG_NO_HANDWRITTEN_C_MANIFEST_ONLY=1 "tests/$g"; then
        die "$g failed"
      fi
      ;;
    *)
      if ! "tests/$g"; then die "$g failed"; fi
      ;;
  esac
  OK=$((OK + 1))
done

SKIP=0
echo "f-phase-f-92-batch OK (${OK}/${#GATES[@]} gates)"
echo "${PREFIX} status=ok ok=${OK} skip=${SKIP} host=$(ci_host_summary)"
