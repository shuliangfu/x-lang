#!/usr/bin/env bash
# 测试 std.map（map_empty_size）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q ../std/map/map.o 2>/dev/null || make -C compiler ../std/map/map.o
ensure_runtime_panic_o
ensure_runtime_process_argv_o
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# shellcheck source=lib/collection-asm-gcc-link.sh
. "$(dirname "$0")/lib/collection-asm-gcc-link.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"
exe="/tmp/shux_map_$$"
if ! collection_link_exe "$LINK_SHUX" tests/map/main.sx "$exe" map 2>&1; then
  echo "map test: compile failed"
  rm -f "$exe"
  exit 1
fi
exitcode=0
"$exe" 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  echo "expected exit 0 (map_empty_size), got $exitcode"
  exit 1
fi
echo "map test OK"
