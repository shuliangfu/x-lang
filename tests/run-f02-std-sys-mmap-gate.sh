#!/usr/bin/env bash
# F-02 v1: std.sys mmap remove mmap.inc.c (Linux smoke + F-01 inventory).
#
# Usage: ./tests/run-f02-std-sys-mmap-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f02-std-sys-mmap-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory (no soft die→exit0).
# Soft XLANG_F02_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Linux MAP_SHARED smoke is observational (asm UNDEF residual
# std_sys_mmap_* / read_file_into — not soft false-green; do not die).
# Report static=/inventory=/linux=/skip=. Gate was portable-false-green
# (DOC still pointed at top-level analysis/phase-f-f02-v1.md after archive
# move; soft FAIL printed then exit0 while static checks already green).
# PLATFORM: SHARED archaeology (Linux smoke N/A on non-Linux).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F02_DOC:-analysis/archive/phase/phase-f-f02-v1.md}"
MANIFEST="tests/baseline/f02-std-sys-mmap.tsv"
PREFIX="xlang: [XLANG_F02_MMAP]"

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
  echo "f02-mmap gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} linux=${LINUX_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
LINUX_OK=0
SKIP=1

echo "=== F-02 v1: std.sys mmap remove mmap.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-02 v1' "$DOC" || die "doc missing F-02 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
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

[ ! -f std/sys/mmap.inc.c ] || die "mmap.inc.c should be deleted"
grep -q 'linux_mmap_rw' std/sys/linux.x || die "linux.x missing linux_mmap_rw"
grep -q 'linux_m' std/sys/mmap.x || die "mmap.x should import std.sys.linux"
if grep -q 'xlang_sys_mmap_rw_c' std/sys/mmap.x 2>/dev/null; then
  die "mmap.x still references xlang_sys_mmap_rw_c"
fi
echo "f02-mmap manifest OK"
STATIC_OK=1

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-02 v1: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi

if [ ! -f tests/run-linux-mmap-file-gate.sh ]; then
  die "missing tests/run-linux-mmap-file-gate.sh"
fi

if ci_is_linux; then
  if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
    die "no native xlang"
  fi
  echo "=== F-02 v1: linux-mmap-file (XLANG=$XLANG_BIN; observational) ==="
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: LINUX|UBUNTU — MAP_SHARED smoke observational (asm UNDEF residual).
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  export XLANG_SKIP_SUBSCRIPT_MAKE=1
  chmod +x tests/run-linux-mmap-file-gate.sh
  # Observational: product UNDEF residual — not soft; do not die the archaeology gate.
  if tests/run-linux-mmap-file-gate.sh; then
    LINUX_OK=1
  else
    echo "f02-mmap gate SKIP linux-mmap-file (observational; std_sys_mmap_* UNDEF residual)" >&2
    LINUX_OK=0
  fi
  SKIP=0
else
  echo "=== F-02 v1: linux-mmap-file N/A (non-Linux host) ==="
  LINUX_OK=0
  SKIP=0
fi

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} linux=${LINUX_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f02-mmap gate OK (F-02 v1; mmap.inc.c removed; honesty)"
