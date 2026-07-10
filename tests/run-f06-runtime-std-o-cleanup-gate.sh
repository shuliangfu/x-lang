#!/usr/bin/env bash
# F-06 v1：runtime / bootstrap 清理已退役 std C .o 引用（io/fs/heap/compress）。
#
# 用法：./tests/run-f06-runtime-std-o-cleanup-gate.sh
# 环境：SHUX_F06_RUNTIME_CLEANUP_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F06_RUNTIME_CLEANUP_FAIL:-0}
DOC="analysis/phase-f-f06-v1.md"
RUNTIME="compiler/seeds/runtime.from_x.c"
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"
RELINK_EXP="compiler/scripts/relink_shux_asm_experimental_bootstrap.sh"
RELINK_GLUE="compiler/scripts/relink_shux_asm_strict_glue.sh"
BOOT_TSV="tests/baseline/boot-std-link-contract.tsv"

die() {
  echo "f06-runtime-cleanup gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-06 v1: runtime / bootstrap std .o cleanup ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-06 v1' "$DOC" || die "doc missing F-06 v1 marker"

for legacy in 'std/fs/fs.o' 'std/heap/heap.o' 'std/compress/compress.o'; do
  if grep -q "shux_rel_o_path_from_argv0(argv\[0\], \"$legacy\")" "$RUNTIME" 2>/dev/null; then
    die "runtime.c still resolves $legacy"
  fi
done
grep -q 'F-06 v1' "$RUNTIME" || die "runtime.c missing F-06 v1 marker"

if grep -q 'link_abi_asm_ld_push_obj.*std/compress/compress.o' "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi.inc still push std/compress/compress.o"
fi
grep -q 'link_abi_generated_c_needs_zlib' "$LINK_ABI" || die "runtime_link_abi.inc missing generated C zlib scan"
grep -q 'shux_std_compress_o_path' "$LINK_ABI" || die "runtime_link_abi.inc missing shux_std_compress_o_path"

for f in "$BUILD_ASM" "$RELINK_EXP" "$RELINK_GLUE"; do
  [ -f "$f" ] || die "missing $f"
  if grep -qE '../std/(fs/fs|io/io|heap/heap)\.o' "$f" 2>/dev/null; then
    die "$f still links legacy std fs/io/heap .o"
  fi
done
grep -q 'F-06 v1' "$BUILD_ASM" || die "build_shux_asm.sh missing F-06 v1 marker"
if grep -qE 'cc .*-c.*std/(fs|io|heap)/' "$BUILD_ASM" 2>/dev/null; then
  die "build_shux_asm.sh still cc -c std/fs|io|heap"
fi

grep -q $'compress\tstd_x\tshux_std_compress_o_path' "$BOOT_TSV" \
  || die "boot-std-link-contract.tsv compress not std_x"

STAGE2="compiler/verify-selfhost-stage2.sh"
[ -f "$STAGE2" ] || die "missing $STAGE2"
if grep -qE '\.\./std/(fs/fs|io/io|heap/heap)\.o' "$STAGE2" 2>/dev/null; then
  die "verify-selfhost-stage2.sh still links legacy fs/io/heap .o"
fi
[ -f analysis/phase-f-f06-v2.md ] || die "missing phase-f-f06-v2.md"
grep -q 'F-06 v2' analysis/phase-f-f06-v2.md || die "phase-f-f06-v2.md missing marker"

echo "f06 runtime std .o cleanup gate OK (F-06 v1+v2)"
