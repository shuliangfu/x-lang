#!/usr/bin/env bash
# C-08 v1：main.c 薄入口 + main.sx main_entry 登记门禁。
#
# 用法：./tests/run-c08-main-entry-gate.sh
set -e
cd "$(dirname "$0")/.."

MAIN_C="compiler/src/main.c"
MAIN_SX="compiler/src/main.sx"
DOC="analysis/phase-c-c08-v1.md"

echo "=== C-08: main.c thin entry ==="
for f in "$MAIN_C" "$MAIN_SX" "$DOC"; do
  [ -f "$f" ] || { echo "c08 main-entry FAIL: missing $f" >&2; exit 1; }
done

lines=$(wc -l <"$MAIN_C" | tr -d ' ')
if [ "$lines" -gt 20 ]; then
  echo "c08 main-entry FAIL: main.c too large ($lines lines, max 20)" >&2
  exit 1
fi
grep -q 'shux_forward_main_to_main_entry' "$MAIN_C" || { echo "c08 main-entry FAIL: main.c missing shux_forward_main_to_main_entry" >&2; exit 1; }
grep -q 'return shux_forward_main_to_main_entry(argc, argv)' "$MAIN_C" || { echo "c08 main-entry FAIL: main.c must return shux_forward_main_to_main_entry(...)" >&2; exit 1; }
grep -q 'function entry(' "$MAIN_SX" || {
  echo "c08 main-entry FAIL: main.sx missing entry() (exports as main_entry via module prefix)" >&2
  exit 1
}
grep -q 'driver_cmd_fmt' "$MAIN_SX" || { echo "c08 main-entry FAIL: main.sx missing driver subcmd dispatch" >&2; exit 1; }
echo "c08 main-entry gate OK (main.c lines=$lines)"
