#!/usr/bin/env bash
# 类型特性烟测：函数重载可用、联合类型已禁用
#
# 用法：./tests/run-types-gate.sh
set -e
cd "$(dirname "$0")/.."

SHUX="${SHUX:-./compiler/shux-c}"
CHECK_CASES=(
  tests/types/overload.sx
)
RUN_CASES=(
  tests/types/overload.sx
)
REJECT_CASES=(
  tests/types/union_int.sx
)

# shellcheck source=tests/lib/shux-link-env.sh
. tests/lib/shux-link-env.sh

for f in "${CHECK_CASES[@]}" "${RUN_CASES[@]}" "${REJECT_CASES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "types gate FAIL: missing $f" >&2
    exit 1
  fi
done

if [ ! -x "$SHUX" ]; then
  make -C compiler shux-c
  SHUX=./compiler/shux-c
fi

echo "=== types gate: typeck ==="
for f in "${CHECK_CASES[@]}"; do
  if ! "$SHUX" check -L . "$f" >/dev/null 2>&1; then
    echo "types gate FAIL: typeck $f" >&2
    "$SHUX" check -L . "$f" 2>&1 | tail -6 >&2 || true
    exit 1
  fi
  echo "types gate OK: check $f"
done

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. tests/lib/bootstrap-link-shux.sh
TYPES_LINK_BACKEND_ARGS="${SHUX_TYPES_LINK_BACKEND_ARGS:--backend c}"

echo "=== types gate: link + run ==="
for f in "${RUN_CASES[@]}"; do
  base="/tmp/shux_types_$(basename "$f" .sx)"
  if ! $RUN_SHUX $TYPES_LINK_BACKEND_ARGS -L . "$f" -o "$base" 2>"${base}_build.log"; then
    echo "types gate FAIL: link $f" >&2
    tail -8 "${base}_build.log" 2>/dev/null >&2 || true
    exit 1
  fi
  exitcode=0
  "$base" >/dev/null 2>&1 || exitcode=$?
  if [ "$exitcode" -ne 0 ]; then
    echo "types gate FAIL: run $f exit=$exitcode" >&2
    exit 1
  fi
  echo "types gate OK: run $f"
done

echo "=== types gate: reject removed union syntax ==="
for f in "${REJECT_CASES[@]}"; do
  if "$SHUX" check -L . "$f" >/tmp/shux_types_reject.log 2>&1; then
    echo "types gate FAIL: union syntax unexpectedly accepted in $f" >&2
    exit 1
  fi
  if ! grep -q "union types are removed" /tmp/shux_types_reject.log; then
    echo "types gate FAIL: missing removed-union diagnostic for $f" >&2
    tail -8 /tmp/shux_types_reject.log >&2 || true
    exit 1
  fi
  echo "types gate OK: reject $f"
done

echo "types gate OK"
