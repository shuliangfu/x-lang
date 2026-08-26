#!/usr/bin/env bash
# F-03 v2：std.fs 去 C 门禁（无 fs.c + posix/win32 + F-01）。
#
# 用法：./tests/run-f03-std-fs-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f03-std-fs-gate.sh
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; static + inventory +
# run-fs + dirmeta + xplat hard-fail (no soft die→exit0; no soft SKIP→OK when
# no native; no prefer-c). Soft XLANG_F03_FS_FAIL retired. Report
# inventory=/run=/dirmeta=/xplat=/skip=. Gate was portable-false-green (soft
# FAIL exit0 while dirmeta could red on false "stale fs.o" and asm run-fs
# already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F03_FS_DOC:-analysis/archive/phase/phase-f-f03-v2-fs.md}"
MANIFEST="tests/baseline/f03-std-fs.tsv"
FS_POSIX="std/fs/posix.x"
FS_WIN32="std/fs/win32.x"
FS_MOD="std/fs/mod.x"
PREFIX="xlang: [XLANG_F03_FS]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
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
  echo "f03-fs gate FAIL: $*" >&2
  echo "${PREFIX} status=fail inventory=${INVENTORY_OK:-0} run=${RUN_OK:-0} dirmeta=${DIRMETA_OK:-0} xplat=${XPLAT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

INVENTORY_OK=0
RUN_OK=0
DIRMETA_OK=0
XPLAT_OK=0
SKIP=1

echo "=== F-03 v2: std.fs remove fs.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v2' "$DOC" || die "doc missing F-03 v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted"
[ -f "$FS_POSIX" ] || die "missing posix.x"
[ -f "$FS_WIN32" ] || die "missing win32.x"
grep -q 'import("std.fs.posix")' "$FS_MOD" || die "mod.x missing posix import"
grep -q 'fs_open_read_c' "$FS_POSIX" || die "fs_posix missing fs_open_read_c"
grep -q 'fs_mmap_ro_c' "$FS_WIN32" || die "fs_win32 missing fs_mmap_ro_c"
if grep -q 'extern function fs_open_read_c' "$FS_MOD" 2>/dev/null; then
  die "mod.x still extern fs_open_read_c (should forward to platform)"
fi
# F-03 = delete fs.c; formal std/fs/fs.o may remain in labi on-demand plan
# (LABI_STD_OP_STD). Align with F-06: forbid argv0 always-resolve of legacy path.
# PLATFORM: SHARED archaeology / link_abi.
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"
if grep -q 'xlang_rel_o_path_from_argv0(argv\[0\], "std/fs/fs.o")' "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi still always-resolves std/fs/fs.o (legacy F-06)"
fi
if grep -q 'link_abi_asm_ld_push_obj.*std/fs/fs\.o' "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi still unconditionally push_obj std/fs/fs.o"
fi
grep -q 'have_fs' compiler/src/runtime_link_abi.h || die "runtime_link_abi.h missing have_fs"

if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        target="$FS_POSIX"
        case "$mod_path" in
          std/fs/win32.x) target="$FS_WIN32" ;;
          std/fs/mod.x) target="$FS_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi
echo "f03-fs manifest OK"

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 v2: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  # Hard-fail inventory regressions (total > baseline). total < baseline stays OK.
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi

echo "=== F-03 v2: run-fs (XLANG=$XLANG_BIN; hard) ==="
# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Avoid subscript make rebuilding prefer-c side path during dogfood.
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-fs.sh ]; then
  die "missing tests/run-fs.sh"
fi
chmod +x tests/run-fs.sh
if ! tests/run-fs.sh; then
  die "run-fs sub-gate failed"
fi
RUN_OK=1

echo "=== F-03 v2: run-std-fs-dirmeta-gate (STD-123; hard) ==="
if [ ! -f tests/run-std-fs-dirmeta-gate.sh ]; then
  die "missing tests/run-std-fs-dirmeta-gate.sh"
fi
chmod +x tests/run-std-fs-dirmeta-gate.sh
if ! tests/run-std-fs-dirmeta-gate.sh; then
  die "std-fs-dirmeta sub-gate failed"
fi
DIRMETA_OK=1

echo "=== F-03 v2: run-std-fs-crossplatform-gate (STD-003; hard) ==="
if [ ! -f tests/run-std-fs-crossplatform-gate.sh ]; then
  die "missing tests/run-std-fs-crossplatform-gate.sh"
fi
chmod +x tests/run-std-fs-crossplatform-gate.sh
if ! tests/run-std-fs-crossplatform-gate.sh; then
  die "std-fs-crossplatform sub-gate failed"
fi
XPLAT_OK=1
SKIP=0

echo "${PREFIX} status=ok inventory=${INVENTORY_OK} run=${RUN_OK} dirmeta=${DIRMETA_OK} xplat=${XPLAT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f03-fs gate OK (F-03 v2; posix.x/win32.x authority; honesty)"
