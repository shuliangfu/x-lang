#!/usr/bin/env bash
# C-08 v1：main.c 薄入口 + main.x main_entry 登记门禁。
#
# 用法：./tests/run-c08-main-entry-gate.sh
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

MAIN_C="compiler/seeds/main.from_x.c"
MAIN_X="compiler/src/main.x"
DOC="${XLANG_C08_DOC:-analysis/archive/phase/phase-c-c08-v1.md}"

echo "=== C-08: main.c thin entry ==="
for f in "$MAIN_C" "$MAIN_X" "$DOC"; do
  [ -f "$f" ] || { echo "c08 main-entry FAIL: missing $f" >&2; exit 1; }
done

lines=$(wc -l <"$MAIN_C" | tr -d ' ')
if [ "$lines" -gt 20 ]; then
  echo "c08 main-entry FAIL: main.c too large ($lines lines, max 20)" >&2
  exit 1
fi
grep -q 'xlang_forward_main_to_main_entry' "$MAIN_C" || {
  echo "c08 main-entry FAIL: main.c missing xlang_forward_main_to_main_entry" >&2
  exit 1
}
# Live seed uses stmt-expr + local r; require the forward call (not a specific return shape).
grep -q 'xlang_forward_main_to_main_entry(argc, argv)' "$MAIN_C" || {
  echo "c08 main-entry FAIL: main.c must call xlang_forward_main_to_main_entry(argc, argv)" >&2
  exit 1
}
# Live ABI export is main_entry (bare `entry` retired — keep seed/.x aligned).
grep -q 'function main_entry(' "$MAIN_X" || {
  echo "c08 main-entry FAIL: main.x missing main_entry()" >&2
  exit 1
}
grep -q 'driver_cmd_fmt' "$MAIN_X" || {
  echo "c08 main-entry FAIL: main.x missing driver subcmd dispatch" >&2
  exit 1
}
echo "c08 main-entry gate OK (main.c lines=$lines)"
