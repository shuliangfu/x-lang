#!/usr/bin/env bash
# B-16 v2：macOS open/read 读文件烟测（委托 run-sys-read-file-gate，Darwin only）。
#
# 用法：./tests/run-macos-read-file-gate.sh
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Darwin" ]; then
  echo "macos-read-file-gate: N/A (Darwin only)"
  exit 0
fi
grep -q 'macos_read_file_into' std/sys/macos.x || { echo "macos-read-file-gate FAIL: macos.x" >&2; exit 1; }
chmod +x tests/run-sys-read-file-gate.sh
SHUX_SYS_READ_FILE_FAIL=${SHUX_MACOS_READ_FILE_FAIL:-0} ./tests/run-sys-read-file-gate.sh
echo "macos-read-file-gate OK"
