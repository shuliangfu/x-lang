#!/usr/bin/env bash
# F 阶段 §9.2 任务清单聚合门禁（F-06～F-12 + F-01/F-09）。
#
# 用法：./tests/run-f-phase-f-92-batch-gate.sh
# 环境：SHUX_F_PHASE_F_92_FAIL=1 — 任一子 gate 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_PHASE_F_92_FAIL:-0}
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

die() {
  echo "f-phase-f-92-batch FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F §9.2 batch: ${#GATES[@]} gates ==="
for g in "${GATES[@]}"; do
  if [ ! -f "tests/$g" ]; then
    die "missing tests/$g"
  fi
  chmod +x "tests/$g"
  echo "--- $g ---"
  case "$g" in
    run-f06-runtime-std-o-cleanup-gate.sh)
      if ! SHUX_F06_RUNTIME_CLEANUP_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-f07-no-cc-std-migrated-gate.sh)
      if ! SHUX_F07_NO_CC_MIGRATED_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-f08-core-inventory-gate.sh)
      if ! SHUX_F08_CORE_INVENTORY_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-no-handwritten-c-gate.sh)
      if ! SHUX_NO_HANDWRITTEN_C_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-f10-test-x-portable-gate.sh)
      if ! SHUX_F10_TEST_X_PORTABLE_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-f11-selfhost-release-prep-gate.sh)
      if ! SHUX_F11_SELFHOST_RELEASE_PREP_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-f12-selfhost-doc-unified-gate.sh)
      if ! SHUX_F12_SELFHOST_DOC_UNIFIED_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    run-f-std-zero-c-track-gate.sh)
      if ! SHUX_F_STD_ZERO_C_FAIL="$FAIL" "tests/$g"; then die "$g failed"; fi
      ;;
    *)
      if ! "tests/$g"; then die "$g failed"; fi
      ;;
  esac
done
echo "f-phase-f-92-batch OK (${#GATES[@]} gates)"
