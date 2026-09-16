#!/usr/bin/env bash
# std.compress 测试：gzip / zstd / Brotli 往返。若 compress.o 未启用对应库，分支跳过仍通过。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
# F-04 v7: compress formats live in .x; compress-o-* are hub no-ops (runtime -l*).
# G.7: tests/lib/compiler-make.sh — ban bare make (MF phys-del). PLATFORM: SHARED
xlang_compiler_make compress-o-zlib-zstd 2>/dev/null \
  || xlang_compiler_make compress-o-zlib 2>/dev/null \
  || true

# 【Why 根源】compress 模块通过 extern FFI 调用 libz/libzstd/libbrotli，链接期需 -lz/-lzstd/-lbrotli*。
# 缺少任一库时编译/链接阶段即失败（zlib glue 桩 #include <zlib.h> 找不到；ld 找不到 -lz/-lzstd/-lbrotli*），
# 无法进入运行时跳过分支。此处检测 zlib.h 头文件 + 四个库链接性，缺失则跳过整个测试。
# 【Invariant】macOS/Ubuntu 装有完整压缩库，测试真正运行；Windows MinGW 无库则跳过（环境限制，非代码 bug）。
CC="${CC:-cc}"
if ! echo '#include <zlib.h>' | "$CC" -E -x c - >/dev/null 2>&1; then
  echo "compress test: skipped (zlib.h not available)"
  exit 0
fi
# 追加常见 lib 搜索路径（与 runtime_link_abi.inc ld_append_brew_lib_paths 对齐），尝试链接四个压缩库
XLANG_COMPRESS_LIB_DIRS=""
for d in /opt/homebrew/lib /usr/local/lib /usr/lib /lib; do
  [ -d "$d" ] && XLANG_COMPRESS_LIB_DIRS="$XLANG_COMPRESS_LIB_DIRS -L$d"
done
if ! echo 'int main(void){return 0;}' | "$CC" -x c - $XLANG_COMPRESS_LIB_DIRS -lz -lzstd -lbrotlienc -lbrotlidec -o /dev/null 2>/dev/null; then
  echo "compress test: skipped (zlib/zstd/brotli libraries not linkable)"
  exit 0
fi
XLANG="${XLANG:-./compiler/xlang}"
exe="/tmp/xlang_compress_$$"
if ! $XLANG build -L . tests/compress/main.x -o "$exe" 2>&1; then echo "compress test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "compress test: expected exit 0, got $exitcode"; exit 1; fi
echo "compress test OK"
