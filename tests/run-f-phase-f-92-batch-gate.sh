#!/usr/bin/env bash
# F-phase §9.2 batch aggregate (F-06～F-12 + F-01/F-09).
#
# Usage: ./tests/run-f-phase-f-92-batch-gate.sh
# 2026-08-26: Honesty — hard-fail xbuild + child gates (no soft die→exit0;
# no soft child FAIL pass-through). Soft XLANG_F_PHASE_F_92_FAIL retired.
# f06/f07 already honesty-hard; remaining children still accept retired
# *_FAIL=1 until their own soft→hard waves. Gate was portable-false-green
# (soft FAIL exit0 while static checks already green).
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

echo "=== F §9.2 batch: ${#GATES[@]} gates (honesty) ==="
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"

for g in "${GATES[@]}"; do
  if [ ! -f "tests/$g" ]; then
    die "missing tests/$g"
  fi
  chmod +x "tests/$g"
  echo "--- $g ---"
  case "$g" in
    run-f06-runtime-std-o-cleanup-gate.sh|run-f07-no-cc-std-migrated-gate.sh|run-f-std-zero-c-track-gate.sh)
      # Already honesty-hard (soft *_FAIL retired).
      if ! "tests/$g"; then die "$g failed"; fi
      ;;
    run-std-c-inventory-gate.sh)
      if ! XLANG_STD_C_INVENTORY_FAIL=1 "tests/$g"; then die "$g failed"; fi
      ;;
    run-f08-core-inventory-gate.sh)
      if ! XLANG_F08_CORE_INVENTORY_FAIL=1 "tests/$g"; then die "$g failed"; fi
      ;;
    run-no-handwritten-c-gate.sh)
      if ! XLANG_NO_HANDWRITTEN_C_FAIL=1 "tests/$g"; then die "$g failed"; fi
      ;;
    run-f10-test-x-portable-gate.sh)
      if ! XLANG_F10_TEST_X_PORTABLE_FAIL=1 "tests/$g"; then die "$g failed"; fi
      ;;
    run-f11-selfhost-release-prep-gate.sh)
      if ! XLANG_F11_SELFHOST_RELEASE_PREP_FAIL=1 "tests/$g"; then die "$g failed"; fi
      ;;
    run-f12-selfhost-doc-unified-gate.sh)
      if ! XLANG_F12_SELFHOST_DOC_UNIFIED_FAIL=1 "tests/$g"; then die "$g failed"; fi
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
