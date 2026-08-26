#!/usr/bin/env bash
# F-06: runtime / bootstrap cleanup of retired std C .o refs (io/fs/heap/compress).
#
# Usage: ./tests/run-f06-runtime-std-o-cleanup-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f06-runtime-std-o-cleanup-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + link_abi + bootstrap + stage2
# + boot contract (no soft die→exit0). Soft XLANG_F06_RUNTIME_CLEANUP_FAIL
# retired. Prefer asm; pin XLANG_LINK_XLANG for dogfood consistency. Report
# static=/link_abi=/bootstrap=/stage2=/contract=/skip=. Gate was
# portable-false-green (soft FAIL exit0 while static checks already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F06_DOC:-analysis/archive/phase/phase-f-f06-v1.md}"
DOC_V2="${XLANG_F06_DOC_V2:-analysis/archive/phase/phase-f-f06-v2.md}"
MANIFEST="tests/baseline/f06-runtime-std-o-cleanup.tsv"
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
RELINK_EXP="compiler/scripts/relink_xlang_asm_experimental_bootstrap.sh"
RELINK_GLUE="compiler/scripts/relink_xlang_asm_strict_glue.sh"
BOOT_TSV="tests/baseline/boot-std-link-contract.tsv"
STAGE2="compiler/verify-selfhost-stage2.sh"
PREFIX="xlang: [XLANG_F06_RUNTIME]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f06-runtime-cleanup gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} link_abi=${LINK_ABI_OK:-0} bootstrap=${BOOTSTRAP_OK:-0} stage2=${STAGE2_OK:-0} contract=${CONTRACT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
LINK_ABI_OK=0
BOOTSTRAP_OK=0
STAGE2_OK=0
CONTRACT_OK=0
SKIP=1

echo "=== F-06: runtime / bootstrap std .o cleanup (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$DOC_V2" ] || die "missing $DOC_V2"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-06 v1' "$DOC" || die "doc missing F-06 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -q 'F-06 v2' "$DOC_V2" || die "phase-f-f06-v2.md missing marker"
grep -qE '^## Gate' "$DOC_V2" || die "doc_v2 missing ## Gate section"

if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (F-06 live face = runtime_link_abi)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

# Manifest: absent / script / symbol rows (honesty TSV).
# PLATFORM: SHARED archaeology.
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    script)
      [ -f "$anchor" ] || die "manifest missing script: $anchor"
      ;;
    symbol)
      target="$mod_path"
      [ -n "$target" ] || die "manifest symbol missing mod_path for $item_id"
      [ -f "$target" ] || die "manifest target missing: $target"
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f06-runtime-cleanup manifest OK"
STATIC_OK=1

[ -f "$LINK_ABI" ] || die "missing $LINK_ABI"
for legacy in 'std/fs/fs.o' 'std/heap/heap.o' 'std/compress/compress.o'; do
  if grep -q "xlang_rel_o_path_from_argv0(argv\[0\], \"$legacy\")" "$LINK_ABI" 2>/dev/null; then
    die "runtime_link_abi still resolves $legacy"
  fi
done
grep -q 'F-06 v1' "$LINK_ABI" || die "runtime_link_abi missing F-06 v1 marker"
if grep -q 'link_abi_asm_ld_push_obj.*std/compress/compress.o' "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi.inc still push std/compress/compress.o"
fi
grep -q 'link_abi_generated_c_needs_zlib' "$LINK_ABI" || die "runtime_link_abi.inc missing generated C zlib scan"
grep -q 'xlang_std_compress_o_path' "$LINK_ABI" || die "runtime_link_abi.inc missing xlang_std_compress_o_path"
LINK_ABI_OK=1

for f in "$BUILD_ASM" "$RELINK_EXP" "$RELINK_GLUE"; do
  [ -f "$f" ] || die "missing $f"
  if grep -qE '../std/(fs/fs|io/io|heap/heap)\.o' "$f" 2>/dev/null; then
    die "$f still links legacy std fs/io/heap .o"
  fi
done
grep -q 'F-06 v1' "$BUILD_ASM" || die "build_xlang_asm.sh missing F-06 v1 marker"
if grep -qE 'cc .*-c.*std/(fs|io|heap)/' "$BUILD_ASM" 2>/dev/null; then
  die "build_xlang_asm.sh still cc -c std/fs|io|heap"
fi
BOOTSTRAP_OK=1

[ -f "$STAGE2" ] || die "missing $STAGE2"
if grep -qE '\.\./std/(fs/fs|io/io|heap/heap)\.o' "$STAGE2" 2>/dev/null; then
  die "verify-selfhost-stage2.sh still links legacy fs/io/heap .o"
fi
STAGE2_OK=1

grep -q $'compress\tstd_x\txlang_std_compress_o_path' "$BOOT_TSV" \
  || die "boot-std-link-contract.tsv compress not std_x"
CONTRACT_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
# Pin product link for dogfood consistency (static gate; keep env honest).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} link_abi=${LINK_ABI_OK} bootstrap=${BOOTSTRAP_OK} stage2=${STAGE2_OK} contract=${CONTRACT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f06 runtime std .o cleanup gate OK (F-06; honesty)"
