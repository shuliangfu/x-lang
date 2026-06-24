#!/usr/bin/env bash
# F-07 v1：已迁移纯 .sx 的 std 模块硬禁 cc -c（io/fs/heap/compress）。
#
# 用法：./tests/run-f07-no-cc-std-migrated-gate.sh
# 环境：SHUX_F07_NO_CC_MIGRATED_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F07_NO_CC_MIGRATED_FAIL:-0}
DOC="analysis/phase-f-f07-v1.md"
MANIFEST="tests/baseline/f07-no-cc-std-migrated.tsv"
BUILD_STD="tests/lib/build-std-c-o.sh"

die() {
  echo "f07-no-cc-migrated gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-07 v1: forbid cc -c migrated std modules ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-07 v1' "$DOC" || die "doc missing F-07 v1 marker"
grep -q '_std_c_o_forbidden_migrated' "$BUILD_STD" || die "build-std-c-o.sh missing F-07 guard"

# .c 源文件须已删除
for c in std/io/io.c std/fs/fs.c std/heap/heap.c std/compress/compress.c \
  std/compress/zlib/zlib.c std/compress/gzip/gzip.c \
  std/compress/brotli/brotli.c std/compress/zstd/zstd.c std/net/net.c \
  std/path/path.c std/uuid/uuid.c std/sort/sort.c; do
  [ ! -f "$c" ] || die "legacy C still exists: $c"
done

# ensure_std_c_o 须拒绝 migrated .o
# shellcheck source=tests/lib/build-std-c-o.sh
. "$BUILD_STD"
for o in ../std/io/io.o ../std/heap/heap.o ../std/compress/compress.o; do
  if ensure_std_c_o "$o" 2>/tmp/f07_forbidden.log; then
    die "ensure_std_c_o should reject $o"
  fi
  grep -q 'F-07 v1' /tmp/f07_forbidden.log || die "ensure_std_c_o reject message missing F-07 for $o"
done

# compiler/ 树内 bootstrap 脚本不得 cc -c migrated 模块
MIGRATED_RE='std/(io/io|fs/fs|heap/heap|compress/(compress|zlib/zlib|gzip/gzip|brotli/brotli|zstd/zstd))\.c'
for f in compiler/scripts/build_shux_asm.sh \
  compiler/scripts/relink_shux_asm_experimental_bootstrap.sh \
  compiler/scripts/relink_shux_asm_strict_glue.sh; do
  [ -f "$f" ] || die "missing $f"
  if grep -qE "cc .*-c.*${MIGRATED_RE}" "$f" 2>/dev/null; then
    die "$f still cc -c migrated std/*.c"
  fi
done

# tests/ 不得 ensure_std_c_o migrated（除 build-std-c-o.sh 自身与 F-07 gate）
while IFS= read -r f; do
  case "$f" in
    tests/lib/build-std-c-o.sh|tests/run-f07-no-cc-std-migrated-gate.sh) continue ;;
  esac
  if grep -qE 'ensure_std_c_o.*\.\./std/(io/io|fs/fs|heap/heap|compress/compress)\.o' "$f" 2>/dev/null; then
    die "$f still ensure_std_c_o migrated module"
  fi
done < <(find tests -name '*.sh' 2>/dev/null)

# Makefile 不得含 migrated .c 规则（F-03/F-04/F-14 已删源文件）
if grep -qE '\.\./std/(io/io|fs/fs|heap/heap|compress/compress|net/net)\.c' compiler/Makefile 2>/dev/null; then
  die "compiler/Makefile still references migrated std/*.c"
fi
[ -f analysis/phase-f-f07-v2.md ] || die "missing phase-f-f07-v2.md"
grep -q 'F-07 v2' analysis/phase-f-f07-v2.md || die "phase-f-f07-v2.md missing marker"

if [ -f tests/run-f06-runtime-std-o-cleanup-gate.sh ]; then
  echo "=== F-07 v1: delegate run-f06-runtime-std-o-cleanup-gate ==="
  chmod +x tests/run-f06-runtime-std-o-cleanup-gate.sh
  if ! SHUX_F06_RUNTIME_CLEANUP_FAIL="$FAIL" tests/run-f06-runtime-std-o-cleanup-gate.sh; then
    die "f06 sub-gate failed"
  fi
fi

if [ -f tests/run-f03-std-core-gate.sh ]; then
  echo "=== F-07 v1: delegate run-f03-std-core-gate ==="
  chmod +x tests/run-f03-std-core-gate.sh
  if ! SHUX_F03_CORE_FAIL="$FAIL" tests/run-f03-std-core-gate.sh; then
    die "f03-core sub-gate failed"
  fi
fi

echo "f07 no-cc migrated std gate OK (F-07 v1)"
