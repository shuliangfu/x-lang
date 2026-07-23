#!/usr/bin/env bash
# 测试 std.map（empty_size）：typeck + 产品 -o / collection 回退链
# 权威链接与 run-set/run-heap 一致：collection_link_exe（禁手写残缺 gcc 清单）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q ../std/map/map.o ../std/heap/heap.o 2>/dev/null \
  || make -C compiler ../std/map/map.o ../std/heap/heap.o
# heap.o 传递依赖：page_mmap + process argv（std 模块编译会带入 process_* UNDEF）
make -C compiler -q ../std/heap/page_mmap.o 2>/dev/null \
  || make -C compiler ../std/heap/page_mmap.o
ensure_runtime_panic_o
ensure_runtime_process_argv_o
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
# shellcheck source=lib/collection-asm-gcc-link.sh
. "$(dirname "$0")/lib/collection-asm-gcc-link.sh"
XLANG=${XLANG:-./compiler/xlang}
LINK_XLANG="${XLANG_LINK_XLANG:-${RUN_XLANG:-$XLANG}}"
if ! "$XLANG" check -L . tests/map/main.x 2>&1; then
  echo "map test: typeck failed"
  exit 1
fi
if ! nm std/map/map.o 2>/dev/null | grep -q 'std_map_empty_size'; then
  echo "map test: missing std_map_empty_size in map.o"
  exit 1
fi
exe="/tmp/xlang_map_$$"
if ! collection_link_exe "$LINK_XLANG" tests/map/main.x "$exe" map 2>&1; then
  echo "map test: link failed"
  rm -f "$exe"
  exit 1
fi
exitcode=0
"$exe" 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  echo "map test: expected exit 0 (empty_size), got $exitcode"
  exit 1
fi
echo "map test OK"
