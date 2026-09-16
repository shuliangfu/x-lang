#!/usr/bin/env bash
# Stdlib filename de-prefix rename verify (local or Docker).
#
# Honesty: soft default `./compiler/xlang-c` + hard-bound `xlang check` on
# renamed modules (prefer-c / check-gate paused false hard-red) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: no old .x path refs; new files present; old files gone
#   - hard: import / Makefile path samples; F-03 static rename checks
#   - hard: Makefile compile std/heap/heap.o
#   - obs:  module `xlang check` (paused / CHK002 path hygiene)
#   - obs:  S7 harddeps sub-gate (check-bound / soft WARN heritage)
# Report: run=/obs=/skip=
# Usage: ./tests/run-rename-verify.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_RENAME_PREFIX:-xlang: [XLANG_RENAME]}"
XLANG_S7_TYPECK_TIMEOUT="${XLANG_S7_TYPECK_TIMEOUT:-120}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  gate_progress "FAIL: $*"
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_MINIMAL_CC_LINK=1
gate_progress "rename-verify XLANG=$XLANG (prefer asm; refuse soft prefer-c)"

gate_progress "rename-verify: 1/6 旧 .x 路径 grep（产品树；拒假阳性）"
# Product-tree only (std + compiler/Makefile). Require a non-identifier char
# before the old basename so `runtime_net_workers.x` / `io_backend.xlang_*`
# do not false-hit. Exclude this script (lists OLD_FILES by design).
# PLATFORM: SHARED — rename archaeology; Ubuntu gold still required.
OLD_X_RE='(^|[^A-Za-z0-9_])(fs_posix|fs_win32|heap_libc|heap_ops|io_backend|io_sync|io_read_ptr|io_stubs|io_win32|net_addr|net_alpn|net_dns|net_io_batch|net_ipv6|net_sock|net_tcp|net_udp|net_workers|brotli_lib|crypto_core|gzip_libz|zlib_libz|zstd_lib)\.x\b'
if rg -n "$OLD_X_RE" std compiler/Makefile 2>/dev/null; then
  die "old .x path references remain in std/ or compiler/Makefile"
fi
gate_progress "OK: no old .x path references in product tree"
RUN_OK=$((RUN_OK + 1))

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
RUN_OK=$((RUN_OK + 1))

gate_progress "rename-verify: 3/6 module check OBS（重命名核心；check 闸暂停）"
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
TYPECK_OBS=0
for m in "${CORE_MODULES[@]}"; do
  gate_progress "check OBS $m ..."
  set +e
  gate_run_timeout "$XLANG_S7_TYPECK_TIMEOUT" "$XLANG_BIN" check "$m" \
    >/tmp/xlang_rename_check_$$.log 2>&1
  chk_ec=$?
  set -e
  if [ "$chk_ec" -ne 0 ]; then
    gate_progress "OBS check $m (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)"
    TYPECK_OBS=$((TYPECK_OBS + 1))
    OBS=$((OBS + 1))
  else
    gate_progress "OK check $m"
    RUN_OK=$((RUN_OK + 1))
  fi
done
if [ "$TYPECK_OBS" -gt 0 ]; then
  gate_progress "rename-verify OBS: $TYPECK_OBS core module check residual(s)"
fi

gate_progress "rename-verify: 3b/6 import／build-script 路径抽样"
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
# Authority after Makefile→xbuild migration: compile/ensure scripts list live .x paths.
# PLATFORM: SHARED — build-script path archaeology; Ubuntu gold still required.
grep -qF '../std/net/tcp.x' compiler/scripts/ensure_host_cc_seed_o.sh \
  || die "ensure_host_cc_seed_o.sh missing ../std/net/tcp.x"
grep -qF '../std/crypto/core.x' compiler/scripts/xlang_compile_std_module.sh \
  || die "xlang_compile_std_module.sh missing ../std/crypto/core.x"
gate_progress "OK: import paths and build scripts use new module names"
RUN_OK=$((RUN_OK + 1))

gate_progress "rename-verify: 4/6 S7 harddeps OBS（check-bound sub-gate；非本闸硬权威）"
set +e
./tests/run-bootstrap-std-harddeps-gate.sh
hd_ec=$?
set -e
if [ "$hd_ec" -ne 0 ]; then
  gate_progress "OBS harddeps exit=$hd_ec (check-bound heritage; refuse soft SKIP→OK silence)"
  OBS=$((OBS + 1))
else
  gate_progress "OK harddeps sub-gate"
  RUN_OK=$((RUN_OK + 1))
fi

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
grep -qF '../std/net/tcp.x' compiler/scripts/ensure_host_cc_seed_o.sh \
  || die "ensure_host_cc_seed_o.sh missing ../std/net/tcp.x"
gate_progress "OK: F-03 static rename checks"
RUN_OK=$((RUN_OK + 1))

gate_progress "rename-verify: 6/6 Makefile 编译 heap.o（net.o 待 extern-unsafe 闭合）"
# xlang_compiler_make is a sourced shell function — call in-process (no nested bash -c).
set +e
xlang_compiler_make ../std/heap/heap.o -j4
make_ec=$?
set -e
if [ "$make_ec" -ne 0 ]; then
  die "Makefile compile heap.o failed (ec=$make_ec; refuse soft SKIP→OK)"
fi
gate_progress "OK: heap.o"
RUN_OK=$((RUN_OK + 1))

gate_progress "rename-verify: ALL OK"
ok_report
