#!/usr/bin/env bash
# B-17 v3: win32 ExitProcess / std.sys exit facade (F-02 v2 pure .x).
#
# Usage: ./tests/run-b17-exit-process-gate.sh
# 2026-08-26: Honesty — needle follows live product authority
# `export function exit(` (calls win32.win32_exit_process). Fossil
# `function os_exit(` retired with the rename; soft F-02 parent never
# reached this check while DOC path was stale (portable false-green).
# PLATFORM: SHARED archaeology (facade static; Windows smoke N/A elsewhere).
set -e
cd "$(dirname "$0")/.."

echo "=== B-17 v3: ExitProcess facade ==="
grep -q 'ExitProcess' std/sys/win32.x || { echo "b17 gate FAIL: win32.x missing ExitProcess FFI" >&2; exit 1; }
grep -q 'win32_exit_process' std/sys/win32.x || { echo "b17 gate FAIL: win32.x" >&2; exit 1; }
[ ! -f std/sys/win32.inc.c ] || { echo "b17 gate FAIL: win32.inc.c should be removed (F-02 v2)" >&2; exit 1; }
# Live face is export function exit(…); Windows arm calls win32_exit_process.
# PLATFORM: SHARED — needle must match product, not fossil os_exit.
grep -q 'export function exit(' std/sys/mod.x || { echo "b17 gate FAIL: mod.x missing export function exit(" >&2; exit 1; }
grep -q 'win32.win32_exit_process' std/sys/mod.x || { echo "b17 gate FAIL: mod.x missing win32.win32_exit_process" >&2; exit 1; }
chmod +x tests/run-win32-write-gate.sh tests/run-win32-read-file-gate.sh 2>/dev/null || true
echo "b17 exit-process gate OK"
