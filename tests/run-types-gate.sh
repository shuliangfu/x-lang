#!/usr/bin/env bash
# 类型特性烟测：联合类型 T|U、函数重载（typeck + 最小可运行）
#
# 用法：./tests/run-types-gate.sh
set -e
cd "$(dirname "$0")/.."

SHU="${SHU:-./compiler/shu-c}"
CHECK_CASES=(
  tests/types/overload.su
  tests/types/union_int.su
)
RUN_CASES=(
  tests/types/overload.su
)

# shellcheck source=tests/lib/shu-link-env.sh
. tests/lib/shu-link-env.sh

for f in "${CHECK_CASES[@]}" "${RUN_CASES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "types gate FAIL: missing $f" >&2
    exit 1
  fi
done

if [ ! -x "$SHU" ]; then
  make -C compiler shu-c
  SHU=./compiler/shu-c
fi

echo "=== types gate: typeck ==="
for f in "${CHECK_CASES[@]}"; do
  if ! "$SHU" check -L . "$f" >/dev/null 2>&1; then
    echo "types gate FAIL: typeck $f" >&2
    "$SHU" check -L . "$f" 2>&1 | tail -6 >&2 || true
    exit 1
  fi
  echo "types gate OK: check $f"
done

# shellcheck source=tests/lib/bootstrap-link-shu.sh
. tests/lib/bootstrap-link-shu.sh

echo "=== types gate: link + run ==="
for f in "${RUN_CASES[@]}"; do
  base="/tmp/shu_types_$(basename "$f" .su)"
  if ! $RUN_SHU -L . "$f" -o "$base" 2>"${base}_build.log"; then
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

echo "types gate OK"
