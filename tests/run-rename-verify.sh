#!/usr/bin/env bash
# 标准库文件名去目录前缀重构 — 验证脚本（本地或 Docker 内运行）
#
# 用法：./tests/run-rename-verify.sh
# Docker：SHUX_DOCKER_TIMEOUT_SEC=600 ./tests/lib/docker-linux-run.sh './tests/run-rename-verify.sh'
set -euo pipefail
cd "$(dirname "$0")/.."

chmod +x compiler/shux-c compiler/shux_asm_stage1 2>/dev/null || true
export SHUX="${SHUX:-./compiler/shux-c}"
export SHUX_MINIMAL_CC_LINK=1
export SHUX_S7_TYPECK_TIMEOUT="${SHUX_S7_TYPECK_TIMEOUT:-120}"

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

die() {
  gate_progress "FAIL: $*"
  exit 1
}

gate_progress "rename-verify: 1/6 旧 .x 路径 grep"
if rg -l '(fs_posix|fs_win32|heap_libc|heap_ops|io_backend|io_sync|io_read_ptr|io_stubs|io_win32|net_addr|net_alpn|net_dns|net_io_batch|net_ipv6|net_sock|net_tcp|net_udp|net_workers|brotli_lib|crypto_core|gzip_libz|zlib_libz|zstd_lib)\.x' \
  --glob '*.{x,sh,Makefile}' 2>/dev/null; then
  die "old .x path references remain"
fi
gate_progress "OK: no old .x path references"

gate_progress "rename-verify: 2/6 重命名文件存在性"
NEW_FILES=(
  std/fs/posix.x std/fs/win32.x
  std/heap/libc.x std/heap/ops.x
  std/io/backend.x std/io/sync.x std/io/read_ptr.x
  std/net/tcp.x std/net/addr.x std/net/dns.x
  std/crypto/core.x
  std/compress/brotli/lib.x std/compress/gzip/libz.x
)
OLD_FILES=(
  std/fs/fs_posix.x std/fs/fs_win32.x
  std/heap/heap_libc.x std/heap/heap_ops.x
  std/io/io_sync.x std/io/io_backend.x
  std/net/net_tcp.x std/crypto/crypto_core.x
)
for f in "${NEW_FILES[@]}"; do
  [ -f "$f" ] || die "missing renamed file $f"
done
for f in "${OLD_FILES[@]}"; do
  [ ! -f "$f" ] || die "old file still exists: $f"
done
gate_progress "OK: renamed files present, old files gone"

gate_progress "rename-verify: 3/6 shux-c typeck（重命名核心模块 fs/heap/io/crypto）"
CORE_MODULES=(
  std/fs/posix.x
  std/fs/mod.x
  std/heap/libc.x
  std/heap/mod.x
  std/io/backend.x
  std/io/sync.x
  std/io/mod.x
  std/crypto/core.x
)
TYPECK_FAIL=0
for m in "${CORE_MODULES[@]}"; do
  gate_progress "typeck $m ..."
  if ! timeout "$SHUX_S7_TYPECK_TIMEOUT" "$SHUX" check "$m"; then
    gate_progress "FAIL typeck $m"
    TYPECK_FAIL=$((TYPECK_FAIL + 1))
  else
    gate_progress "OK typeck $m"
  fi
done
[ "$TYPECK_FAIL" -eq 0 ] || die "$TYPECK_FAIL core module(s) failed typeck"

gate_progress "rename-verify: 3b/6 import/Makefile 路径抽样"
IMPORT_CHECKS=(
  'import("std.fs.posix")|std/fs/mod.x'
  'import("std.heap.libc")|std/heap/mod.x'
  'import("std.io.sync")|std/io/backend.x'
  'import("std.compress.brotli.lib")|std/compress/brotli/mod.x'
)
for pair in "${IMPORT_CHECKS[@]}"; do
  needle="${pair%%|*}"
  file="${pair##*|}"
  grep -qF "$needle" "$file" || die "missing $needle in $file"
done
grep -q '../std/net/tcp.x' compiler/Makefile || die "Makefile missing tcp.x"
grep -q '../std/crypto/core.x' compiler/Makefile || die "Makefile missing crypto/core.x"
gate_progress "OK: import paths and Makefile use new module names"

gate_progress "rename-verify: 4/6 S7 harddeps gate"
./tests/run-bootstrap-std-harddeps-gate.sh

gate_progress "rename-verify: 5/6 F-03 静态检查（无 runtime 子 gate）"
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted"
[ ! -f std/heap/heap.c ] || die "heap.c should be deleted"
[ ! -f std/io/io.c ] || die "io.c should be deleted"
[ -f std/fs/posix.x ] || die "missing posix.x"
[ -f std/heap/libc.x ] || die "missing libc.x"
[ -f std/io/sync.x ] || die "missing io/sync.x"
grep -q 'heap_mem_set_c' std/heap/ops.x || die "ops.x missing heap_mem_set_c"
grep -q 'import("std.heap.ops")' std/heap/mod.x || die "heap mod missing ops import"
grep -q 'fs_open_read_c' std/fs/posix.x || die "posix missing fs_open_read_c"
grep -q 'import("std.heap.libc")' std/heap/mod.x || die "mod.x missing libc import"
grep -q 'import("std.fs.posix")' std/fs/mod.x || die "mod.x missing posix import"
grep -q 'import("std.io.sync")' std/io/backend.x || die "backend.x missing sync import"
grep -q '../std/net/tcp.x' compiler/Makefile || die "Makefile missing tcp.x"
gate_progress "OK: F-03 static rename checks"

gate_progress "rename-verify: 6/6 Makefile 编译 heap.o（net.o 待 extern-unsafe 闭合）"
make -C compiler ../std/heap/heap.o -j4

gate_progress "rename-verify: ALL OK"
